---
title: Documentation Best Practices
impact: MEDIUM
impactDescription: Improves code discoverability and maintainability
tags: documentation, comments, godoc, clarity
---

## Documentation Best Practices

Write documentation that explains "why", not "what". Good documentation helps
future maintainers (including future you) understand the reasoning behind code
decisions.

### Package Documentation

Every package should have a package comment that describes its purpose.

**Correct:**

```go
// Package auth provides authentication and authorization services.
// It supports JWT tokens, OAuth2 flows, and API key validation.
//
// Basic usage:
//
//     authenticator := auth.New(config)
//     token, err := authenticator.Authenticate(credentials)
//
package auth
```

**Key points:**

- Place comment directly before `package` declaration
- Start with "Package \<name\>"
- Explain what the package does
- Show basic usage example if helpful
- Use blank comment lines for paragraphs

**Incorrect:**

```go
// auth package
package auth

// Or too minimal
// Package auth
package auth

// Or no package comment at all
package auth
```

### Function Documentation

Document exported functions with comments that explain what they do and, when
necessary, why.

**Correct:**

```go
// ProcessPayment processes a payment transaction for the given amount.
// It validates the payment method, charges the account, and records
// the transaction in the ledger.
//
// Returns an error if the payment fails or if the amount is invalid.
func ProcessPayment(amount int, method PaymentMethod) error {
    // Implementation...
}

// Connect establishes a connection to the server.
// It retries up to 3 times with exponential backoff because
// the server occasionally drops initial connections under load.
func Connect(addr string) error {
    // Implementation...
}
```

**Key points:**

- Start with function name
- Explain what the function does
- Document parameters if not obvious
- Document return values, especially errors
- Explain "why" for non-obvious decisions

**Incorrect:**

```go
// This function processes payment
func ProcessPayment(amount int, method PaymentMethod) error {
    // ...
}

// Process payment
func ProcessPayment(amount int, method PaymentMethod) error {
    // ...
}
```

### Type Documentation

**Correct:**

```go
// User represents a user account in the system.
// It contains authentication credentials and profile information.
type User struct {
    ID       string
    Email    string
    Password string  // bcrypt hashed
}

// Config holds application configuration.
// All fields are required unless marked optional.
type Config struct {
    // Port is the HTTP server port (default: 8080)
    Port int

    // DBUrl is the database connection string
    DBUrl string

    // Debug enables verbose logging (optional)
    Debug bool
}
```

**Key points:**

- Explain what the type represents
- Document non-obvious field meanings
- Note field constraints or defaults
- Explain relationships to other types

### Comments Explain "Why", Not "What"

The code itself shows "what" is happening. Comments should explain "why" it's
done that way.

**Correct (explains rationale):**

```go
// Retry up to 3 times because the API occasionally returns transient errors
// that resolve on subsequent requests.
for i := 0; i < 3; i++ {
    if err := callAPI(); err == nil {
        break
    }
    time.Sleep(time.Second)
}

// We use a buffered channel here to avoid blocking the sender
// when the receiver is temporarily busy processing.
messages := make(chan Message, 100)

// Read in chunks of 4KB because larger reads don't improve performance
// on our typical file sizes (see benchmark in PR #123).
buffer := make([]byte, 4096)
```

**Incorrect (restates obvious code):**

```go
// Loop 3 times
for i := 0; i < 3; i++ {
    // Call API
    if err := callAPI(); err == nil {
        // Break if no error
        break
    }
    // Sleep for 1 second
    time.Sleep(time.Second)
}

// Make a buffered channel with capacity 100
messages := make(chan Message, 100)

// Create a buffer of 4096 bytes
buffer := make([]byte, 4096)
```

### When to Add Comments

**Add comments when:**

- Explaining non-obvious decisions or trade-offs
- Warning about gotchas or limitations
- Documenting performance considerations
- Explaining business logic or domain rules
- Referencing external resources (RFCs, tickets, docs)

**Don't comment when:**

- The code is self-explanatory
- You can make code clearer instead
- Restating what the code obviously does

**Good use of comments:**

```go
// Users with admin role bypass rate limiting because admins
// need unrestricted access for operational tasks (see POLICY-123).
if user.Role == RoleAdmin {
    return true
}

// We can't use sync.Map here because we need to iterate in
// insertion order, and sync.Map doesn't guarantee ordering.
cache := make(map[string]*Entry)
```

**Bad use of comments:**

```go
// Check if user is admin
if user.Role == RoleAdmin {
    // Return true
    return true
}

// Create a map
cache := make(map[string]*Entry)
```

### Documentation for Exported Identifiers

All exported (public) identifiers should have documentation:

- Types
- Functions
- Methods
- Constants
- Variables

**Correct:**

```go
// DefaultTimeout is the default timeout for HTTP requests.
const DefaultTimeout = 30 * time.Second

// ErrNotFound is returned when the requested resource doesn't exist.
var ErrNotFound = errors.New("not found")

// Client is an HTTP client for the API.
type Client struct {
    baseURL string
}

// Get retrieves a resource by ID.
func (c *Client) Get(id string) (*Resource, error) {
    // ...
}
```

**Note:** Unexported identifiers generally don't need documentation comments
unless the implementation is complex or non-obvious.

### Example Functions

Use example functions for executable documentation:

```go
// Example function shows up in godoc
func ExampleSum() {
    result := sum(2, 3)
    fmt.Println(result)
    // Output: 5
}

func ExampleUser_String() {
    u := &User{Name: "Alice", Age: 30}
    fmt.Println(u)
    // Output: Alice (30)
}
```

Example functions run as tests and verify the output matches the "Output:"
comment.
