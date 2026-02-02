---
title: Performance Optimization
impact: LOW
impactDescription: Optimize after measuring; premature optimization wastes time
tags: performance, optimization, profiling, efficiency
---

## Performance Optimization

Optimize code only after measuring and identifying actual bottlenecks. Premature
optimization is a common source of complexity without benefit.

**Golden rule:** Make it work, make it right, make it fast (in that order).

### Measure Before Optimizing

Use Go's profiling tools to identify real bottlenecks.

**CPU profiling:**

```go
import _ "net/http/pprof"

func main() {
    go func() {
        http.ListenAndServe("localhost:6060", nil)
    }()
    // Your application code
}
```

Then: `go tool pprof http://localhost:6060/debug/pprof/profile?seconds=30`

**Benchmark tests:**

```go
func BenchmarkSum(b *testing.B) {
    for i := 0; i < b.N; i++ {
        sum(100, 200)
    }
}

// Run: go test -bench=. -benchmem
```

**Why measure first:**

- Intuition about performance is often wrong
- Optimization adds complexity
- Focus effort where it actually matters

### Efficient String Building

Use `strings.Builder` for concatenating multiple strings.

**Correct (efficient):**

```go
var sb strings.Builder
for _, s := range items {
    sb.WriteString(s)
}
result := sb.String()
```

**Incorrect (inefficient - creates new string each iteration):**

```go
var result string
for _, s := range items {
    result += s  // O(n²) - each += allocates a new string
}
```

**Benchmark difference:** For 1000 items, `strings.Builder` is 100x faster and
uses 99% less memory.

### Slice Preallocation

Preallocate slices when the size is known or can be estimated.

**Correct (preallocate):**

```go
// When size is known
items := make([]Item, 0, expectedSize)
for i := 0; i < expectedSize; i++ {
    items = append(items, createItem(i))
}

// When size can be estimated
items := make([]Item, 0, len(input))  // Estimate based on input
for _, data := range input {
    if shouldInclude(data) {
        items = append(items, process(data))
    }
}
```

**Acceptable (size unknown):**

```go
var items []Item  // Start with nil slice
for _, data := range input {
    items = append(items, process(data))
}
```

**Why it matters:** Without preallocation, slice grows by doubling capacity,
causing multiple allocations and copies.

### Value vs Pointer Receivers

Use value receivers for types that won't be mutated. Use pointer receivers when
mutation is needed.

**Value receiver (good for small, immutable types):**

```go
type Point struct {
    X, Y int
}

// Value receiver - Point is small (16 bytes)
func (p Point) Distance(other Point) float64 {
    dx := p.X - other.X
    dy := p.Y - other.Y
    return math.Sqrt(float64(dx*dx + dy*dy))
}
```

**Pointer receiver (good for types requiring mutation):**

```go
type Config struct {
    // Many fields, large struct
    Settings map[string]string
    Cache    *Cache
    Logger   *Logger
}

// Pointer receiver - avoid copying large struct
func (c *Config) UpdateSetting(key, value string) {
    c.Settings[key] = value  // Also mutates
}
```

**Rule of thumb:**

- Types without mutation → value receiver
- Types that need mutation → pointer receiver
- Mixed (some mutate, some don't) → use pointer receiver for consistency

### Map vs Slice for Lookups

Use maps for O(1) lookups, slices only when there are very few items.

**Correct (use map for lookups):**

```go
// Build map for repeated lookups
userMap := make(map[string]*User, len(users))
for _, user := range users {
    userMap[user.ID] = user
}

// O(1) lookups
if user, ok := userMap[id]; ok {
    process(user)
}
```

**Incorrect (repeated linear search):**

```go
// O(n) every time - slow for large slices
for _, user := range users {
    if user.ID == id {
        process(user)
        break
    }
}
```

**Crossover point:** Maps are typically faster for > 10-20 items with repeated
lookups.

### Cache Expensive Computations

Cache results of expensive operations when they're called repeatedly with the
same inputs.

**Correct (cache expensive operations):**

```go
type Calculator struct {
    cache map[string]int
    mu    sync.RWMutex
}

func (c *Calculator) ExpensiveComputation(input string) int {
    // Check cache first
    c.mu.RLock()
    if result, ok := c.cache[input]; ok {
        c.mu.RUnlock()
        return result
    }
    c.mu.RUnlock()

    // Compute
    result := expensiveOperation(input)

    // Store in cache
    c.mu.Lock()
    c.cache[input] = result
    c.mu.Unlock()

    return result
}
```

**Consider TTL for caches:**

```go
type CacheEntry struct {
    Value  int
    Expiry time.Time
}

func (c *Calculator) Get(input string) (int, bool) {
    c.mu.RLock()
    entry, ok := c.cache[input]
    c.mu.RUnlock()

    if !ok || time.Now().After(entry.Expiry) {
        return 0, false
    }
    return entry.Value, true
}
```

### Avoid Unnecessary Allocations

Reuse buffers and objects when possible.

**Correct (reuse buffer):**

```go
type Processor struct {
    buffer []byte
}

func (p *Processor) Process(data []byte) []byte {
    // Reuse buffer if large enough
    if cap(p.buffer) < len(data) {
        p.buffer = make([]byte, len(data))
    }
    p.buffer = p.buffer[:len(data)]

    // Process data into buffer
    copy(p.buffer, data)
    transform(p.buffer)
    return p.buffer
}
```

**sync.Pool for frequently allocated objects:**

```go
var bufferPool = sync.Pool{
    New: func() interface{} {
        return new(bytes.Buffer)
    },
}

func process(data []byte) []byte {
    buf := bufferPool.Get().(*bytes.Buffer)
    defer bufferPool.Put(buf)

    buf.Reset()
    buf.Write(data)
    // Process buffer
    return buf.Bytes()
}
```

### Range Loop Performance

**Avoid copying large structs in range loops:**

```go
// Good - iterate over pointers or indices
for i := range items {
    process(&items[i])
}

// Or if items is []*Item
for _, item := range items {
    process(item)  // Already a pointer
}

// Avoid - copies each struct
type LargeStruct struct {
    // Many fields
}

items := []LargeStruct{...}
for _, item := range items {  // Copies entire struct each iteration
    process(item)
}
```

### When to Optimize

**Optimize when:**

- Profiling shows a clear bottleneck
- Performance is measurably inadequate
- You have specific performance requirements (latency, throughput)
- The optimization is simple and doesn't sacrifice clarity

**Don't optimize when:**

- Performance is already adequate
- Code is in a cold path (rarely executed)
- Optimization significantly hurts readability
- You haven't measured the impact

**Document performance-critical code:**

```go
// This loop is in the hot path and processes millions of items.
// Benchmarked optimization shows 10x improvement over map lookup.
// See benchmark: BenchmarkProcessItems
for i := 0; i < len(items); i++ {
    // Optimized implementation
}
```
