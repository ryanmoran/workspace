# Testing Strategies for Legacy Code

Practical approaches for testing code that wasn't designed to be tested.

## The Challenge

Legacy code often has these characteristics that make testing difficult:

- **Global state** - Functions depend on global variables
- **Hidden dependencies** - Database connections, file I/O, external services
- **Tight coupling** - Everything interconnected
- **Side effects** - Functions do more than one thing
- **No clear boundaries** - Hard to isolate units
- **Large functions** - 100+ line methods doing multiple things

**The Solution:** Apply these strategies to gradually build a safety net.

---

## Strategy 1: Characterization Tests

**Purpose:** Document current behavior (bugs and all) before refactoring.

### What Are Characterization Tests?

Tests that describe what the code *actually does*, not what it *should do*.

**Key principle:** Don't fix bugs while writing characterization tests. Just document behavior.

### How to Write Them

1. **Choose a function to test**
2. **Write a test with a guess**
3. **Run it and watch it fail**
4. **Use the actual output as the expected value**
5. **Test passes - you've documented the behavior**

### Example

**Legacy Code:**

```go
// What does this do? Let's find out with tests
func CalculateDiscount(customer Customer, amount float64) float64 {
    discount := 0.0

    if customer.Type == "premium" {
        discount = amount * 0.15
    } else if customer.Type == "regular" {
        discount = amount * 0.10
    }

    if customer.YearsActive > 5 {
        discount = discount * 1.5 // Weird: multiplies discount by 1.5
    }

    return discount
}
```

**Characterization Tests:**

```go
func TestCalculateDiscount_PremiumCustomer(t *testing.T) {
    customer := Customer{Type: "premium", YearsActive: 2}

    discount := CalculateDiscount(customer, 100.0)

    // Documents actual behavior
    require.Equal(t, 15.0, discount)
}

func TestCalculateDiscount_RegularCustomer(t *testing.T) {
    customer := Customer{Type: "regular", YearsActive: 2}

    discount := CalculateDiscount(customer, 100.0)

    require.Equal(t, 10.0, discount)
}

func TestCalculateDiscount_LongTimeCustomer(t *testing.T) {
    customer := Customer{Type: "premium", YearsActive: 6}

    discount := CalculateDiscount(customer, 100.0)

    // TODO: This seems like a bug - 22.5 seems wrong
    // But this is current behavior, so we document it
    require.Equal(t, 22.5, discount)
}

func TestCalculateDiscount_UnknownType(t *testing.T) {
    customer := Customer{Type: "unknown", YearsActive: 2}

    discount := CalculateDiscount(customer, 100.0)

    // Documents edge case: returns 0 for unknown type
    require.Equal(t, 0.0, discount)
}
```

### Benefits

- Documents current behavior
- Prevents accidental changes during refactoring
- Identifies bugs without fixing them yet
- Fast to write

### When to Use

- Beginning of refactoring
- Unclear what code should do
- Code has few or no tests
- Need safety net quickly

---

## Strategy 2: Approval Tests (Golden Master)

**Purpose:** Test complex outputs (JSON, HTML, reports) by comparing snapshots.

### How It Works

1. **Capture current output** (the "golden master")
2. **Store it in a file**
3. **Future tests compare against this baseline**
4. **Any difference is a test failure**

### Example

**Legacy Code:**

```go
func GenerateInvoice(order Order) string {
    // Returns complex HTML invoice
    var buf strings.Builder

    buf.WriteString("<html><body>")
    buf.WriteString(fmt.Sprintf("<h1>Invoice #%d</h1>", order.ID))
    buf.WriteString("<table>")

    for _, item := range order.Items {
        buf.WriteString(fmt.Sprintf("<tr><td>%s</td><td>$%.2f</td></tr>", 
            item.Name, item.Price))
    }

    buf.WriteString("</table>")
    buf.WriteString(fmt.Sprintf("<p>Total: $%.2f</p>", order.Total))
    buf.WriteString("</body></html>")

    return buf.String()
}
```

**Approval Test:**

