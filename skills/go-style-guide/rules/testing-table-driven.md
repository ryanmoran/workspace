---
title: Table-Driven Tests
impact: HIGH
impactDescription: Comprehensive test coverage with minimal code duplication
tags: testing, table-driven, test-patterns, coverage
---

## Table-Driven Tests

Use table-driven tests for comprehensive coverage. This pattern makes adding
test cases trivial and clearly shows all scenarios.

**Why this matters:** Table-driven tests reduce duplication, make test cases
obvious, and scale effortlessly as requirements evolve.

### Basic Pattern

**Correct:**

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
                t.Errorf("validateEmail(%q) error = %v, wantErr %v", tt.email, err, tt.wantErr)
            }
        })
    }
}
```

**Incorrect (repetitive tests):**

```go
func TestValidateEmailValid(t *testing.T) {
    err := validateEmail("user@example.com")
    if err != nil {
        t.Errorf("expected no error, got %v", err)
    }
}

func TestValidateEmailMissingAt(t *testing.T) {
    err := validateEmail("userexample.com")
    if err == nil {
        t.Error("expected error, got nil")
    }
}

func TestValidateEmailMissingDomain(t *testing.T) {
    err := validateEmail("user@")
    if err == nil {
        t.Error("expected error, got nil")
    }
}

// ... many more similar functions
```

### Testing Return Values

**Correct:**

```go
func TestSum(t *testing.T) {
    tests := []struct {
        name string
        a, b int
        want int
    }{
        {name: "positive numbers", a: 2, b: 3, want: 5},
        {name: "negative numbers", a: -2, b: -3, want: -5},
        {name: "zero", a: 0, b: 5, want: 5},
        {name: "mixed signs", a: -2, b: 3, want: 1},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got := sum(tt.a, tt.b)
            if got != tt.want {
                t.Errorf("sum(%d, %d) = %d; want %d", tt.a, tt.b, got, tt.want)
            }
        })
    }
}
```

### Testing Complex Structs

**Correct:**

```go
func TestParseUser(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    *User
        wantErr bool
    }{
        {
            name:  "valid user",
            input: `{"name":"Alice","age":30}`,
            want: &User{
                Name: "Alice",
                Age:  30,
            },
            wantErr: false,
        },
        {
            name:    "invalid json",
            input:   `{invalid}`,
            want:    nil,
            wantErr: true,
        },
        {
            name:  "missing fields",
            input: `{"name":"Bob"}`,
            want: &User{
                Name: "Bob",
                Age:  0,  // Zero value
            },
            wantErr: false,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := parseUser(tt.input)
            if (err != nil) != tt.wantErr {
                t.Errorf("parseUser() error = %v, wantErr %v", err, tt.wantErr)
                return
            }
            if !reflect.DeepEqual(got, tt.want) {
                t.Errorf("parseUser() = %+v, want %+v", got, tt.want)
            }
        })
    }
}
```

### Parallel Tests

Use `t.Parallel()` to run test cases concurrently:

```go
func TestValidateEmail(t *testing.T) {
    tests := []struct {
        name    string
        email   string
        wantErr bool
    }{
        // ... test cases
    }

    for _, tt := range tests {
        tt := tt  // Capture range variable
        t.Run(tt.name, func(t *testing.T) {
            t.Parallel()  // Run test cases in parallel

            err := validateEmail(tt.email)
            if (err != nil) != tt.wantErr {
                t.Errorf("validateEmail(%q) error = %v, wantErr %v", tt.email, err, tt.wantErr)
            }
        })
    }
}
```

### When Not to Use Table-Driven Tests

Table-driven tests are not always appropriate:

- **Setup/teardown varies per case** - Complex per-case setup makes tables unwieldy
- **Single test case** - Don't use tables for one-off tests
- **Integration tests with side effects** - When tests can't run independently
- **Tests that need different assertion logic** - When each case needs unique checks

In these cases, use separate test functions instead.
