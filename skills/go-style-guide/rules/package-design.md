---
title: Package Design Principles
impact: HIGH
impactDescription: Affects maintainability, testability, and code organization
tags: packages, architecture, dependencies, organization
---

## Package Design Principles

Design packages with focused responsibility and minimal dependencies for
maintainable, testable code.

### Focused Responsibility

Each package should have a single, clear purpose. Avoid "god packages" that do
everything.

**Good package structure:**

```text
myapp/
  main.go           # Command-line application (can be at root)
  handler.go        # Public library code (can be at root)
  internal/         # Private application code
    auth/           # Authentication logic
      token.go
      session.go
    storage/        # Data persistence
      postgres.go
      cache.go
    api/            # HTTP handlers
      users.go
      posts.go
```

**Key principles:**

- Command-line applications can be at the root directory (no `cmd/` needed)
- Public library code can be at the root directory (no `pkg/` needed)
- Each package has clear, non-overlapping responsibility
- `internal/` for private application code
- Use `cmd/` only when you have multiple command-line applications
- Use `pkg/` only when you need to clearly separate public API from private code

**Incorrect:**

```text
myapp/
  util/             # Too generic, becomes a dumping ground
    helpers.go      # What kind of helpers?
    stuff.go        # Unfocused
  common/           # Too vague
    things.go
```

### Minimize Dependencies

**Why it matters:** Dependencies create coupling, make testing harder, and
increase build times and binary sizes.

**Correct:**

```go
package notification

// Depend on interface, not concrete type
type Sender interface {
    Send(to string, message string) error
}

type Service struct {
    sender Sender  // Accept interface
}

// Users can provide any implementation
func New(sender Sender) *Service {
    return &Service{sender: sender}
}
```

**Incorrect:**

```go
package notification

import (
    "myapp/email"     // Hard dependency on email package
    "myapp/sms"       // Hard dependency on SMS package
    "myapp/push"      // Hard dependency on push package
)

type Service struct {
    email *email.Client
    sms   *sms.Client
    push  *push.Client
}
```

### Avoid Circular Dependencies

Go does not allow circular package dependencies. Design your package structure
to avoid them.

**Correct (dependency flows one direction):**

```text
api → business → storage
```

```go
// package storage
type UserStore struct { ... }

// package business
import "myapp/storage"

type UserService struct {
    store *storage.UserStore
}

// package api
import "myapp/business"

type Handler struct {
    service *business.UserService
}
```

**Incorrect (circular dependency):**

```text
api ←→ business  // Circular!
```

**How to fix:** Extract shared types to a common package or use interfaces.

```go
// package types (shared)
type User struct { ... }

// package business
import "myapp/types"
type UserService struct { ... }

// package api
import "myapp/types"
type Handler struct { ... }
```

### Avoid Premature Package Creation

Don't create packages for features that don't exist yet. Let package structure
emerge from real needs.

**Incorrect:**

```go
// Creating packages speculatively
package cache      // Created but not used yet
package queue      // "We might need this later"
package analytics  // "Eventually we'll add this"
```

**Correct:**

```go
// Start with simple code in existing packages
// Extract to new package when:
// 1. Package is getting too large (>1000 lines)
// 2. Clear cohesive functionality emerges
// 3. Code is being imported by multiple packages
// 4. Testing would be easier with isolation
```

### Package-Level Documentation

Every package should have a package comment explaining its purpose.

**Correct:**

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

**Incorrect:**

```go
// auth package
package auth

// Or no package comment at all
package auth
```

### Internal Packages

Use `internal/` directories to make packages private to your application or
module.

```text
myapp/
  internal/
    auth/        # Only importable by myapp packages
    storage/     # Not accessible to external modules
```

**Rule:** Packages under `internal/` can only be imported by code in the parent
directory tree.

This prevents external dependencies on implementation details and gives you
freedom to refactor.
