# Code Smells Catalog

Comprehensive reference for identifying code that needs refactoring.

## Categories

1. [Bloaters](#bloaters) - Code grown too large
2. [Object-Orientation Abusers](#object-orientation-abusers) - Improper OOP usage
3. [Change Preventers](#change-preventers) - Changes require many edits
4. [Dispensables](#dispensables) - Unnecessary code
5. [Couplers](#couplers) - Excessive dependencies

---

## Bloaters

Code elements that have grown so large they're hard to work with.

### Long Method

**Description:** Method/function has too many lines of code (>20-30 lines).

**Why it's bad:**

- Hard to understand
- Difficult to test
- Hides multiple responsibilities
- Harder to reuse parts of logic

**Examples:**

```go
// BAD: 50+ line method doing multiple things
func ProcessOrder(order Order) error {
    // 10 lines of validation
    if order.CustomerID == 0 { return errors.New("invalid customer") }
    if order.Total < 0 { return errors.New("negative total") }
    // ... more validation

    // 15 lines of tax calculation
    taxRate := 0.08
    if order.State == "CA" { taxRate = 0.0825 }
    // ... complex tax logic

    // 10 lines of inventory check
    for _, item := range order.Items {
        stock := db.GetStock(item.ProductID)
        // ... inventory logic
    }

    // 15 lines of payment processing
    payment := ProcessPayment(order.PaymentMethod, order.Total)
    // ... payment logic

    return nil
}
```

**How to fix:** Extract Method (see refactoring-techniques.md)

### Large Class

**Description:** Class has too many fields, methods, or responsibilities (>200-300 lines).

**Why it's bad:**

- Violates Single Responsibility Principle
- Hard to understand and maintain
- Difficult to test
- Often duplicates code from other classes

**Warning signs:**

- Class has >10 instance variables
- Class has >20 methods
- Some methods only use subset of fields
- Class name is vague ("Manager", "Helper", "Utility")

**Examples:**

```go
// BAD: God object doing everything
type OrderManager struct {
    db           *Database
    emailClient  *EmailClient
    inventory    *Inventory
    payment      *PaymentProcessor
    shipping     *ShippingService
    analytics    *Analytics
    logger       *Logger
    cache        *Cache
    // 15 more fields...
}

// 50+ methods including:
// - Order validation
// - Inventory management  
// - Payment processing
// - Email notifications
// - Shipping calculations
// - Analytics tracking
// - Cache management
// etc.
```

**How to fix:** Extract Class, Extract Subclass

### Long Parameter List

**Description:** Method has too many parameters (>3-4).

**Why it's bad:**

- Hard to remember parameter order
- Easy to pass wrong values
- Method signature changes frequently
- Often indicates missing abstraction

**Examples:**

```go
// BAD: 8 parameters
func CreateUser(
    firstName, lastName, email, phone, address, city, state, zip string,
) (*User, error) {
    // ...
}

// Call site is confusing
user, err := CreateUser("John", "Doe", "john@example.com", 
    "555-1234", "123 Main St", "Springfield", "IL", "62701")
```

**How to fix:** Introduce Parameter Object, Preserve Whole Object

### Primitive Obsession

**Description:** Using primitives (strings, ints) instead of small objects for domain concepts.

**Why it's bad:**

- Duplicated validation logic
- No type safety
- Unclear intent
- Business rules scattered

**Examples:**

```go
// BAD: Everything is a string
type User struct {
    Email       string // Could be anything
    PhoneNumber string // No format validation
    ZipCode     string // Could be "abc"
    SSN         string // No protection
}

// Validation scattered everywhere
func IsValidEmail(email string) bool { /* ... */ }
func IsValidPhone(phone string) bool { /* ... */ }
func IsValidZip(zip string) bool { /* ... */ }
```

**How to fix:** Replace Data Value with Object

### Data Clumps

**Description:** Same group of variables appearing together repeatedly.

**Why it's bad:**

- Code duplication
- Missing abstraction
- Changes require updates in many places

**Examples:**

```go
// BAD: These 3 variables always appear together
func CalculateDistance(startLat, startLon, endLat, endLon float64) float64 {}
func GetWeather(lat, lon float64) Weather {}
func FindNearby(lat, lon float64, radius float64) []Location {}

// Should be:
type Location struct {
    Latitude  float64
    Longitude float64
}

func CalculateDistance(start, end Location) float64 {}
func GetWeather(loc Location) Weather {}
func FindNearby(loc Location, radius float64) []Location {}
```

**How to fix:** Extract Class, Introduce Parameter Object

---

## Object-Orientation Abusers

Misuse of object-oriented programming principles.

### Switch Statements

**Description:** Complex switch/case or if/else chains based on type codes.

**Why it's bad:**

- Hard to extend (must modify in multiple places)
- Violates Open/Closed Principle
- Often duplicated across methods

**Examples:**

```go
// BAD: Type-based switching
func GetPrice(product Product) float64 {
    switch product.Type {
    case "book":
        return product.BasePrice * 0.9
    case "electronics":
        return product.BasePrice * 1.1
    case "food":
        if product.IsPerishable {
            return product.BasePrice * 0.8
        }
        return product.BasePrice
    default:
        return product.BasePrice
    }
}

func GetShippingCost(product Product) float64 {
    switch product.Type {
    case "book":
        return 3.00
    case "electronics":
        return 10.00
    // ... same switch repeated
    }
}
```

**How to fix:** Replace Conditional with Polymorphism

### Temporary Field

**Description:** Field only has a value in certain circumstances.

**Why it's bad:**

- Confusing - why is field sometimes null?
- Wastes memory
- Often indicates missing abstraction

**Examples:**

```go
// BAD: totalTax only used during calculation
type Invoice struct {
    Items    []LineItem
    Customer Customer
    totalTax float64 // Only used temporarily
}

func (i *Invoice) Calculate() {
    i.totalTax = 0 // Reset each time
    for _, item := range i.Items {
        i.totalTax += item.Price * 0.08
    }
}
```

**How to fix:** Extract Class for the special case

### Refused Bequest

**Description:** Subclass uses only fraction of inherited methods.

**Why it's bad:**

- Violates Liskov Substitution Principle
- Incorrect inheritance hierarchy
- Misleading interface

**Examples:**

```go
// BAD: ReadOnlyList inherits but refuses methods
type List interface {
    Add(item interface{})
    Remove(item interface{})
    Get(index int) interface{}
}

type ReadOnlyList struct {
    items []interface{}
}

func (r *ReadOnlyList) Add(item interface{}) {
    panic("not supported") // Refusing inherited behavior
}

func (r *ReadOnlyList) Remove(item interface{}) {
    panic("not supported") // Refusing inherited behavior
}
```

**How to fix:** Replace Inheritance with Delegation

---

## Change Preventers

Code structures that make changes difficult.

### Divergent Change

**Description:** One class commonly changed for different reasons.

**Why it's bad:**

- Violates Single Responsibility Principle
- High risk of breaking unrelated functionality
- Many reasons for class to change

**Warning signs:**

- "When we add a new database, we change class X"
- "When we add a new report format, we change class X"
- "When we add a new validation, we change class X"

**Examples:**

```go
// BAD: Changes for different reasons
type ReportGenerator struct {
    db *Database
}

// Changes when database schema changes
func (r *ReportGenerator) FetchData() []Record { /* ... */ }

// Changes when report format changes
func (r *ReportGenerator) FormatAsHTML() string { /* ... */ }
func (r *ReportGenerator) FormatAsPDF() []byte { /* ... */ }

// Changes when business logic changes
func (r *ReportGenerator) CalculateTotals() Summary { /* ... */ }
```

**How to fix:** Extract Class (separate concerns)

### Shotgun Surgery

**Description:** Single change requires edits across many classes.

**Why it's bad:**

- Easy to miss changes
- High risk of bugs
- Slow to make changes
- Duplicated logic

**Examples:**

```go
// BAD: Adding new product type requires changes in 10 files
// file: pricing.go
func CalculatePrice(product Product) {
    if product.Type == "newtype" { /* ... */ }
}

// file: shipping.go  
func CalculateShipping(product Product) {
    if product.Type == "newtype" { /* ... */ }
}

// file: inventory.go
func UpdateInventory(product Product) {
    if product.Type == "newtype" { /* ... */ }
}

// ... 7 more files with similar changes
```

**How to fix:** Move Method, Move Field (consolidate related changes)

### Parallel Inheritance Hierarchies

**Description:** Creating subclass in one hierarchy requires creating subclass in another.

**Why it's bad:**

- Duplicated structure
- Easy to forget parallel change
- Hard to maintain consistency

**Examples:**

```go
// BAD: Must create parallel hierarchies
// Product hierarchy
type Product interface{}
type Book struct{}
type Electronics struct{}
type Food struct{}

// Must create matching hierarchy for UI
type ProductView interface{}
type BookView struct{}
type ElectronicsView struct{}
type FoodView struct{}

// Adding new product requires two new classes
```

**How to fix:** Move Method (eliminate parallel hierarchy)

---

## Dispensables

Unnecessary code that can be removed.

### Comments

**Description:** Excessive or unnecessary comments explaining bad code.

**Why it's bad:**

- Often explains WHAT instead of WHY
- Becomes outdated quickly
- Code should be self-documenting

**Examples:**

```go
// BAD: Comment explains bad code
// Loop through all customers and check if active
// and if balance is greater than 0 then add to list
for i := 0; i < len(customers); i++ {
    if customers[i].Status == "active" && customers[i].Balance > 0 {
        activeCustomers = append(activeCustomers, customers[i])
    }
}

// GOOD: Self-documenting code
for _, customer := range customers {
    if customer.IsActiveWithBalance() {
        activeCustomers = append(activeCustomers, customer)
    }
}
```

**How to fix:** Extract Method, Rename Variable, Improve Code

### Duplicate Code

**Description:** Same or very similar code in multiple places.

**Why it's bad:**

- Must update in multiple places
- Inconsistent behavior when one copy differs
- Harder to maintain
- Violates DRY principle

**Examples:**

```go
// BAD: Duplicated calculation
func ProcessOrderA(order Order) {
    tax := order.Subtotal * 0.08
    total := order.Subtotal + tax + order.Shipping
    // ...
}

func ProcessOrderB(order Order) {
    tax := order.Subtotal * 0.08
    total := order.Subtotal + tax + order.Shipping
    // ...
}
```

**Rule of Three:** When code appears 3+ times, refactor.

**How to fix:** Extract Method, Extract Class

### Dead Code

**Description:** Variables, functions, parameters, or code branches never used.

**Why it's bad:**

- Wastes space
- Confuses readers
- False sense of functionality
- Maintenance burden

**Examples:**

```go
// BAD: Unused parameter
func ProcessOrder(order Order, legacy string) { // legacy never used
    // ...
}

// BAD: Unreachable code
func Calculate(x int) int {
    if x > 0 {
        return x * 2
    }
    return 0

    // Everything below is unreachable
    fmt.Println("This never runs")
    return -1
}

// BAD: Unused function
func OldCalculation() {} // No references in codebase
```

**How to fix:** Delete it

### Lazy Class

**Description:** Class that doesn't do enough to justify its existence.

**Why it's bad:**

- Unnecessary abstraction
- Added complexity without benefit
- Extra file to navigate

**Examples:**

```go
// BAD: Class does almost nothing
type UserValidator struct{}

func (v UserValidator) Validate(user User) error {
    if user.Email == "" {
        return errors.New("email required")
    }
    return nil
}

// Better: Just a function
func ValidateUser(user User) error {
    if user.Email == "" {
        return errors.New("email required")
    }
    return nil
}
```

**How to fix:** Inline Class, Collapse Hierarchy

### Speculative Generality

**Description:** Code created for future use that isn't needed yet.

**Why it's bad:**

- Violates YAGNI (You Aren't Gonna Need It)
- Added complexity
- Hard to understand current requirements
- Future needs often differ from speculation

**Examples:**

```go
// BAD: Overgeneralized for "future use"
type DataStore interface {
    Save(data interface{}) error
    Load(id string) (interface{}, error)
    Delete(id string) error
    Query(filter interface{}) ([]interface{}, error)
    Backup() error
    Restore(backup interface{}) error
    Migrate(version int) error
    // ... 10 more methods we might need someday
}

// GOOD: Only what's actually used
type UserStore interface {
    SaveUser(user User) error
    GetUser(id string) (User, error)
}
```

**How to fix:** Remove unused abstractions

---

## Couplers

Code with excessive or inappropriate dependencies between classes.

### Feature Envy

**Description:** Method uses data/methods from another class more than its own.

**Why it's bad:**

- Poor cohesion
- Method in wrong place
- Increases coupling

**Examples:**

```go
// BAD: InvoiceCalculator envies Order's data
type InvoiceCalculator struct{}

func (c *InvoiceCalculator) CalculateTotal(order *Order) float64 {
    // Uses all Order's data, none of its own
    subtotal := 0.0
    for _, item := range order.Items {
        subtotal += item.Price * float64(item.Quantity)
    }
    tax := subtotal * order.TaxRate
    return subtotal + tax + order.ShippingCost
}

// GOOD: Method belongs on Order
func (o *Order) CalculateTotal() float64 {
    subtotal := o.calculateSubtotal()
    tax := subtotal * o.TaxRate
    return subtotal + tax + o.ShippingCost
}
```

**How to fix:** Move Method

### Inappropriate Intimacy

**Description:** Classes too coupled to each other's internal details.

**Why it's bad:**

- High coupling
- Changes cascade
- Hard to reuse independently

**Examples:**

```go
// BAD: Classes know too much about each other
type Order struct {
    Items []LineItem
}

type Invoice struct {
    order *Order
}

func (i *Invoice) Calculate() {
    // Directly accessing Order's internals
    for _, item := range i.order.Items {
        // Knows LineItem's internal structure
        price := item.basePrice * item.markup
        // ...
    }
}
```

**How to fix:** Move Method, Extract Class, Hide Delegate

### Message Chains

**Description:** Client asks one object for another, which asks another, etc.

**Why it's bad:**

- High coupling to intermediate objects
- Changes to chain break client
- Violates Law of Demeter

**Examples:**

```go
// BAD: Long message chain
manager := employee.GetDepartment().GetManager()
managerEmail := employee.GetDepartment().GetManager().GetContact().GetEmail()

// Client depends on Employee, Department, Manager, Contact
// Change to any intermediate breaks this code
```

**Law of Demeter:** Only talk to immediate friends.

**How to fix:** Hide Delegate

```go
// GOOD: Hide the chain
func (e *Employee) GetManagerEmail() string {
    return e.department.manager.contact.email
}

managerEmail := employee.GetManagerEmail()
```

### Middle Man

**Description:** Class that mostly delegates to another class.

**Why it's bad:**

- Unnecessary indirection
- Extra layer without benefit
- Harder to understand call flow

**Examples:**

```go
// BAD: Manager just delegates everything
type PersonManager struct {
    person *Person
}

func (m *PersonManager) GetName() string {
    return m.person.Name
}

func (m *PersonManager) GetAge() int {
    return m.person.Age
}

func (m *PersonManager) GetEmail() string {
    return m.person.Email
}

// Just use Person directly!
```

**How to fix:** Remove Middle Man, Inline Method

---

## Detection Strategy

When reviewing code, scan for these smells in order:

1. **Bloaters** (easiest to spot - large methods/classes)
2. **Dispensables** (dead code, duplication)
3. **Couplers** (inappropriate dependencies)
4. **Change Preventers** (shotgun surgery, divergent change)
5. **OOP Abusers** (switch statements, refused bequest)

## Prioritization

Fix smells in this order:

1. **Dead Code** - Delete immediately (zero risk)
2. **Duplicate Code** - High impact, usually safe to fix
3. **Long Method** - Break into smaller pieces
4. **Feature Envy** - Move methods to right place
5. **Large Class** - Extract responsibilities (higher effort)

## Resources

- Refactoring: Improving the Design of Existing Code (Martin Fowler)
- <https://refactoring.guru/refactoring/smells>
- Clean Code (Robert C. Martin)