```go
import "github.com/approvals/go-approval-tests"

func TestGenerateInvoice_Standard(t *testing.T) {
    order := Order{
        ID: 12345,
        Items: []LineItem{
            {Name: "Widget", Price: 10.00},
            {Name: "Gadget", Price: 25.00},
        },
        Total: 35.00,
    }

    result := GenerateInvoice(order)

    // First run: creates testdata/TestGenerateInvoice_Standard.approved.txt
    // Future runs: compares result against approved file
    approvaltests.VerifyString(t, result)
}
```

**Generated File (`testdata/TestGenerateInvoice_Standard.approved.txt`):**

```html
<html><body><h1>Invoice #12345</h1><table><tr><td>Widget</td><td>$10.00</td></tr><tr><td>Gadget</td><td>$25.00</td></tr></table><p>Total: $35.00</p></body></html>
```

### Benefits

- Easy to write for complex outputs
- Comprehensive coverage
- Detects any change
- Works with JSON, XML, HTML, reports, etc.

### When to Use

- Complex output formats
- Integration testing
- End-to-end testing
- Legacy system with many outputs

### Tools

- Go: `github.com/approvals/go-approval-tests`
- Node: `jest --updateSnapshot`
- General: Store files in `testdata/` directory

---

## Strategy 3: Test Islands

**Purpose:** Test small pieces of untestable code by extracting them.

### The Problem

You have a 200-line function that:

- Accesses global state
- Calls database directly
- Has side effects everywhere
- Can't be tested as-is

### The Solution

1. **Identify small, pure calculation** within the mess
2. **Extract it into separate function**
3. **Test the extracted function**
4. **Repeat** to create "islands" of tested code

### Example

**Before (Untestable):**

```go
// 200-line function, can't test easily
func ProcessOrder(orderID int) error {
    // Global database access
    order := GlobalDB.GetOrder(orderID)

    // Embedded calculation (can extract this!)
    tax := 0.0
    if order.State == "CA" {
        tax = order.Subtotal * 0.0825
    } else if order.State == "NY" {
        tax = order.Subtotal * 0.08
    } else {
        tax = order.Subtotal * 0.06
    }

    total := order.Subtotal + tax + order.Shipping

    // More global database access
    GlobalDB.UpdateOrder(orderID, total)

    // More tangled logic...
    // ... 150 more lines ...

    return nil
}
```

**After (Extract & Test Island):**

```go
// Extracted, testable function
func calculateTax(state string, subtotal float64) float64 {
    switch state {
    case "CA":
        return subtotal * 0.0825
    case "NY":
        return subtotal * 0.08
    default:
        return subtotal * 0.06
    }
}

// Test the island!
func TestCalculateTax(t *testing.T) {
    tests := []struct {
        name     string
        state    string
        subtotal float64
        expected float64
    }{
        {"California", "CA", 100.0, 8.25},
        {"New York", "NY", 100.0, 8.00},
        {"Other", "TX", 100.0, 6.00},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := calculateTax(tt.state, tt.subtotal)
            require.InDelta(t, tt.expected, result, 0.01)
        })
    }
}

// Original function now uses the tested island
func ProcessOrder(orderID int) error {
    order := GlobalDB.GetOrder(orderID)

    tax := calculateTax(order.State, order.Subtotal) // Tested!
    total := order.Subtotal + tax + order.Shipping

    GlobalDB.UpdateOrder(orderID, total)

    // ... rest of code ...

    return nil
}
```

**Continue extracting more islands:**

```go
// Extract shipping calculation
func calculateTotal(subtotal, tax, shipping float64) float64 {
    return subtotal + tax + shipping
}

// Test it
func TestCalculateTotal(t *testing.T) {
    result := calculateTotal(100.0, 8.25, 5.00)
    require.Equal(t, 113.25, result)
}
```

### Benefits

- Incremental progress
- Each extraction reduces risk
- Gradually builds test coverage
- Original code gets smaller

### When to Use

- Function too large to test
- Can't inject dependencies easily
- Need to start somewhere
- Want quick wins

---

## Strategy 4: Emergency Rescue Pattern

**Purpose:** When code is truly impossible to test, replace it.

### The Situation

You have code that:

- Is too tangled to extract from
- Would take weeks to make testable
- Needs to change NOW

