---
name: testing
description: "Three-layer testing strategy for Go microservices with gRPC/Connect APIs. Use when writing tests for domain logic, datastores, request handlers, or integration scenarios. Covers unit tests with mocks, database tests with real PostgreSQL, and end-to-end integration tests."
---

# Testing Strategy for Go Microservices

## Overview

This skill defines a **three-layer testing strategy** for Go microservices using
the three-layer architecture pattern (requests → domain → datastores).

Each layer has a specific testing approach optimized for speed, isolation, and
confidence:

1. **Unit Tests** - Fast, isolated, mock-based
2. **Database Tests** - Real PostgreSQL, transactional, SQL verification
3. **Integration Tests** - Full service, end-to-end, realistic scenarios

## When to Use

Apply this skill when:

- Writing tests for any layer of a three-layer Go service
- Setting up a new test file or test suite
- Reviewing test coverage and structure
- Deciding which type of test to write
- Configuring test infrastructure (mocks, databases, test harnesses)

## The Three Test Layers

### Layer 1: Unit Tests

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

**Structure**:

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

**Key Patterns**:

1. **Setup helper**: Returns component under test + mocks struct
2. **t.Helper()**: Mark setup functions so errors point to test code
3. **Mock returns**: Configure before calling method under test
4. **Block scoping**: Use `{}` blocks when inspecting mock call arguments
5. **Nested t.Run()**: Group related tests, create test hierarchy
6. **failure cases**: Dedicated section for error scenarios
7. **require over assert**: Stops test immediately on failure

### Layer 2: Database Tests

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

**Structure**:

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

**Key Patterns**:

1. **t.Parallel()**: Every test and subtest runs in parallel
2. **Transact/Connect**: Use `pool.Transact()` for writes, `pool.Connect()` for reads
3. **Time assertions**: Use `WithinDuration()` for timestamp checks
4. **Constraint testing**: Explicitly test unique constraints, foreign keys
5. **Real errors**: Test actual database error messages
6. **Mock for error paths**: Use `dbxmock` to simulate connection failures

### Layer 3: Integration Tests

**Location**: `integration/*/`

**Purpose**: Test full request-to-response flow with all real dependencies

**Characteristics**:

- Full service running with real database
- Real gRPC/Connect handlers
- Mock external services (other microservices, auth)
- Tests realistic user scenarios
- Slower, fewer tests than unit/db tests

**Dependencies**:

- `connectrpc.com/connect` - gRPC/Connect client
- `github.com/Hadrian-MTV/servekit/auth/authtest` - Mock auth server
- Project-specific SDK helper for common operations

**Structure**:

**Main test setup** (`integration/entity/main_test.go`):

