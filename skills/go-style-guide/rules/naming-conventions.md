---
title: Naming Conventions
impact: CRITICAL
impactDescription: Affects code readability and API usability
tags: naming, mixedcaps, clarity, conventions
---

## Naming Conventions

Use `MixedCaps` or `mixedCaps` (camel case) for all Go identifiers. Never use
underscores except in generated code or test names.

**General Principles:**

- Keep names concise and context-aware
- Avoid stuttering (redundant package name repetition)
- Shorter names for smaller scopes, longer names for larger scopes
- Names should be clear to readers unfamiliar with the code

### Constants

Use MixedCaps for both exported and unexported constants.

**Correct:**

```go
// Exported constants
const MaxRetries = 3
const DefaultTimeout = 30 * time.Second

// Unexported constants
const bufferSize = 1024
const maxConnections = 100
```

**Incorrect:**

```go
const MAX_RETRIES = 3          // Don't use underscores
const default_timeout = 30     // Don't use underscores
const kMaxConnections = 100    // Don't use prefixes
```

### Variables

Keep variable names concise and clear within their context.

**Correct:**

```go
var count int
var users []*User
var mu sync.Mutex  // Conventional abbreviation

// Longer names for package-level or wider scope
var defaultClientTimeout = 30 * time.Second
```

**Incorrect:**

```go
var userCount int          // Redundant if "count" is obviously for users in context
var userSlice []*User      // Type is already clear
var userMutex sync.Mutex   // Don't repeat the type information
```

### Functions and Methods

Use action-oriented names that clearly express intent. Avoid redundant type
information.

**Correct:**

```go
func ProcessPayment(amount int) error
func (c *Client) Connect() error
func validateEmail(email string) bool
```

**Incorrect:**

```go
func ProcessPaymentAmount(amount int) error  // "Amount" is redundant
func (c *Client) ConnectClient() error       // "Client" is redundant
func EmailValidator(email string) bool       // Should be a verb
```

### Package Names

- Short, single-word, lowercase
- No underscores or mixed caps
- Avoid generic names like `util`, `common`, `base`
- Should be clear what functionality the package provides

**Correct:**

```go
package auth
package httputil
package ioutil
```

**Incorrect:**

```go
package authentication  // Too long
package http_util      // Underscores
package utils          // Too generic
```

### Avoid Stuttering

Don't repeat the package name in exported names.

**Correct:**

```go
auth.Token          // not auth.AuthToken
user.Service        // not user.UserService
http.Client         // not http.HTTPClient
```

**Example implementation:**

```go
package user

// Service provides user management operations.
// Will be used as user.Service, not user.UserService
type Service struct {
    db Database
}
```

**Incorrect:**

```go
package user

// UserService provides user management operations.
// Results in stuttering: user.UserService
type UserService struct {
    db Database
}
```

### Getters and Setters

If you have a getter, omit the "Get" prefix. Use "Set" prefix for setters.

**Correct:**

```go
type Client struct {
    name string
}

// Getter - no "Get" prefix
func (c *Client) Name() string {
    return c.name
}

// Setter - use "Set" prefix
func (c *Client) SetName(name string) {
    c.name = name
}
```

**Incorrect:**

```go
func (c *Client) GetName() string {  // Don't use "Get" prefix
    return c.name
}
```

### Interface Names

Single-method interfaces should be named with the method name plus "-er" suffix.

**Correct:**

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Writer interface {
    Write(p []byte) (n int, err error)
}

type Closer interface {
    Close() error
}
```
