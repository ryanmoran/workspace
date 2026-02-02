---
title: Test Quality and Clarity
impact: MEDIUM
impactDescription: Makes test failures actionable and debugging faster
tags: testing, test-quality, error-messages, helpers
---

## Test Quality and Clarity

Write tests that provide clear, actionable feedback when they fail.

### Test Naming

**Test functions:**

- Use `TestFunctionName` for unit tests
- Use `BenchmarkFunctionName` for benchmarks
- Use `ExampleFunctionName` for examples

**Subtests:**

- Use `t.Run()` with descriptive names
- Name describes the scenario being tested
- Use lowercase for consistency

**Correct:**

```go
func TestUserService(t *testing.T) {
    t.Run("creates new user successfully", func(t *testing.T) {
        // ...
    })

    t.Run("returns error for duplicate email", func(t *testing.T) {
        // ...
    })

    t.Run("validates required fields", func(t *testing.T) {
        // ...
    })
}
```

**Incorrect:**

```go
func TestUserService1(t *testing.T) { ... }  // Non-descriptive
func TestUserService2(t *testing.T) { ... }

// Or vague subtest names
t.Run("test1", func(t *testing.T) { ... })
t.Run("happy_path", func(t *testing.T) { ... })  // Use spaces, not underscores
```

### Clear Test Failures

Provide actionable error messages that include:

- What was being tested
- Actual values received
- Expected values
- Relevant input data

**Correct:**

```go
// Clear, actionable error
if got != want {
    t.Errorf("sum(%d, %d) = %d; want %d", a, b, got, want)
}

// For complex values
if !reflect.DeepEqual(got, want) {
    t.Errorf("parseUser(%q):\ngot:  %+v\nwant: %+v", input, got, want)
}

// With context
if err == nil {
    t.Fatalf("Delete(%q) succeeded; want error for non-existent user", userID)
}
```

**Incorrect:**

```go
// Vague errors that don't help debugging
if got != want {
    t.Error("wrong result")
}

if err != nil {
    t.Error("error occurred")
}

if user == nil {
    t.Error("failed")
}
```

### Test Helpers

Use `t.Helper()` to mark helper functions. This makes test failures point to the actual test code, not the helper.

**Correct:**

```go
func requireNoError(t *testing.T, err error) {
    t.Helper()  // Mark as helper
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
}

func assertEqual(t *testing.T, got, want int) {
    t.Helper()
    if got != want {
        t.Errorf("got %d; want %d", got, want)
    }
}

// Usage
func TestSomething(t *testing.T) {
    result, err := doSomething()
    requireNoError(t, err)              // Failure reports line 13, not line 2
    assertEqual(t, result, expected)    // Failure reports line 14, not line 7
}
```

**Without `t.Helper()` (incorrect):**

```go
func requireNoError(t *testing.T, err error) {
    // Missing t.Helper()
    if err != nil {
        t.Fatalf("unexpected error: %v", err)  // Failure always reports THIS line
    }
}
```

### Test Setup and Teardown

Use `t.Cleanup()` for reliable cleanup that runs even if test fails:

**Correct:**

```go
func TestWithDatabase(t *testing.T) {
    db := setupTestDB(t)
    t.Cleanup(func() {
        db.Close()  // Always runs, even if test fails
    })

    // Test code
    // No need for defer or manual cleanup
}
```

**Also correct (using defer):**

```go
func TestWithDatabase(t *testing.T) {
    db := setupTestDB(t)
    defer db.Close()

    // Test code
}
```

### Test Fixtures

Keep test fixtures close to tests and easy to understand:

**Correct:**

```go
func TestParseUser(t *testing.T) {
    // Inline fixtures for clarity
    validJSON := `{"name":"Alice","age":30,"email":"alice@example.com"}`
    invalidJSON := `{invalid json}`

    user, err := parseUser(validJSON)
    requireNoError(t, err)
    assertEqual(t, user.Name, "Alice")
}
```

**For shared fixtures:**

```go
// testdata/ directory (automatically ignored by go build)
testdata/
  valid_user.json
  invalid_user.json

// In test
func TestParseUser(t *testing.T) {
    data, err := os.ReadFile("testdata/valid_user.json")
    requireNoError(t, err)

    user, err := parseUser(string(data))
    // ...
}
```

### Testing Errors

Test both success and error cases:

**Correct:**

```go
func TestValidateAge(t *testing.T) {
    tests := []struct {
        name    string
        age     int
        wantErr error
    }{
        {name: "valid age", age: 25, wantErr: nil},
        {name: "negative age", age: -5, wantErr: ErrInvalidAge},
        {name: "too old", age: 200, wantErr: ErrInvalidAge},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := validateAge(tt.age)

            // Check specific error
            if !errors.Is(err, tt.wantErr) {
                t.Errorf("validateAge(%d) error = %v; want %v", tt.age, err, tt.wantErr)
            }
        })
    }
}
```

### Don't Test Implementation Details

Test behavior, not implementation:

**Correct (tests behavior):**

```go
func TestUserService_CreateUser(t *testing.T) {
    svc := NewUserService(db)

    user, err := svc.CreateUser("alice@example.com")
    requireNoError(t, err)

    // Test the observable behavior
    assertEqual(t, user.Email, "alice@example.com")
    assertUserExistsInDB(t, db, user.ID)
}
```

**Incorrect (tests implementation):**

```go
func TestUserService_CreateUser(t *testing.T) {
    svc := NewUserService(db)

    // Don't test internal method calls
    if svc.validateEmail("alice@example.com") != nil {
        t.Error("expected email validation to pass")
    }

    // Don't test order of internal operations
    if !svc.calledHashPassword {
        t.Error("expected password hashing")
    }
}
```