```go
package entity_test

import (
    "context"
    "fmt"
    "log/slog"
    "os"
    "testing"

    "github.com/Hadrian-MTV/servekit/auth/authtest"
    "github.com/joho/godotenv"

    v1 "yourpackage/generated/proto/entity/v1"
    "yourpackage/generated/proto/entity/v1/entityv1connect"
    "yourpackage/integration/entity/sdk"
    "yourpackage/integration/support"
    "yourpackage/integration/support/services"
    "yourpackage/internal/config"
)

var settings struct {
    Clients struct {
        Entity entityv1connect.EntityServiceClient
    }
    SDK      sdk.Client
    Services struct {
        MainService services.Service
        UserAuth    *authtest.MockAuthServer
        ServiceAuth *authtest.MockAuthServer
    }
    Database support.Database
    Binary   services.Binary
}

func TestMain(m *testing.M) {
    err := BeforeSuite()
    if err != nil {
        slog.Error("failed to setup integration tests:", "error", err)
        os.Exit(1)
    }

    code := m.Run()

    err = AfterSuite()
    if err != nil {
        slog.Error("failed to teardown integration tests:", "error", err)
        os.Exit(1)
    }

    os.Exit(code)
}

func BeforeSuite() error {
    err := godotenv.Load("../../.env.test")
    if err != nil {
        return fmt.Errorf("failed to load environment variables")
    }

    cfg, err := config.Load()
    if err != nil {
        return fmt.Errorf("failed to load config: %w", err)
    }

    ctx := context.Background()

    // Setup database with template for fast test isolation
    settings.Database, err = support.SetupDatabase(
        ctx,
        fmt.Sprintf("%s_template", cfg.Database.Name),
        cfg.Database.User,
        cfg.Database.Password,
        "../../schema.sql",
    )
    if err != nil {
        return fmt.Errorf("failed to setup database: %w", err)
    }

    // Build service binary
    mode := os.Getenv("MODE")
    settings.Binary, err = services.NewBinary(mode)
    if err != nil {
        return fmt.Errorf("failed to build binary: %w", err)
    }

    // Start mock auth servers
    settings.Services.UserAuth, err = authtest.StartMockAuth()
    if err != nil {
        return fmt.Errorf("failed to start user auth: %w", err)
    }

    settings.Services.ServiceAuth, err = authtest.StartMockAuth()
    if err != nil {
        return fmt.Errorf("failed to start service auth: %w", err)
    }

    // Start main service
    settings.Services.MainService, err = settings.Binary.Start(
        ctx,
        services.WithEnvironment(/* ... */),
        services.WithReadyCheck(/* ... */),
    )
    if err != nil {
        return fmt.Errorf("failed to start main service: %w", err)
    }

    // Create client
    settings.Clients.Entity = entityv1connect.NewEntityServiceClient(
        http.DefaultClient,
        settings.Services.MainService.URL().String(),
    )

    // Create SDK helper
    settings.SDK = sdk.New(settings.Clients.Entity, settings.Services.UserAuth)

    return nil
}

func AfterSuite() error {
    var errs []error

    if settings.Services.MainService != nil {
        errs = append(errs, settings.Services.MainService.Stop())
    }
    if settings.Services.UserAuth != nil {
        errs = append(errs, settings.Services.UserAuth.Close())
    }
    if settings.Services.ServiceAuth != nil {
        errs = append(errs, settings.Services.ServiceAuth.Close())
    }
    if settings.Database.Pool != nil {
        errs = append(errs, settings.Database.Delete())
    }

    return errors.Join(errs...)
}
```

**Individual test** (`integration/entity/create_test.go`):

```go
package entity_test

import (
    "fmt"
    "testing"

    "connectrpc.com/connect"
    "github.com/stretchr/testify/require"

    v1 "yourpackage/generated/proto/entity/v1"
    "yourpackage/integration/support"
)

func TestCreate(t *testing.T) {
    t.Run("creates entity successfully", func(t *testing.T) {
        ctx := t.Context()

        name := fmt.Sprintf("Entity %d", support.RandomInt64())

        request, err := support.NewAuthenticatedRequest(
            settings.Services.UserAuth.URL().String(),
            &v1.CreateRequest{Name: name},
        ).Build()
        require.NoError(t, err)

        response, err := settings.Clients.Entity.Create(ctx, request)
        require.NoError(t, err)
        require.NotNil(t, response)

        entity := response.Msg.GetEntity()
        require.NotEmpty(t, entity.GetId())
        require.Equal(t, name, entity.GetName())
    })

    t.Run("failure cases", func(t *testing.T) {
        t.Run("when name is empty", func(t *testing.T) {
            ctx := t.Context()

            request, err := support.NewAuthenticatedRequest(
                settings.Services.UserAuth.URL().String(),
                &v1.CreateRequest{Name: ""},
            ).Build()
            require.NoError(t, err)

            _, err = settings.Clients.Entity.Create(ctx, request)
            require.ErrorContains(t, err, "name is required")

            var connectErr *connect.Error
            require.ErrorAs(t, err, &connectErr)
            require.Equal(t, connect.CodeInvalidArgument, connectErr.Code())
        })
    })
}
```

**SDK helper** (`integration/entity/sdk/sdk.go`):

```go
package sdk

import (
    "context"
    "fmt"
    "testing"

    "github.com/Hadrian-MTV/servekit/auth/authtest"
    "github.com/stretchr/testify/require"

    v1 "yourpackage/generated/proto/entity/v1"
    "yourpackage/generated/proto/entity/v1/entityv1connect"
    "yourpackage/integration/support"
)

type Client struct {
    client   entityv1connect.EntityServiceClient
    authURL  string
}

func New(client entityv1connect.EntityServiceClient, auth *authtest.MockAuthServer) Client {
    return Client{
        client:  client,
        authURL: auth.URL().String(),
    }
}

// Create creates an entity and fails the test on error
func (c Client) Create(t *testing.T, ctx context.Context, name string) Entity {
    t.Helper()

    request, err := support.NewAuthenticatedRequest(c.authURL, &v1.CreateRequest{
        Name: name,
    }).Build()
    require.NoError(t, err)

    response, err := c.client.Create(ctx, request)
    require.NoError(t, err)

    entity := response.Msg.GetEntity()
    return Entity{
        ID:   entity.GetId(),
        Name: entity.GetName(),
    }
}

type Entity struct {
    ID   string
    Name string
}
```

