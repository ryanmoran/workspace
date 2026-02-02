---
title: Integration Tests
impact: HIGH
impactDescription: Validates full request-to-response flow with real dependencies
tags: integration, e2e, grpc, connect, handlers, full-service
---

## Integration Tests

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

## Structure

### Main Test Setup

**File**: `integration/entity/main_test.go`

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

### Individual Test

**File**: `integration/entity/create_test.go`

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

### SDK Helper

**File**: `integration/entity/sdk/sdk.go`

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

## Key Patterns

1. **TestMain setup**: Single suite setup/teardown for all tests
2. **Global settings**: Share clients, services, database across tests
3. **SDK helpers**: Reduce boilerplate, fail test on setup errors
4. **Random data**: Use `support.RandomInt64()` for unique test data
5. **Authenticated requests**: Helper to add auth tokens
6. **Connect error assertions**: Check both error message and code
