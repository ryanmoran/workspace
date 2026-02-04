# Refactoring Techniques Reference

Detailed guide for common refactoring techniques with Go examples.

## Categories

1. [Composing Methods](#composing-methods) - Streamlining methods
2. [Moving Features](#moving-features) - Moving functionality between objects
3. [Organizing Data](#organizing-data) - Improving data handling
4. [Simplifying Conditionals](#simplifying-conditionals) - Making logic clearer
5. [Simplifying Method Calls](#simplifying-method-calls) - Better interfaces
6. [Dealing with Generalization](#dealing-with-generalization) - Managing inheritance

---

## Composing Methods

Techniques for improving method structure and reducing complexity.

### Extract Method

**Problem:** Code fragment that can be grouped together.

**Solution:** Move fragment into separate method with descriptive name.

**Benefits:**

- Improved readability
- Reduced duplication
- Easier testing
- Self-documenting code

**Before:**

```go
func PrintOwing(invoice Invoice) {
    fmt.Println("***********************")
    fmt.Println("***** Invoice *****")
    fmt.Println("***********************")

    // Print details
    fmt.Printf("Name: %s\n", invoice.Customer)
    fmt.Printf("Amount: %.2f\n", invoice.Amount)

    // Calculate outstanding
    outstanding := 0.0
    for _, order := range invoice.Orders {
        outstanding += order.Amount
    }

    fmt.Printf("Outstanding: %.2f\n", outstanding)
}
```

**After:**

```go
func PrintOwing(invoice Invoice) {
    printBanner()
    printDetails(invoice)
    printOutstanding(invoice)
}

func printBanner() {
    fmt.Println("***********************")
    fmt.Println("***** Invoice *****")
    fmt.Println("***********************")
}

func printDetails(invoice Invoice) {
    fmt.Printf("Name: %s\n", invoice.Customer)
    fmt.Printf("Amount: %.2f\n", invoice.Amount)
}

func printOutstanding(invoice Invoice) {
    outstanding := calculateOutstanding(invoice)
    fmt.Printf("Outstanding: %.2f\n", outstanding)
}

func calculateOutstanding(invoice Invoice) float64 {
    outstanding := 0.0
    for _, order := range invoice.Orders {
        outstanding += order.Amount
    }
    return outstanding
}
```

**When to use:**

- Method is too long (>20 lines)
- Comments needed to explain code section
- Code can be reused elsewhere

### Inline Method

**Problem:** Method body is more obvious than the method name.

**Solution:** Replace method calls with method body.

**Benefits:**

- Removes unnecessary indirection
- Simplifies code flow
- Easier to understand

**Before:**

```go
func GetRating(driver Driver) int {
    return moreThanFiveLateDeliveries(driver) ? 2 : 1
}

func moreThanFiveLateDeliveries(driver Driver) bool {
    return driver.LateDeliveries > 5
}
```

**After:**

```go
func GetRating(driver Driver) int {
    if driver.LateDeliveries > 5 {
        return 2
    }
    return 1
}
```

**When to use:**

- Method does almost nothing
- Method is only called once
- Indirection adds no value

### Replace Temp with Query

**Problem:** Temporary variable holding result of expression.

**Solution:** Extract expression into method, replace temp with method call.

**Benefits:**

- Can reuse calculation
- Clearer intent
- Encourages extraction of complex logic

**Before:**

```go
func CalculateTotal(order Order) float64 {
    basePrice := order.Quantity * order.ItemPrice

    if basePrice > 1000 {
        return basePrice * 0.95
    }
    return basePrice * 0.98
}
```

**After:**

```go
func CalculateTotal(order Order) float64 {
    if basePrice(order) > 1000 {
        return basePrice(order) * 0.95
    }
    return basePrice(order) * 0.98
}

func basePrice(order Order) float64 {
    return order.Quantity * order.ItemPrice
}
```

**When to use:**

- Temp used multiple times
- Complex expression
- Expression could be used elsewhere

### Decompose Conditional

**Problem:** Complex conditional (if/then/else).

**Solution:** Extract condition and branches into separate methods.

**Benefits:**

- Clarifies intent of condition
- More readable
- Easier to modify logic

**Before:**

```go
func GetCharge(user User, date time.Time) float64 {
    if date.Before(summerStart) || date.After(summerEnd) {
        return user.Quantity * user.WinterRate + user.WinterServiceCharge
    }
    return user.Quantity * user.SummerRate
}
```

**After:**

```go
func GetCharge(user User, date time.Time) float64 {
    if isWinter(date) {
        return winterCharge(user)
    }
    return summerCharge(user)
}

func isWinter(date time.Time) bool {
    return date.Before(summerStart) || date.After(summerEnd)
}

func winterCharge(user User) float64 {
    return user.Quantity * user.WinterRate + user.WinterServiceCharge
}

func summerCharge(user User) float64 {
    return user.Quantity * user.SummerRate
}
```

---

## Moving Features

Techniques for moving functionality between objects.

### Move Method

**Problem:** Method uses features of another class more than its own.

**Solution:** Create new method in the class it uses most, delegate or remove old method.

**Benefits:**

- Better cohesion
- Clearer responsibilities
- Reduced coupling

**Before:**

```go
type Account struct {
    DaysOverdrawn int
    Type          AccountType
}

type AccountType struct {
    OverdraftCharge float64
}

// BankCharge uses Account's data but belongs elsewhere
type BankCharge struct{}

func (b BankCharge) CalculateOverdraftFee(account Account) float64 {
    if account.Type.isPremium() {
        result := 10 + (account.DaysOverdrawn - 7) * 0.85
        if result < 0 {
            return 0
        }
        return result
    }
    return account.DaysOverdrawn * 1.75
}
```

**After:**

```go
type Account struct {
    DaysOverdrawn int
    Type          AccountType
}

func (a Account) CalculateOverdraftFee() float64 {
    return a.Type.overdraftFee(a.DaysOverdrawn)
}

type AccountType struct {
    OverdraftCharge float64
}

func (t AccountType) overdraftFee(daysOverdrawn int) float64 {
    if t.isPremium() {
        result := 10 + (daysOverdrawn - 7) * 0.85
        if result < 0 {
            return 0
        }
        return result
    }
    return daysOverdrawn * 1.75
}
```

### Extract Class

**Problem:** Class doing work of two or more classes.

**Solution:** Create new class and move relevant fields and methods.

**Benefits:**

- Single Responsibility Principle
- Easier to understand
- Better testability

**Before:**

```go
type Person struct {
    Name            string
    OfficeAreaCode  string
    OfficeNumber    string
}

func (p Person) GetTelephoneNumber() string {
    return fmt.Sprintf("(%s) %s", p.OfficeAreaCode, p.OfficeNumber)
}
```

**After:**

```go
type Person struct {
    Name  string
    Phone TelephoneNumber
}

type TelephoneNumber struct {
    AreaCode string
    Number   string
}

func (t TelephoneNumber) String() string {
    return fmt.Sprintf("(%s) %s", t.AreaCode, t.Number)
}

func (p Person) GetTelephoneNumber() string {
    return p.Phone.String()
}
```

**When to use:**

- Class has subset of data used only in some methods
- Subset of data that changes together
- Class too large or complex

### Hide Delegate

**Problem:** Client calls delegate object via another object.

**Solution:** Create method on server object that hides the delegate.

**Benefits:**

- Reduces coupling
- Easier to change delegate
- Simplifies client code

**Before:**

```go
type Person struct {
    Department *Department
}

type Department struct {
    Manager *Person
}

// Client code
manager := john.Department.Manager
```

**After:**

```go
type Person struct {
    department *Department
}

func (p *Person) GetManager() *Person {
    return p.department.Manager
}

type Department struct {
    Manager *Person
}

// Client code
manager := john.GetManager()
```

---

## Organizing Data

Techniques for improving data representation.

### Replace Data Value with Object

**Problem:** Data item needs additional data or behavior.

**Solution:** Turn data item into object.

**Benefits:**

- Encapsulates related data
- Type safety
- Centralized validation
- Prevents duplication

**Before:**

```go
type Order struct {
    Customer string // Just a string
}

// Validation scattered
func IsValidCustomer(name string) bool {
    return len(name) > 0
}
```

**After:**

```go
type Order struct {
    Customer Customer
}

type Customer struct {
    name string
}

func NewCustomer(name string) (Customer, error) {
    if len(name) == 0 {
        return Customer{}, errors.New("name required")
    }
    return Customer{name: name}, nil
}

func (c Customer) Name() string {
    return c.name
}
```

**When to use:**

- Simple data item needs validation
- Additional data logically grouped
- Need to add behavior to data

### Encapsulate Field

**Problem:** Public field directly accessed.

**Solution:** Make field private, provide accessors.

**Benefits:**

- Control access
- Can add validation
- Can change implementation
- Better encapsulation

**Before:**

```go
type Person struct {
    Name string // Public
}

// Direct access
person.Name = "John"
```

**After:**

```go
type Person struct {
    name string // Private
}

func (p *Person) Name() string {
    return p.name
}

func (p *Person) SetName(name string) error {
    if len(name) == 0 {
        return errors.New("name required")
    }
    p.name = name
    return nil
}
```

### Replace Type Code with Class

**Problem:** Class has field with type code that affects behavior.

**Solution:** Replace type code with class or enum.

**Benefits:**

- Type safety
- Prevents invalid values
- Can attach behavior
- Clearer intent

**Before:**

```go
type Employee struct {
    Name string
    Type int // 0=engineer, 1=salesman, 2=manager
}

const (
    Engineer  = 0
    Salesman  = 1
    Manager   = 2
)
```

**After:**

```go
type Employee struct {
    Name string
    Type EmployeeType
}

type EmployeeType int

const (
    Engineer EmployeeType = iota
    Salesman
    Manager
)

func (e EmployeeType) String() string {
    return [...]string{"Engineer", "Salesman", "Manager"}[e]
}

func (e EmployeeType) IsValid() bool {
    return e >= Engineer && e <= Manager
}
```

---

## Simplifying Conditionals

Techniques for making conditional logic clearer.

### Replace Conditional with Polymorphism

**Problem:** Conditional changes behavior based on object type.

**Solution:** Move each branch to overriding method in subclass/implementation.

**Benefits:**

- Open/Closed Principle
- Easier to extend
- Eliminates type checking
- Clearer responsibilities

**Before:**

```go
type Bird struct {
    Type string
}

func (b Bird) GetSpeed() float64 {
    switch b.Type {
    case "European":
        return getBaseSpeed()
    case "African":
        return getBaseSpeed() - getLoadFactor() * b.numberOfCoconuts
    case "Norwegian":
        return (b.isNailed) ? 0 : getBaseSpeed() * b.voltage / 10
    }
    return 0
}
```

**After:**

```go
type Bird interface {
    GetSpeed() float64
}

type European struct{}

func (e European) GetSpeed() float64 {
    return getBaseSpeed()
}

type African struct {
    numberOfCoconuts int
}

func (a African) GetSpeed() float64 {
    return getBaseSpeed() - getLoadFactor() * float64(a.numberOfCoconuts)
}

type Norwegian struct {
    isNailed bool
    voltage  float64
}

func (n Norwegian) GetSpeed() float64 {
    if n.isNailed {
        return 0
    }
    return getBaseSpeed() * n.voltage / 10
}
```

### Consolidate Conditional Expression

**Problem:** Multiple conditionals with same result.

**Solution:** Combine into single expression and extract.

**Benefits:**

- Clearer intent
- Easier to understand logic
- Simpler to modify

**Before:**

```go
func DisabilityAmount(employee Employee) float64 {
    if employee.Seniority < 2 {
        return 0
    }
    if employee.MonthsDisabled > 12 {
        return 0
    }
    if employee.IsPartTime {
        return 0
    }
    // Calculate disability amount
    return calculateDisability(employee)
}
```

**After:**

```go
func DisabilityAmount(employee Employee) float64 {
    if isNotEligibleForDisability(employee) {
        return 0
    }
    return calculateDisability(employee)
}

func isNotEligibleForDisability(employee Employee) bool {
    return employee.Seniority < 2 ||
           employee.MonthsDisabled > 12 ||
           employee.IsPartTime
}
```

### Replace Nested Conditional with Guard Clauses

**Problem:** Nested conditionals obscure normal flow.

**Solution:** Use guard clauses for special cases.

**Benefits:**

- Clearer normal flow
- Less nesting
- Easier to read

**Before:**

```go
func GetPayAmount(employee Employee) float64 {
    var result float64

    if employee.IsSeparated {
        result = 0
    } else {
        if employee.IsRetired {
            result = 0
        } else {
            // Normal calculation
            result = employee.Salary
        }
    }

    return result
}
```

**After:**

```go
func GetPayAmount(employee Employee) float64 {
    if employee.IsSeparated {
        return 0
    }
    if employee.IsRetired {
        return 0
    }

    // Normal calculation
    return employee.Salary
}
```

### Introduce Null Object

**Problem:** Repeated null checks throughout code.

**Solution:** Replace null with null object that provides default behavior.

**Benefits:**

- Eliminates null checks
- Safer code
- Clearer intent

**Before:**

```go
type Customer struct {
    Name string
    Plan *BillingPlan
}

func GetBillingAmount(customer Customer) float64 {
    if customer.Plan != nil {
        return customer.Plan.Amount
    }
    return 0 // Default for null
}

func GetPlanName(customer Customer) string {
    if customer.Plan != nil {
        return customer.Plan.Name
    }
    return "No Plan" // Default for null
}
```

**After:**

```go
type BillingPlan interface {
    Amount() float64
    Name() string
}

type RealPlan struct {
    amount float64
    name   string
}

func (r RealPlan) Amount() float64 { return r.amount }
func (r RealPlan) Name() string    { return r.name }

type NullPlan struct{}

func (n NullPlan) Amount() float64 { return 0 }
func (n NullPlan) Name() string    { return "No Plan" }

type Customer struct {
    Name string
    Plan BillingPlan // Never nil
}

// No null checks needed
func GetBillingAmount(customer Customer) float64 {
    return customer.Plan.Amount()
}

func GetPlanName(customer Customer) string {
    return customer.Plan.Name()
}
```

---

## Simplifying Method Calls

Techniques for making interfaces cleaner.

### Rename Method

**Problem:** Method name doesn't reveal its purpose.

**Solution:** Rename the method.

**Benefits:**

- Self-documenting code
- Clearer intent
- Better readability

**Before:**

```go
func (c Customer) gm() string { // What does 'gm' mean?
    return c.Manager
}
```

**After:**

```go
func (c Customer) GetManager() string {
    return c.Manager
}
```

### Add Parameter

**Problem:** Method needs more information from caller.

**Solution:** Add parameter for needed object.

**Before:**

```go
func GetContact() Contact {
    // Assumes specific contact
}
```

**After:**

```go
func GetContact(contactID string) Contact {
    // Can get any contact
}
```

### Remove Parameter

**Problem:** Parameter no longer used by method body.

**Solution:** Remove the parameter.

**Benefits:**

- Simpler interface
- Fewer dependencies
- Easier to call

**Before:**

```go
func CreateOrder(customer Customer, date time.Time) Order {
    // date is never used
    return Order{Customer: customer}
}
```

**After:**

```go
func CreateOrder(customer Customer) Order {
    return Order{Customer: customer}
}
```

### Introduce Parameter Object

**Problem:** Methods with same group of parameters.

**Solution:** Replace parameters with object.

**Benefits:**

- Clearer intent
- Shorter parameter lists
- Can add behavior to object

**Before:**

```go
func AmountInvoiced(start, end time.Time, customer Customer) float64 { /* ... */ }
func AmountReceived(start, end time.Time, customer Customer) float64 { /* ... */ }
func AmountOverdue(start, end time.Time, customer Customer) float64 { /* ... */ }
```

**After:**

```go
type DateRange struct {
    Start time.Time
    End   time.Time
}

func AmountInvoiced(range DateRange, customer Customer) float64 { /* ... */ }
func AmountReceived(range DateRange, customer Customer) float64 { /* ... */ }
func AmountOverdue(range DateRange, customer Customer) float64 { /* ... */ }
```

### Separate Query from Modifier

**Problem:** Method returns value and changes state.

**Solution:** Split into two methods - one query, one modifier.

**Benefits:**

- Clearer semantics
- Easier to reason about
- Can query without side effects

**Before:**

```go
func (c *Cache) GetOrCreate(key string) Value {
    if val, ok := c.data[key]; ok {
        return val
    }

    // Side effect: modifies cache
    val := createDefault()
    c.data[key] = val
    return val
}
```

**After:**

```go
func (c *Cache) Get(key string) (Value, bool) {
    val, ok := c.data[key]
    return val, ok
}

func (c *Cache) Create(key string) Value {
    val := createDefault()
    c.data[key] = val
    return val
}

// Client decides
val, ok := cache.Get(key)
if !ok {
    val = cache.Create(key)
}
```

---

## Dealing with Generalization

Techniques for managing inheritance and abstraction.

### Pull Up Method

**Problem:** Methods in subclasses do the same thing.

**Solution:** Move method to superclass.

**Benefits:**

- Eliminates duplication
- Centralizes logic
- Easier to maintain

**Before:**

```go
type Employee interface {
    GetSalary() float64
}

type Engineer struct {
    monthlySalary float64
}

func (e Engineer) GetSalary() float64 {
    return e.monthlySalary
}

type Salesman struct {
    monthlySalary float64
}

func (s Salesman) GetSalary() float64 {
    return s.monthlySalary // Same implementation!
}
```

**After:**

```go
type Employee struct {
    monthlySalary float64
}

func (e Employee) GetSalary() float64 {
    return e.monthlySalary
}

type Engineer struct {
    Employee
}

type Salesman struct {
    Employee
}
```

### Push Down Method

**Problem:** Behavior in superclass only relevant to some subclasses.

**Solution:** Move method to those subclasses.

**Benefits:**

- Clearer class purpose
- No irrelevant methods
- Better interface segregation

**Before:**

```go
type Employee struct{}

func (e Employee) GetQuota() int {
    return 100 // Only makes sense for salesmen
}

type Engineer struct{ Employee }
type Salesman struct{ Employee }
```

**After:**

```go
type Employee struct{}

type Engineer struct{ Employee }
// No GetQuota - doesn't make sense

type Salesman struct{ Employee }

func (s Salesman) GetQuota() int {
    return 100
}
```

### Extract Interface

**Problem:** Multiple clients use same subset of class's interface.

**Solution:** Move subset to separate interface.

**Benefits:**

- Clearer dependencies
- Better testability (can mock)
- Interface segregation

**Before:**

```go
type TimeSheet struct {
    // Many methods
}

func (t TimeSheet) GetHours() float64 { /* ... */ }
func (t TimeSheet) Submit() error { /* ... */ }
func (t TimeSheet) Approve() error { /* ... */ }
func (t TimeSheet) GenerateReport() Report { /* ... */ }

// Client only needs hours
func CalculatePay(ts TimeSheet) float64 {
    return ts.GetHours() * hourlyRate
}
```

**After:**

```go
type HourTracker interface {
    GetHours() float64
}

type TimeSheet struct {
    // Many methods
}

func (t TimeSheet) GetHours() float64 { /* ... */ }
func (t TimeSheet) Submit() error { /* ... */ }
func (t TimeSheet) Approve() error { /* ... */ }
func (t TimeSheet) GenerateReport() Report { /* ... */ }

// Client only depends on interface
func CalculatePay(ht HourTracker) float64 {
    return ht.GetHours() * hourlyRate
}
```

### Replace Inheritance with Delegation

**Problem:** Subclass uses only part of superclass interface or doesn't want to inherit data.

**Solution:** Create field for superclass, delegate methods, remove inheritance.

**Benefits:**

- More flexible
- Can change delegate at runtime
- Clearer intent

**Before:**

```go
type Stack struct {
    ArrayList // Inherits everything
}

// Problem: Inherits methods that break Stack semantics
// client can call stack.Get(5) which violates LIFO
```

**After:**

```go
type Stack struct {
    list ArrayList // Delegation
}

func (s *Stack) Push(item interface{}) {
    s.list.Add(item)
}

func (s *Stack) Pop() interface{} {
    return s.list.RemoveLast()
}

// Only exposes Stack-appropriate methods
```

---

## Refactoring Workflow

### Safe Refactoring Steps

For any technique:

1. **Ensure tests exist and pass**
2. **Make one change**
3. **Run tests**
4. **Commit if green**
5. **Repeat**

### When to Use Each Technique

| Smell | Technique |
|-------|-----------|
| Long Method | Extract Method |
| Large Class | Extract Class |
| Duplicate Code | Extract Method, Pull Up Method |
| Long Parameter List | Introduce Parameter Object |
| Feature Envy | Move Method |
| Switch Statements | Replace Conditional with Polymorphism |
| Primitive Obsession | Replace Data Value with Object |
| Message Chains | Hide Delegate |
| Middle Man | Remove Middle Man, Inline Method |
| Temporary Field | Extract Class |

### Testing After Refactoring

After applying technique, verify:

- [ ] All tests pass
- [ ] No new lint warnings
- [ ] Code is more readable
- [ ] Responsibilities clearer
- [ ] No behavior change

---

## Resources

- Refactoring: Improving the Design of Existing Code (Martin Fowler)
- <https://refactoring.guru/refactoring/techniques>
- Clean Code (Robert C. Martin)
