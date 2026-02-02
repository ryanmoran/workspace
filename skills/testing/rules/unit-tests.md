---
title: Unit Tests
impact: CRITICAL
impactDescription: Foundation for fast, isolated testing of business logic
tags: unit-tests, mocks, domain, requests, isolation
---

## Unit Tests

**Location**: `internal/*/domain/*_test.go`, `internal/*/requests/*_test.go`

**Purpose**: Test business logic and validation in complete isolation

**Characteristics**:

- Use generated mocks (counterfeiter) for all dependencies
- No database, no network, no external systems
- Run in milliseconds
- Hundreds or thousands of tests
- Focus on edge cases, error paths, business rules

**Dependencies**:

- `github.com/stretchr/testify/require` - Assertions
- `counterfeiter` - Mock generation

## Structure

```go
package domain_test

import (
    "context"
    "errors"
    "testing"
    "time"

    "github.com/stretchr/testify/require"

    "yourpackage/internal/entity/domain"
    "yourpackage/internal/entity/domain/mocks"
)

func TestEntity(t *testing.T) {
    type Mocks struct {
        EntityDatastore *mocks.EntityDatastore
        OtherService    *mocks.OtherService
    }

    setup := func(t *testing.T) (domain.Entity, Mocks) {
        t.Helper()

        mocks := Mocks{
            EntityDatastore: &mocks.EntityDatastore{},
            OtherService:    &mocks.OtherService{},
        }

        return domain.NewEntity(mocks.EntityDatastore, mocks.OtherService), mocks
    }

    t.Run("MethodName", func(t *testing.T) {
        t.Run("success case description", func(t *testing.T) {
            ctx := t.Context()
            entity, mocks := setup(t)

            // Configure mock returns
            expectedResult := domain.Result{ID: "123", Value: "test"}
            mocks.EntityDatastore.CreateReturns(expectedResult, nil)

            // Execute
            result, err := entity.Create(ctx, nil, "test-input")

            // Assert results
            require.NoError(t, err)
            require.Equal(t, "123", result.ID)
            require.Equal(t, "test", result.Value)

            // Verify mock interactions with block scoping
            require.Equal(t, 1, mocks.EntityDatastore.CreateCallCount())
            {
                _, _, input := mocks.EntityDatastore.CreateArgsForCall(0)
                require.Equal(t, "test-input", input)
            }
        })

        t.Run("failure cases", func(t *testing.T) {
            t.Run("returns error when datastore fails", func(t *testing.T) {
                ctx := t.Context()
                entity, mocks := setup(t)

                mocks.EntityDatastore.CreateReturns(domain.Result{}, errors.New("db error"))

                _, err := entity.Create(ctx, nil, "test-input")

                require.ErrorContains(t, err, "failed to create")
                require.ErrorContains(t, err, "db error")
            })

            t.Run("returns error when input is invalid", func(t *testing.T) {
                ctx := t.Context()
                entity, mocks := setup(t)

                _, err := entity.Create(ctx, nil, "")

                require.ErrorContains(t, err, "input is required")
                require.Equal(t, 0, mocks.EntityDatastore.CreateCallCount())
            })
        })
    })
}
```

## Key Patterns

1. **Setup helper**: Returns component under test + mocks struct
2. **t.Helper()**: Mark setup functions so errors point to test code
3. **Mock returns**: Configure before calling method under test
4. **Block scoping**: Use `{}` blocks when inspecting mock call arguments
5. **Nested t.Run()**: Group related tests, create test hierarchy
6. **failure cases**: Dedicated section for error scenarios
7. **require over assert**: Stops test immediately on failure

## Common Pitfalls

### Don't Mix Test Types

❌ **Wrong**: Database calls in unit tests

```go
// Unit test should NOT do this
func TestEntity(t *testing.T) {
    t.Run("Create", func(t *testing.T) {
        pool := setupDatabase(t)  // ❌ Unit test using real DB
        entity := domain.NewEntity(datastores.NewEntity())
        // ...
    })
}
```

✅ **Right**: Use mocks in unit tests

```go
func TestEntity(t *testing.T) {
    t.Run("Create", func(t *testing.T) {
        entity, mocks := setup(t)  // ✅ Mocked datastore
        mocks.EntityDatastore.CreateReturns(result, nil)
        // ...
    })
}
```

### Don't Skip t.Helper()

❌ **Wrong**: Missing t.Helper() in setup functions

```go
func setup(t *testing.T) Component {
    // Missing t.Helper()
    mock := &mocks.Dependency{}
    return NewComponent(mock)
}
```

✅ **Right**: Always mark setup functions

```go
func setup(t *testing.T) Component {
    t.Helper()  // ✅ Error lines point to caller
    mock := &mocks.Dependency{}
    return NewComponent(mock)
}
```

### Don't Verify Mocks Without Block Scoping

❌ **Wrong**: Mock verification without blocks

```go
ctx, tx, name, value := mock.CreateArgsForCall(0)
require.Equal(t, "test", name)
// Variables pollute scope
```

✅ **Right**: Use block scoping

```go
{
    ctx, tx, name, value := mock.CreateArgsForCall(0)
    require.Equal(t, "test", name)
}  // ✅ Variables scoped to block
```