### The Solution

**Don't try to test the old code. Write new code that you CAN test.**

### Steps

1. **Ignore the old function**
2. **Write test for function you WISH existed**
3. **Implement new function** (passes test)
4. **Replace all call sites**
5. **Delete old function**

### Example

**Old Code (Untestable mess):**

```go
// 300 lines of spaghetti code
// Global variables, side effects, database calls
// You've tried everything - it won't cooperate
func LegacyCalculatePrice(itemID int) float64 {
    // ... horrible tangled mess ...
    // ... global state everywhere ...
    // ... side effects ...
    return price
}
```

**New Approach:**

**1. Write test for function you WISH existed:**

```go
func TestCalculatePrice(t *testing.T) {
    item := Item{
        BasePrice:  100.0,
        Category:   "electronics",
        IsOnSale:   true,
    }

    price := CalculatePrice(item)

    require.Equal(t, 90.0, price)
}
```

**2. Implement new function (clean, testable):**

```go
func CalculatePrice(item Item) float64 {
    price := item.BasePrice

    if item.IsOnSale {
        price = applyDiscount(price, item.Category)
    }

    return price
}

func applyDiscount(price float64, category string) float64 {
    discountRate := 0.1 // 10% default

    if category == "electronics" {
        discountRate = 0.1
    } else if category == "clothing" {
        discountRate = 0.2
    }

    return price * (1 - discountRate)
}
```

**3. Replace call sites:**

```go
// Old code
price := LegacyCalculatePrice(itemID)

// New code
item := db.GetItem(itemID) // Make dependency explicit
price := CalculatePrice(item)
```

**4. Delete old function once all call sites updated:**

```go
// Delete entire LegacyCalculatePrice function
```

### Benefits

- Escape from untestable code
- Fresh start with clean design
- Tested from the beginning
- Faster than fixing old code

### Risks

- Must ensure behavior matches
- Need to update all call sites
- Characterization tests help verify equivalence

### When to Use

- Old code truly untestable
- Tried other strategies unsuccessfully
- Need to make changes frequently
- Cost of rewrite < cost of maintaining old code

---

## Strategy 5: Dependency Injection for Testability

**Purpose:** Make hidden dependencies explicit so you can mock them.

### The Problem

Code depends on things you can't control in tests:

- Database
- File system
- Network calls
- Current time
- Random numbers

### The Solution

Make dependencies explicit parameters or fields.

### Example: Database Dependency

**Before (Hard to test):**

```go
func GetActiveUsers() ([]User, error) {
    // Direct database access
    db := sql.Open("postgres", "connection string")
    rows, err := db.Query("SELECT * FROM users WHERE active = true")
    // ...
}

// Can't test without real database
```

**After (Injectable dependency):**

```go
type UserStore interface {
    GetActive() ([]User, error)
}

func GetActiveUsers(store UserStore) ([]User, error) {
    return store.GetActive()
}

// Real implementation
type PostgresUserStore struct {
    db *sql.DB
}

func (s PostgresUserStore) GetActive() ([]User, error) {
    rows, err := s.db.Query("SELECT * FROM users WHERE active = true")
    // ...
}

// Mock for testing
type MockUserStore struct {
    users []User
}

func (m MockUserStore) GetActive() ([]User, error) {
    return m.users, nil
}

// Test with mock
func TestGetActiveUsers(t *testing.T) {
    mockStore := MockUserStore{
        users: []User{
            {ID: 1, Name: "Alice", Active: true},
            {ID: 2, Name: "Bob", Active: true},
        },
    }

    users, err := GetActiveUsers(mockStore)

    require.NoError(t, err)
    require.Len(t, users, 2)
}
```

### Example: Time Dependency

**Before (Hard to test time-dependent logic):**

```go
func IsExpired(expiryDate time.Time) bool {
    return time.Now().After(expiryDate)
}

// How do you test this? Can't control time.Now()
```

**After (Injectable time):**

