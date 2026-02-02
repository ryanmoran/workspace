---
title: Custom Error Types
impact: MEDIUM
impactDescription: Enables rich error information and better error handling
tags: errors, error-types, sentinel-errors, custom-types
---

## Custom Error Types

Define sentinel errors as package-level variables and custom error types for
rich error information.

### Sentinel Errors

Sentinel errors are predefined error values that callers can check using
`errors.Is()`.

**Correct:**

```go
package storage

import "errors"

// Sentinel errors - package-level variables
var (
    ErrNotFound      = errors.New("resource not found")
    ErrUnauthorized  = errors.New("unauthorized access")
    ErrAlreadyExists = errors.New("resource already exists")
)

func Get(id string) (*Resource, error) {
    r, found := db.Lookup(id)
    if !found {
        return nil, ErrNotFound
    }
    return r, nil
}
```

**Usage:**

```go
import "errors"

resource, err := storage.Get(id)
if errors.Is(err, storage.ErrNotFound) {
    // Handle not found case specifically
    return handleNotFound(id)
}
if err != nil {
    // Handle other errors
    return err
}
```

**Incorrect:**

```go
// Don't create new error instances for the same condition
func Get(id string) (*Resource, error) {
    r, found := db.Lookup(id)
    if !found {
        // New error instance each time - can't use errors.Is()
        return nil, errors.New("resource not found")
    }
    return r, nil
}
```

### Custom Error Types

Use custom error types when you need to provide structured error information.

**Correct:**

```go
package validation

// ValidationError provides detailed validation failure information
type ValidationError struct {
    Field   string
    Value   interface{}
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation failed for field %s: %s", e.Field, e.Message)
}

// Usage
func ValidateUser(u *User) error {
    if u.Age < 0 {
        return &ValidationError{
            Field:   "Age",
            Value:   u.Age,
            Message: "must be non-negative",
        }
    }
    return nil
}
```

**Usage with errors.As():**

```go
import "errors"

if err := validation.ValidateUser(user); err != nil {
    var valErr *validation.ValidationError
    if errors.As(err, &valErr) {
        // Access structured error information
        log.Printf("Invalid field: %s (value: %v): %s",
            valErr.Field, valErr.Value, valErr.Message)
    }
    return err
}
```

### Wrapping Custom Errors

Custom errors should support wrapping:

**Correct:**

```go
type QueryError struct {
    Query string
    Err   error  // Wrapped error
}

func (e *QueryError) Error() string {
    return fmt.Sprintf("query failed: %s: %v", e.Query, e.Err)
}

// Implement Unwrap to support errors.Is() and errors.As()
func (e *QueryError) Unwrap() error {
    return e.Err
}

// Usage
func ExecuteQuery(query string) error {
    err := db.Exec(query)
    if err != nil {
        return &QueryError{
            Query: query,
            Err:   err,  // Preserve original error
        }
    }
    return nil
}
```

### Error Naming Conventions

**Sentinel errors:**

- Prefix with `Err`
- Use MixedCaps
- Be specific: `ErrNotFound` not `ErrError`

**Custom error types:**

- Suffix with `Error`
- Use MixedCaps
- Describe the category: `ValidationError`, `NetworkError`, `ParseError`

**Incorrect:**

```go
var NotFound = errors.New("not found")        // Missing Err prefix
var ERROR_UNAUTHORIZED = errors.New("nope")   // Wrong case

type InputErr struct{ ... }                   // Should be InputError
```