**Key Patterns**:

1. **TestMain setup**: Single suite setup/teardown for all tests
2. **Global settings**: Share clients, services, database across tests
3. **SDK helpers**: Reduce boilerplate, fail test on setup errors
4. **Random data**: Use `support.RandomInt64()` for unique test data
5. **Authenticated requests**: Helper to add auth tokens
6. **Connect error assertions**: Check both error message and code

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

**Helper functions**: `setup`, `setupTestDatabase`, etc.

**Failure cases**: Group in `t.Run("failure cases", ...)`

## Test Assertions

### Always Use require

**Use**: `github.com/stretchr/testify/require`

**Never use**: `github.com/stretchr/testify/assert`

**Reason**: `require` stops test immediately on failure, preventing cascading errors and noise

### Common Assertions

```go
// Errors
require.NoError(t, err)
require.Error(t, err)
require.ErrorContains(t, err, "expected substring")
require.ErrorIs(t, err, domain.ErrNotFound)
require.ErrorAs(t, err, &connectErr)

// Equality
require.Equal(t, expected, actual)
require.NotEqual(t, unexpected, actual)
require.Empty(t, value)
require.NotEmpty(t, value)
require.Nil(t, value)
require.NotNil(t, value)

// Booleans
require.True(t, condition)
require.False(t, condition)

// Collections
require.Len(t, slice, 5)
require.Contains(t, slice, element)
require.NotContains(t, slice, element)

// Numeric
require.Greater(t, actual, minimum)
require.Less(t, actual, maximum)
require.EqualValues(t, int64(5), int32(5))  // Different types

// Time
require.WithinDuration(t, time.Now(), timestamp, 100*time.Millisecond)

// Custom messages (when needed)
require.Equal(t, expected, actual, "custom context: %s", details)
```

## Testing Best Practices

### Test Isolation

**Unit tests**: Completely isolated via mocks

**Database tests**: Each test gets isolated database via transaction or template clone

**Integration tests**: Database truncated/reset between tests if sharing

### Test Data

**Randomize**: Use `support.RandomInt64()` for unique identifiers

**Realistic**: Use realistic data that represents actual usage

**Minimal**: Create only what's needed for the test

**Cleanup**: Tests should clean up after themselves (or use transactions)

### Error Testing

**Always test error paths**:

- Invalid input
- Missing required fields
- Duplicate constraints
- Not found scenarios
- Dependency failures
- Permission denied

**Use failure cases section**:

```go
t.Run("failure cases", func(t *testing.T) {
    t.Run("when input is invalid", ...)
    t.Run("when dependency fails", ...)
})
```

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

### Don't Use assert

❌ **Wrong**: Using assert instead of require

```go
assert.NoError(t, err)  // ❌ Test continues on failure
assert.Equal(t, expected, actual)
```

✅ **Right**: Always use require

```go
require.NoError(t, err)  // ✅ Test stops on failure
require.Equal(t, expected, actual)
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

## Testing Checklist

When writing tests, ensure:

- [ ] Test file named `*_test.go`
- [ ] Package named `package_test` for unit tests
- [ ] `setup()` helper function with `t.Helper()`
- [ ] Nested `t.Run()` for test organization
- [ ] `failure cases` section for error scenarios
- [ ] `require` assertions (never `assert`)
- [ ] Mock verification uses block scoping `{}`
- [ ] Database tests use `t.Parallel()`
- [ ] Integration tests have SDK helpers
- [ ] Descriptive test names
- [ ] Error paths tested
- [ ] Edge cases covered
- [ ] Tests are isolated (no shared state)
- [ ] Tests clean up after themselves

## Related Patterns

- **Three-Layer Service**: Architecture that defines what to test at each layer
- **Dependency Injection**: Enables mock-based testing
- **Interface-Based Testing**: Use interfaces for all dependencies
- **Test-Driven Development**: Write tests first, implementation second

## References

- [Counterfeiter](https://github.com/maxbrunsfeld/counterfeiter)
- [Testify](https://github.com/stretchr/testify)
- [Testcontainers](https://golang.testcontainers.org/)