```go
type Clock interface {
    Now() time.Time
}

type RealClock struct{}

func (RealClock) Now() time.Time {
    return time.Now()
}

func IsExpired(expiryDate time.Time, clock Clock) bool {
    return clock.Now().After(expiryDate)
}

// Test with fake clock
type FakeClock struct {
    current time.Time
}

func (f FakeClock) Now() time.Time {
    return f.current
}

func TestIsExpired(t *testing.T) {
    fakeClock := FakeClock{
        current: time.Date(2024, 1, 15, 0, 0, 0, 0, time.UTC),
    }
    expiryDate := time.Date(2024, 1, 10, 0, 0, 0, 0, time.UTC)

    result := IsExpired(expiryDate, fakeClock)

    require.True(t, result)
}
```

### When to Use

- Code depends on external systems
- Can modify function signature
- Want to test without real dependencies
- Building new test suite

---

## Strategy 6: Subcutaneous Testing

**Purpose:** Test just below the UI/API layer when unit testing is too hard.

### What Is It?

Testing at the boundary just below:

- HTTP handlers (but not the HTTP layer itself)
- CLI commands (but not the CLI parsing)
- UI controllers (but not the UI framework)

### Benefits

- Avoids testing framework complexity
- Still tests most of the logic
- Faster than end-to-end tests
- More integration-like than unit tests

### Example: HTTP Handler

**System structure:**

```text
HTTP Request → Handler → Business Logic → Database
```

**Instead of testing HTTP layer (slow, complex):**

```go
// Full HTTP test (slow)
func TestCreateUser_HTTP(t *testing.T) {
    server := httptest.NewServer(handler)
    defer server.Close()

    resp, err := http.Post(server.URL+"/users", "application/json", body)
    // Parse response, check status codes, headers, etc.
}
```

**Test the business logic directly (subcutaneous):**

```go
// Test business logic, skip HTTP (faster)
func TestCreateUser_Logic(t *testing.T) {
    service := NewUserService(mockDB)

    user, err := service.CreateUser(UserInput{
        Email: "test@example.com",
        Name:  "Test User",
    })

    require.NoError(t, err)
    require.Equal(t, "test@example.com", user.Email)
}
```

### When to Use

- Legacy system with framework complexity
- Integration tests needed
- Unit tests too difficult
- Want faster feedback than E2E

---

## Combining Strategies

Use multiple strategies together:

1. **Start with Characterization Tests** - Document current behavior
2. **Add Approval Tests** - For complex outputs
3. **Extract Test Islands** - Make pieces testable
4. **Inject Dependencies** - As you refactor
5. **Add Unit Tests** - For newly extracted code
6. **Subcutaneous Tests** - For integration coverage

### Example Workflow

```text
Day 1: Characterization tests for main function
Day 2: Extract calculation logic → Test Island
Day 3: Extract validation logic → Test Island  
Day 4: Inject database dependency → Unit tests with mock
Day 5: Refactor with confidence (all tests green)
```

---

## Testing Anti-Patterns

### Don't Do This

**1. Modifying code to make it testable without tests first**

- Write characterization tests FIRST
- Then refactor to improve testability

**2. Testing implementation details**

- Test behavior, not internals
- Tests should survive refactoring

**3. Skipping edge cases**

- Legacy code often has hidden edge cases
- Test nulls, empties, negatives, boundaries

**4. Writing tests after refactoring**

- Tests written after can't verify you didn't break things
- Write tests BEFORE any changes

**5. Fixing bugs while writing characterization tests**

- Document bugs with TODO
- Fix bugs in separate commit AFTER tests exist

---

## Quick Reference

| Situation | Strategy | Time to Implement |
|-----------|----------|-------------------|
| Don't know what code does | Characterization Tests | 30 min |
| Complex output (JSON, HTML) | Approval Tests | 15 min |
| Large untestable function | Test Islands | 1-2 hours |
| Impossible to test | Emergency Rescue | 2-4 hours |
| Hidden dependencies | Dependency Injection | 1-3 hours |
| Framework complexity | Subcutaneous Tests | 30 min |

---

## Resources

- Working Effectively with Legacy Code (Michael Feathers)
- <https://bitfieldconsulting.com/posts/testing-legacy-code>
- <https://github.com/approvals/go-approval-tests>
- <https://martinfowler.com/bliki/CharacterizationTest.html>
