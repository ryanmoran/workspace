---
title: Interface Design
impact: MEDIUM
impactDescription: Affects API flexibility and testability
tags: interfaces, abstraction, design, decoupling
---

## Interface Design

Use interfaces sparingly and purposefully. Interfaces add abstraction, which has
benefits (testability, flexibility) and costs (indirection, complexity).

### Use Interfaces Sparingly

Only create interfaces when you need abstraction. Don't create interfaces "just
in case" or for every type.

**When to use interfaces:**

- When you have multiple implementations
- When you need to decouple packages
- To enable testing with mocks
- To define contracts between components

**When NOT to use interfaces:**

- "Might need to swap implementations someday"
- Single concrete implementation with no plans to change
- Internal implementation details that never leave the package

**Correct:**

```go
// io.Reader is used everywhere - good interface
type Reader interface {
    Read(p []byte) (n int, err error)
}

// Multiple implementations exist and are commonly swapped
type Database interface {
    Query(sql string) (Rows, error)
    Exec(sql string) error
}
```

**Incorrect:**

```go
// Unnecessary interface for single implementation
type UserServiceInterface interface {
    CreateUser(email string) (*User, error)
    GetUser(id string) (*User, error)
    DeleteUser(id string) error
}

type UserService struct { ... }  // Only implementation
```

### Keep Interfaces Small

Prefer small, focused interfaces. Many interfaces in Go have only one or two
methods.

**Correct (small, focused interfaces):**

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

// Compose small interfaces
type ReadCloser interface {
    Reader
    Closer
}

type ReadWriteCloser interface {
    Reader
    Writer
    Closer
}
```

**Incorrect (large, monolithic interface):**

```go
type DataStore interface {
    // Too many methods - hard to implement, hard to test
    Get(key string) ([]byte, error)
    Set(key string, value []byte) error
    Delete(key string) error
    List() ([]string, error)
    Count() (int, error)
    Clear() error
    Backup(path string) error
    Restore(path string) error
    Stats() (Statistics, error)
}
```

**Better (split into focused interfaces):**

```go
type Store interface {
    Get(key string) ([]byte, error)
    Set(key string, value []byte) error
    Delete(key string) error
}

type Lister interface {
    List() ([]string, error)
}

type BackupRestore interface {
    Backup(path string) error
    Restore(path string) error
}
```

### Define Interfaces at Usage Site

Define interfaces in the package that uses them, not the package that implements
them. This is called "consumer-side interface definition."

**Why:** This keeps packages focused, reduces coupling, and lets each consumer
define exactly the interface they need.

**Correct:**

```go
// Package storage (consumer)
package storage

// Storage defines what this package needs from a cache.
// Implementations might use Redis, Memcached, or in-memory storage.
type Cache interface {
    Get(key string) ([]byte, error)
    Set(key string, value []byte) error
}

type UserStore struct {
    cache Cache  // Depends on interface
}

// Package redis (provider)
package redis

// Client implements storage.Cache (implicitly)
type Client struct { ... }

func (c *Client) Get(key string) ([]byte, error) { ... }
func (c *Client) Set(key string, value []byte) error { ... }
// Client may have other methods not in storage.Cache
```

**Incorrect:**

```go
// Package cache (provider)
package cache

// Don't define interfaces in the provider package
type Cache interface {
    Get(key string) ([]byte, error)
    Set(key string, value []byte) error
}

type Redis struct { ... }
```

### Accept Interfaces, Return Structs

**Rule of thumb:** Functions should accept interfaces (flexible) and return
concrete types (clear).

**Correct:**

```go
// Accept interface - callers can provide any implementation
// Return concrete type - callers know exactly what they're getting
func NewServer(db Database, cache Cache) *Server {
    return &Server{
        db:    db,
        cache: cache,
    }
}
```

**Why return concrete types:**

- Clear about capabilities and guarantees
- Can add methods without breaking compatibility
- Easier to work with (direct access to all methods)
- Lets consumers define their own interfaces

**Exception:** Sometimes returning an interface is appropriate:

- Standard library interfaces (io.Reader, io.Writer)
- When hiding implementation is critical (security, plugins)
- When you might return different concrete types

**Example exception:**

```go
// Appropriate to return interface
func NewLogger(cfg Config) Logger {
    if cfg.Type == "json" {
        return &JSONLogger{...}
    }
    return &TextLogger{...}
}
```

### Interface Naming

**Single-method interfaces:** Method name + "-er" suffix

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Writer interface {
    Write(p []byte) (n int, err error)
}

type Stringer interface {
    String() string
}
```

**Multi-method interfaces:** Descriptive name

```go
type Database interface {
    Query(sql string) (Rows, error)
    Exec(sql string) error
}

type FileSystem interface {
    Open(name string) (File, error)
    Stat(name string) (FileInfo, error)
}
```

### Empty Interface

Use `interface{}` (or `any` in Go 1.18+) sparingly. It defeats type safety.

**Correct (specific types):**

```go
func ProcessUser(u *User) error { ... }
func FormatValue(v fmt.Stringer) string { ... }
```

**Acceptable uses of empty interface:**

```go
// JSON encoding - needs to handle any type
func json.Marshal(v any) ([]byte, error)

// Generic container before generics
type Cache struct {
    data map[string]any
}

// After Go 1.18, use generics instead:
type Cache[T any] struct {
    data map[string]T
}
```
