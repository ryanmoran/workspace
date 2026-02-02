---
title: Error Handling Basics
impact: HIGH
impactDescription: Prevents silent failures and improves debuggability
tags: errors, error-handling, reliability, debugging
---

## Error Handling Basics

Always check errors explicitly. Never ignore errors unless you have a very
specific reason (which should be documented).

**Why this matters:** Ignored errors lead to silent failures, data corruption,
and extremely difficult debugging sessions. Explicit error handling is a core
Go idiom.

### Always Check Errors

**Correct:**

```go
// Explicit error checking
if err := doSomething(); err != nil {
    return fmt.Errorf("operation failed: %w", err)
}

// Check and handle appropriately
file, err := os.Open("config.json")
if err != nil {
    return fmt.Errorf("open config: %w", err)
}
defer file.Close()
```

**Incorrect:**

```go
// Ignoring errors without justification
_ = doSomething()
doSomething()

// Blank error assignments without comment
file, _ := os.Open("config.json")
```

**Acceptable (with justification):**

```go
// We intentionally ignore Close errors here because we're only reading
// and any error would have been caught during Read.
_ = file.Close()
```

### Error Wrapping

Use `%w` verb with `fmt.Errorf` to wrap errors. This preserves error chains for
debugging while adding context at each layer.

**Correct:**

```go
func processUser(id int) error {
    user, err := fetchUser(id)
    if err != nil {
        // Add context while preserving the error chain
        return fmt.Errorf("process user %d: %w", id, err)
    }

    if err := validateUser(user); err != nil {
        return fmt.Errorf("validate user %d: %w", id, err)
    }

    return nil
}
```

**Incorrect:**

```go
func processUser(id int) error {
    user, err := fetchUser(id)
    if err != nil {
        // Lost the original error - can't use errors.Is() or errors.As()
        return fmt.Errorf("process user %d: %v", id, err)
    }

    // Even worse - loses context about what operation failed
    if err := validateUser(user); err != nil {
        return err
    }

    return nil
}
```

### Checking Wrapped Errors

Use `errors.Is()` and `errors.As()` to check wrapped errors:

```go
// Check for specific sentinel error
if errors.Is(err, os.ErrNotExist) {
    // Handle file not found
}

// Extract specific error type
var pathErr *os.PathError
if errors.As(err, &pathErr) {
    // Access path-specific information
    log.Printf("Failed to access path: %s", pathErr.Path)
}
```

### Idiomatic Error Handling Patterns

#### Pattern 1: Early return

```go
func process(data []byte) error {
    if len(data) == 0 {
        return errors.New("empty data")
    }
    // Continue with valid data - no nesting
}
```

#### Pattern 2: Error variable reuse in sequence

```go
func multiStep() error {
    var err error
    if err = step1(); err != nil {
        return fmt.Errorf("step 1: %w", err)
    }
    if err = step2(); err != nil {
        return fmt.Errorf("step 2: %w", err)
    }
    if err = step3(); err != nil {
        return fmt.Errorf("step 3: %w", err)
    }
    return nil
}
```

#### Pattern 3: Initialize and check in if statement

```go
// Keeps err scoped to the if block
if err := validate(input); err != nil {
    return fmt.Errorf("validation: %w", err)
}
```

### Error Messages

- Start with lowercase (errors are often wrapped)
- Don't end with punctuation
- Be specific about what failed
- Include relevant context (IDs, values)

**Correct:**

```go
return fmt.Errorf("user %d not found in database", userID)
return fmt.Errorf("invalid email format: %s", email)
```

**Incorrect:**

```go
return fmt.Errorf("Error")  // Too vague, starts with uppercase
return fmt.Errorf("Failed to find user.")  // Ends with punctuation
```
