---
title: Test Organization
impact: MEDIUM
impactDescription: Ensures tests are discoverable and maintainable
tags: organization, structure, naming, directories
---

## Test Organization

### Directory Structure

```text
yourservice/
├── internal/
│   ├── entity/
│   │   ├── domain/
│   │   │   ├── entity.go
│   │   │   ├── entity_test.go          # Unit tests with mocks
│   │   │   ├── interfaces.go            # Interface definitions
│   │   │   └── mocks/
│   │   │       └── entity_datastore.go  # Generated mocks
│   │   ├── datastores/
│   │   │   ├── entity.go
│   │   │   └── entity_test.go          # Database tests
│   │   └── requests/
│   │       ├── create.go
│   │       └── create_test.go          # Request validation tests
│   └── utilities/
│       ├── helper.go
│       └── helper_test.go              # Utility tests
└── integration/
    ├── entity/
    │   ├── main_test.go                # Suite setup
    │   ├── create_test.go              # Integration tests
    │   ├── get_test.go
    │   └── sdk/
    │       └── sdk.go                  # Test helpers
    └── support/
        ├── database.go                 # Database test utilities
        ├── authenticated_request.go    # Auth helpers
        └── random.go                   # Test data generation
```

### Naming Conventions

**Test files**: `*_test.go` suffix

**Test functions**: `TestEntity`, `TestMethodName`

**Sub-tests**: Descriptive names in `t.Run()`

- "creates entity successfully"
- "returns error when name is empty"
- "enforces unique constraint"

**Helper functions**: `setup`

You can nest the `setup` helper function to get more specific functionality in sub-tests.

```go
func setup(t *testing.T) dbx.Pool {
    return dbx.NewPool(...)
}

func TestSomething(t *testing.T) {
  setup := func(t *testing.T) (dbx.Pool, datastores.Objects) {
    t.Helper()

    pool := setup(t)  // Calls package-level function

    return pool, datastores.NewObjects()
  }

  t.Run("with objects", func(t *testing.T) {
    setup := func(t *testing.T) (dbx.Pool, datastores.Objects, string) {
      t.Helper()

      pool, datastore := setup(t) // Calls outer-scope setup function

      return pool, datastore, support.RandomString(10)
    }

    t.Run("has random value", func(t *testing.T) {
      pool, database, value := setup(t) // Calls local sub-test setup function

      // ...
    })
  })
}
```

**Failure cases**: Group in `t.Run("failure cases", ...)`

### Test Documentation

**Names are documentation**: Use descriptive test names

```go
// Good
t.Run("creates entity with generated slug", ...)
t.Run("returns error when name exceeds 255 characters", ...)

// Bad
t.Run("test1", ...)
t.Run("error", ...)
```

**Comments when needed**: Explain non-obvious setup or assertions

**Examples in comments**: Show expected behavior
