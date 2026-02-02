---
name: go-style-guide
description: Google Go Style Guide for writing clear, idiomatic, and maintainable Go code. Use this skill when writing, reviewing, or refactoring Go code to ensure adherence to Google's best practices. Triggers on tasks involving Go packages, functions, error handling, testing, naming, or performance optimization.
---

# Google Go Style Guide

Comprehensive style guide for Go programming based on Google's engineering standards. Emphasizes clarity, simplicity, and maintainability through proven patterns and idioms.

## When to Apply

Reference these guidelines when:

- Writing new Go packages, functions, or types
- Reviewing Go code for style and idiom compliance
- Refactoring existing Go codebases
- Designing APIs and package interfaces
- Handling errors or writing tests
- Making naming or formatting decisions

## Core Principles (In Priority Order)

The Go Style Guide is built on five fundamental principles that should guide all decisions:

1. **Clarity** - Code's purpose and rationale must be clear to readers
2. **Simplicity** - Write code in the simplest way possible
3. **Concision** - Maintain high signal-to-noise ratio
4. **Maintainability** - Design code for future modifications
5. **Consistency** - Follow consistent patterns across the codebase

When style choices conflict, prioritize based on this ordering.

## Quick Reference by Category

| Category | Priority | Key Focus |
|----------|----------|-----------|
| Formatting | CRITICAL | Use `gofmt` always |
| Naming | CRITICAL | MixedCaps, context-aware, concise |
| Error Handling | HIGH | Explicit, idiomatic patterns |
| Package Design | HIGH | Minimal dependencies, focused responsibility |
| Testing | HIGH | Table-driven, comprehensive |
| Documentation | MEDIUM | Explain "why", not "what" |
| Interfaces | MEDIUM | Use sparingly, clear contracts |
| Concurrency | MEDIUM | Idiomatic channels/goroutines |
| Performance | LOW | Optimize deliberately when needed |

## Detailed Guidelines

### 1. Formatting (CRITICAL)

**Always use `gofmt`**

- All Go source files must conform to `gofmt` output
- No exceptions - this ensures universal consistency
- Configure your editor to run `gofmt` on save

**Line Length**

- No fixed line length restriction
- Prefer refactoring over artificial line splitting
- Avoid splitting lines before indentation changes
- Let code naturally flow; break only when it improves readability

**Example:**

```go
// Good - natural flow
if err := processLongFunctionName(context, parameter1, parameter2, parameter3); err != nil {
    return fmt.Errorf("processing failed: %w", err)
}

// Avoid - artificial splitting that doesn't help readability
if err := processLongFunctionName(context, parameter1,
    parameter2, parameter3); err != nil {
    return fmt.Errorf("processing failed: %w", err)
}
```

### 2. Naming (CRITICAL)

**General Rules**

- Use `MixedCaps` or `mixedCaps` (camel case) - never underscores
- Keep names concise and context-aware
- Avoid stuttering (redundant package name repetition)
- Shorter names for smaller scopes, longer names for larger scopes

**Constants**

```go
// Exported constants
const MaxRetries = 3
const DefaultTimeout = 30 * time.Second

// Unexported constants
const bufferSize = 1024
const maxConnections = 100
```

**Variables**

```go
// Good - concise, clear in context
var count int
var users []*User
var mu sync.Mutex

// Avoid - redundant prefixes/suffixes
var userCount int       // if "count" is obviously for users
var userSlice []*User   // type is already clear
var userMutex sync.Mutex
```

**Functions and Methods**

```go
// Good - action-oriented, clear intent
func ProcessPayment(amount int) error
func (c *Client) Connect() error
func validateEmail(email string) bool

// Avoid - redundant type information
func ProcessPaymentAmount(amount int) error  // "Amount" is redundant
func (c *Client) ConnectClient() error       // "Client" is redundant
```

**Package Names**

- Short, single-word, lowercase
- No underscores or mixed caps
- Avoid generic names like `util`, `common`, `base`

```go
// Good
package auth
package httputil
package ioutil

// Avoid
package authentication  // too long
package http_util      // underscores
package utils          // too generic
```

**Avoid Stuttering**

```go
// Good
auth.Token          // not auth.AuthToken
user.Service        // not user.UserService
http.Client         // not http.HTTPClient

// In implementation
package user

type Service struct { ... }  // Becomes user.Service, not user.UserService
```

### 3. Error Handling (HIGH)

**Always Check Errors Explicitly**

```go
// Good - explicit error checking
if err := doSomething(); err != nil {
    return fmt.Errorf("operation failed: %w", err)
}

// Avoid - ignoring errors
_ = doSomething()
doSomething()
```

**Error Wrapping**

- Use `%w` verb with `fmt.Errorf` to wrap errors
- Preserve error chains for debugging
- Add context at each layer

