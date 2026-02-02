---
title: Database Tests
impact: HIGH
impactDescription: Verifies SQL queries and database schema work correctly
tags: database, postgresql, datastores, sql, transactions
---

## Database Tests

**Location**: `internal/*/datastores/*_test.go`

**Purpose**: Verify SQL queries work correctly with real PostgreSQL

**Characteristics**:

- Use real PostgreSQL database via testcontainers or servekit/dbtest
- Each test gets isolated database via template cloning
- Tests run in parallel for speed
- Focus on CRUD operations, constraints, indexes
- Verify database schema works as designed

**Dependencies**:

- `github.com/Hadrian-MTV/servekit/dbx` - Database abstraction
- `github.com/Hadrian-MTV/servekit/dbtest` - Test database utilities
- `github.com/Hadrian-MTV/servekit/dbx/dbxmock` - Mocks for error testing
- `testcontainers-go` - PostgreSQL container management

## Structure

```go
package datastores_test

import (
    "context"
    "errors"
    "testing"
    "time"

    "github.com/Hadrian-MTV/servekit/dbx"
    "github.com/Hadrian-MTV/servekit/dbx/dbxmock"
    "github.com/stretchr/testify/require"

    "yourpackage/internal/entity/datastores"
    "yourpackage/internal/entity/domain"
)

func TestEntity(t *testing.T) {
    t.Parallel()

    setup := func(t *testing.T) (datastores.Entity, dbx.Pool) {
        t.Helper()

        pool := setupTestDatabase(t)
        entity := datastores.NewEntity()

        return entity, pool
    }

    t.Run("Create", func(t *testing.T) {
        t.Parallel()

        t.Run("creates record successfully", func(t *testing.T) {
            t.Parallel()

            ctx := t.Context()
            entity, pool := setup(t)

            var result domain.Entity
            err := pool.Transact(ctx, func(tx dbx.Tx) error {
                var err error
                result, err = entity.Create(ctx, tx, "Test Name", "test-value")
                return err
            })
            require.NoError(t, err)

            require.NotEmpty(t, result.ID)
            require.Equal(t, "Test Name", result.Name)
            require.Equal(t, "test-value", result.Value)
            require.WithinDuration(t, time.Now(), result.CreatedAt, 100*time.Millisecond)
        })

        t.Run("enforces unique constraint", func(t *testing.T) {
            t.Parallel()

            ctx := t.Context()
            entity, pool := setup(t)

            err := pool.Transact(ctx, func(tx dbx.Tx) error {
                _, err := entity.Create(ctx, tx, "Duplicate", "value1")
                if err != nil {
                    return err
                }

                // Should fail with constraint violation
                _, err = entity.Create(ctx, tx, "Duplicate", "value2")
                return err
            })

            require.Error(t, err)
            require.ErrorContains(t, err, "unique constraint")
        })

        t.Run("failure cases", func(t *testing.T) {
            t.Parallel()

            t.Run("when the transaction is nil", func(t *testing.T) {
                t.Parallel()

                ctx := t.Context()
                entity, _ := setup(t)

                _, err := entity.Create(ctx, nil, "Test", "value")
                require.ErrorIs(t, err, datastores.ErrNilTx)
            })

            t.Run("when the connection errors", func(t *testing.T) {
                t.Parallel()

                ctx := t.Context()
                entity := datastores.NewEntity()
                pool := dbxmock.NewPool()
                row := &dbxmock.Row{}
                row.ScanReturns(errors.New("tx errored"))
                pool.Conn.QueryRowReturns(row)

                err := pool.Transact(ctx, func(tx dbx.Tx) error {
                    _, err := entity.Create(ctx, tx, "Test", "value")
                    return err
                })
                require.ErrorContains(t, err, "tx errored")
            })
        })
    })

    t.Run("Get", func(t *testing.T) {
        t.Parallel()

        t.Run("retrieves record by ID", func(t *testing.T) {
            t.Parallel()

            ctx := t.Context()
            entity, pool := setup(t)

            var created, retrieved domain.Entity
            err := pool.Transact(ctx, func(tx dbx.Tx) error {
                var err error
                created, err = entity.Create(ctx, tx, "Test", "value")
                if err != nil {
                    return err
                }

                retrieved, err = entity.Get(ctx, tx, created.ID)
                return err
            })
            require.NoError(t, err)

            require.Equal(t, created.ID, retrieved.ID)
            require.Equal(t, created.Name, retrieved.Name)
            require.Equal(t, created.Value, retrieved.Value)
        })

        t.Run("failure cases", func(t *testing.T) {
            t.Parallel()

            t.Run("when record does not exist", func(t *testing.T) {
                t.Parallel()

                ctx := t.Context()
                entity, pool := setup(t)

                err := pool.Connect(ctx, func(conn dbx.Conn) error {
                    _, err := entity.Get(ctx, conn, "00000000-0000-0000-0000-000000000000")
                    return err
                })
                require.ErrorContains(t, err, "no rows")
            })
        })
    })
}

func setupTestDatabase(t *testing.T) dbx.Pool {
    t.Helper()
    // Implementation depends on project setup
    // See integration/support/database.go for full example
    panic("implement setupTestDatabase for your project")
}
```

## Key Patterns

1. **t.Parallel()**: Every test and subtest runs in parallel
2. **Transact/Connect**: Use `pool.Transact()` for writes, `pool.Connect()` for reads
3. **Time assertions**: Use `WithinDuration()` for timestamp checks
4. **Constraint testing**: Explicitly test unique constraints, foreign keys
5. **Real errors**: Test actual database error messages
6. **Mock for error paths**: Use `dbxmock` to simulate connection failures

## Common Pitfalls

### Don't Forget t.Parallel()

❌ **Wrong**: Database tests without parallel

```go
func TestDatastore_Create(t *testing.T) {
    // Missing t.Parallel() - tests run serially
    t.Run("success", func(t *testing.T) {
        // Missing t.Parallel()
    })
}
```

✅ **Right**: Parallel database tests

```go
func TestDatastore_Create(t *testing.T) {
    t.Parallel()  // ✅ Test can run in parallel

    t.Run("success", func(t *testing.T) {
        t.Parallel()  // ✅ Subtest can run in parallel
    })
}
```