```go
// Good - wrapping with context
func processUser(id int) error {
    user, err := fetchUser(id)
    if err != nil {
        return fmt.Errorf("process user %d: %w", id, err)
    }
    // ...
}

// Avoid - losing error context
func processUser(id int) error {
    user, err := fetchUser(id)
    if err != nil {
        return err  // loses context about what operation failed
    }
    // ...
}
```

**Error Variables and Types**

- Define sentinel errors as package-level variables
- Use custom error types for rich error information

```go
// Sentinel errors
var (
    ErrNotFound = errors.New("resource not found")
    ErrUnauthorized = errors.New("unauthorized access")
)

// Custom error type
type ValidationError struct {
    Field string
    Err   error
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation failed for %s: %v", e.Field, e.Err)
}
```

**Idiomatic Error Handling Patterns**

```go
// Pattern 1: Early return
func process(data []byte) error {
    if len(data) == 0 {
        return errors.New("empty data")
    }
    // Continue with valid data
}

// Pattern 2: Error variable reuse in sequence
func multiStep() error {
    var err error
    if err = step1(); err != nil {
        return err
    }
    if err = step2(); err != nil {
        return err
    }
    return nil
}

// Pattern 3: Initialize and check in if statement
if err := validate(input); err != nil {
    return err
}
```

### 4. Package Design (HIGH)

**Focused Responsibility**

- Each package should have a single, clear purpose
- Avoid "god packages" that do everything
- Group related functionality together

**Minimize Dependencies**

- Depend on as few packages as possible
- Avoid circular dependencies
- Consider interfaces to break dependencies

**Package Organization**

```go
// Good package structure
myapp/
  cmd/           // Command-line applications
    myapp/
      main.go
  internal/      // Private application code
    auth/        // Authentication logic
    storage/     // Data persistence
  pkg/           // Public library code
    client/      // Client library
  api/           // API definitions (proto, OpenAPI)

// Each package has clear, non-overlapping responsibility
```

**Avoid Feature Packages Before Use**

- Don't create packages for features that don't exist yet
- Don't over-engineer early abstractions
- Let package structure emerge from real needs

```go
// Avoid - premature abstraction
package cache  // Created but not used yet
package queue  // "We might need this later"

// Good - create when actually needed
// Start with simple code, extract package when complexity justifies it
```

### 5. Testing (HIGH)

**Table-Driven Tests**

- Use table-driven tests for comprehensive coverage
- Makes adding test cases trivial
- Clearly shows all scenarios

```go
func TestValidateEmail(t *testing.T) {
    tests := []struct {
        name    string
        email   string
        wantErr bool
    }{
        {
            name:    "valid email",
            email:   "user@example.com",
            wantErr: false,
        },
        {
            name:    "missing @",
            email:   "userexample.com",
            wantErr: true,
        },
        {
            name:    "missing domain",
            email:   "user@",
            wantErr: true,
        },
        {
            name:    "empty string",
            email:   "",
            wantErr: true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := validateEmail(tt.email)
            if (err != nil) != tt.wantErr {
                t.Errorf("validateEmail() error = %v, wantErr %v", err, tt.wantErr)
            }
        })
    }
}
```

**Test Naming**

- Test function: `TestFunctionName`
- Benchmark: `BenchmarkFunctionName`
- Example: `ExampleFunctionName`
- Subtests: use descriptive names in `t.Run()`

**Clear Test Failures**

- Provide actionable error messages
- Include actual vs expected values
- Show relevant input data

```go
// Good - clear, actionable error
if got != want {
    t.Errorf("sum(%d, %d) = %d; want %d", a, b, got, want)
}

// Avoid - vague error
if got != want {
    t.Error("wrong result")
}
```

**Test Helpers**

- Use `t.Helper()` to mark helper functions
- Helps identify correct failure location

```go
func requireNoError(t *testing.T, err error) {
    t.Helper()  // Mark as helper so errors point to caller
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
}
```

### 6. Documentation (MEDIUM)

**Package Documentation**

- Every package should have a package comment
- Describe what the package does and why it exists
- Place before `package` declaration

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

**Function Documentation**

- Document exported functions
- Explain what, when necessary why, but not how (code shows how)
- Start with function name

```go
// ProcessPayment processes a payment transaction for the given amount.
// It validates the payment method, charges the account, and records
// the transaction in the ledger.
//
// Returns an error if the payment fails or if the amount is invalid.
func ProcessPayment(amount int, method PaymentMethod) error {
    // Implementation...
}
```

**Comments Explain "Why", Not "What"**

```go
// Good - explains rationale
// Retry up to 3 times because the API occasionally returns transient errors
// that resolve on subsequent requests.
for i := 0; i < 3; i++ {
    if err := callAPI(); err == nil {
        break
    }
    time.Sleep(time.Second)
}

// Avoid - restates obvious code
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
```

### 7. Interfaces (MEDIUM)

**Use Sparingly**

- Only create interfaces when you need abstraction
- Accept interfaces, return concrete types (usually)
- Smaller interfaces are better (often single-method)

```go
// Good - small, focused interface
type Reader interface {
    Read(p []byte) (n int, err error)
}

// Good - composition of small interfaces
type ReadCloser interface {
    Reader
    Closer
}

// Avoid - large interfaces with many methods
type DataStore interface {
    Get(key string) ([]byte, error)
    Set(key string, value []byte) error
    Delete(key string) error
    List() ([]string, error)
    Count() (int, error)
    Clear() error
    // ... many more methods
}
```

**Define Interfaces at Usage Site**

- Define interfaces in the package that uses them, not implements them
- This keeps packages focused and reduces coupling

```go
// In package storage (consumer)
package storage

// Cache is used by storage to cache frequently accessed data.
// Implementations might use Redis, Memcached, or in-memory storage.
type Cache interface {
    Get(key string) ([]byte, error)
    Set(key string, value []byte) error
}

// In package redis (provider)
package redis

// Client implements storage.Cache
type Client struct { ... }
```

**Accept Interfaces, Return Structs**

```go
// Good - accepts interface (flexible), returns concrete type (clear)
func NewServer(db Database) *Server {
    return &Server{db: db}
}

// Avoid - returns interface (limits future additions without breaking changes)
func NewServer(db Database) Server {
    return &server{db: db}
}
```

### 8. Concurrency (MEDIUM)

**Idiomatic Channel Usage**

- Use channels for communication and synchronization
- Close channels from sender, not receiver
- Use buffered channels to prevent blocking when appropriate

```go
// Good - clear ownership and direction
func generate(nums ...int) <-chan int {
    out := make(chan int)
    go func() {
        defer close(out)  // Sender closes
        for _, n := range nums {
            out <- n
        }
    }()
    return out
}

func square(in <-chan int) <-chan int {
    out := make(chan int)
    go func() {
        defer close(out)
        for n := range in {
            out <- n * n
        }
    }()
    return out
}
```

**Context for Cancellation**

- Pass context.Context as first parameter
- Respect context cancellation in goroutines
- Use context for request-scoped values sparingly

```go
// Good - respects context cancellation
func processItems(ctx context.Context, items []Item) error {
    for _, item := range items {
        select {
        case <-ctx.Done():
            return ctx.Err()
        default:
            if err := process(ctx, item); err != nil {
                return err
            }
        }
    }
    return nil
}
```

**Minimize Shared State**

- Prefer message passing over shared memory
- When sharing memory, protect with sync.Mutex or sync.RWMutex
- Use sync.Once for one-time initialization

```go
// Good - use mutex to protect shared state
type SafeCounter struct {
    mu    sync.Mutex
    count int
}

func (c *SafeCounter) Increment() {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.count++
}

// Better - use channel for coordination
type Counter struct {
    ops chan func(*int)
}

func (c *Counter) Increment() {
    c.ops <- func(count *int) { *count++ }
}
```

**WaitGroups for Goroutine Coordination**

```go
// Good - wait for all goroutines to complete
func processAll(items []Item) {
    var wg sync.WaitGroup
    for _, item := range items {
        item := item  // Capture loop variable
        wg.Add(1)
        go func() {
            defer wg.Done()
            process(item)
        }()
    }
    wg.Wait()
}
```

### 9. Performance (LOW - Optimize When Necessary)

**Measure Before Optimizing**

- Profile to identify actual bottlenecks
- Don't optimize prematurely
- Document performance-critical code

**Efficient String Building**

```go
// Good - use strings.Builder for multiple concatenations
var sb strings.Builder
for _, s := range items {
    sb.WriteString(s)
}
result := sb.String()

// Avoid - repeated string concatenation
var result string
for _, s := range items {
    result += s  // Creates new string each iteration
}
```

**Prefer Value Receivers for Small Types**

```go
// Good - small struct, value receiver
type Point struct {
    X, Y int
}

func (p Point) Distance(other Point) float64 {
    dx := p.X - other.X
    dy := p.Y - other.Y
    return math.Sqrt(float64(dx*dx + dy*dy))
}

// Pointer receiver when: mutating, large struct, or consistency
type LargeStruct struct {
    // ... many fields
}

func (l *LargeStruct) Update() {
    // Mutates or avoids copying large struct
}
```

**Slice Preallocation**

```go
// Good - preallocate when size is known
items := make([]Item, 0, expectedSize)
for i := 0; i < expectedSize; i++ {
    items = append(items, createItem(i))
}

// Acceptable - size unknown
var items []Item
for _, data := range input {
    items = append(items, process(data))
}
```

## Progressive Application

Apply these guidelines progressively based on task scope:

**New code**: Apply all relevant guidelines from the start
**Code review**: Focus on critical issues (formatting, naming, errors) first
**Refactoring**: Improve incrementally, don't rewrite everything at once
**Legacy code**: Apply style to new code and touched code, not entire codebase

## Additional Resources

- Official Go Style Guide: <https://google.github.io/styleguide/go/>
- Effective Go: <https://go.dev/doc/effective_go>
- Go Code Review Comments: <https://go.dev/wiki/CodeReviewComments>
