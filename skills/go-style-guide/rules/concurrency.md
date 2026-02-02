---
title: Concurrency Patterns
impact: MEDIUM
impactDescription: Enables safe concurrent code and prevents race conditions
tags: concurrency, goroutines, channels, context, synchronization
---

## Concurrency Patterns

Write concurrent code using idiomatic Go patterns with channels, goroutines, and
context.

### Idiomatic Channel Usage

Use channels for communication and synchronization between goroutines.

**Key principles:**

- Sender closes channels, not receivers
- Closing is optional (channels can be left open)
- Only close if receivers need to know there's no more data
- Never close a channel from the receiver side
- Never close a channel more than once

**Correct (sender closes):**

```go
func generate(nums ...int) <-chan int {
    out := make(chan int)
    go func() {
        defer close(out)  // Sender closes
        for _, n := range nums {
            out <- n
        }
    }()
    return out
}

func square(in <-chan int) <-chan int {
    out := make(chan int)
    go func() {
        defer close(out)  // This function is the sender for 'out'
        for n := range in {
            out <- n * n
        }
    }()
    return out
}

// Usage - pipeline pattern
func main() {
    nums := generate(2, 3, 4)
    squared := square(nums)

    for result := range squared {
        fmt.Println(result)  // 4, 9, 16
    }
}
```

**Incorrect:**

```go
func process(in <-chan int) {
    for n := range in {
        fmt.Println(n)
    }
    close(in)  // ERROR: Receiver shouldn't close!
}
```

### Buffered Channels

Use buffered channels to prevent blocking when appropriate.

**Unbuffered channel (synchronous):**

```go
// Sender blocks until receiver reads
ch := make(chan int)
```

**Buffered channel (asynchronous up to capacity):**

```go
// Sender doesn't block until buffer is full
ch := make(chan int, 10)
```

**When to use buffered channels:**

- Known producer/consumer capacity difference
- Want to avoid blocking on send
- Implementing a worker pool with fixed capacity
- Limiting concurrent operations

**Example:**

```go
// Limit concurrent API calls
type APIClient struct {
    limiter chan struct{}  // Semaphore pattern
}

func NewAPIClient(maxConcurrent int) *APIClient {
    return &APIClient{
        limiter: make(chan struct{}, maxConcurrent),
    }
}

func (c *APIClient) Call(endpoint string) error {
    c.limiter <- struct{}{}        // Acquire
    defer func() { <-c.limiter }() // Release

    // Make API call
    return callAPI(endpoint)
}
```

### Context for Cancellation

Always pass `context.Context` as the first parameter for cancellable operations.

**Correct:**

```go
func processItems(ctx context.Context, items []Item) error {
    for _, item := range items {
        // Check for cancellation
        select {
        case <-ctx.Done():
            return ctx.Err()  // Return cancellation/timeout error
        default:
            if err := process(ctx, item); err != nil {
                return err
            }
        }
    }
    return nil
}

// Usage
ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
defer cancel()

err := processItems(ctx, items)
```

**Pattern for long-running work:**

```go
func worker(ctx context.Context) error {
    ticker := time.NewTicker(1 * time.Second)
    defer ticker.Stop()

    for {
        select {
        case <-ctx.Done():
            return ctx.Err()
        case <-ticker.C:
            // Do periodic work
            if err := doWork(ctx); err != nil {
                return err
            }
        }
    }
}
```

### Minimize Shared State

Prefer message passing (channels) over shared memory when possible.

**Good (message passing):**

```go
type Counter struct {
    ops chan func(*int)
}

func NewCounter() *Counter {
    c := &Counter{
        ops: make(chan func(*int)),
    }
    go c.run()
    return c
}

func (c *Counter) run() {
    var count int
    for op := range c.ops {
        op(&count)  // All access in single goroutine - no race!
    }
}

func (c *Counter) Increment() {
    c.ops <- func(count *int) { *count++ }
}

func (c *Counter) Get() int {
    result := make(chan int)
    c.ops <- func(count *int) { result <- *count }
    return <-result
}
```

**Acceptable (mutex for shared state):**

```go
type Counter struct {
    mu    sync.Mutex
    count int
}

func (c *Counter) Increment() {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.count++
}

func (c *Counter) Get() int {
    c.mu.Lock()
    defer c.mu.Unlock()
    return c.count
}
```

**Incorrect (race condition):**

```go
type Counter struct {
    count int  // No protection!
}

func (c *Counter) Increment() {
    c.count++  // RACE CONDITION if called from multiple goroutines
}
```

### WaitGroups for Goroutine Coordination

Use `sync.WaitGroup` to wait for multiple goroutines to complete.

**Correct:**

```go
func processAll(items []Item) error {
    var wg sync.WaitGroup
    errs := make(chan error, len(items))

    for _, item := range items {
        wg.Add(1)
        go func(item Item) {
            defer wg.Done()
            if err := process(item); err != nil {
                errs <- err
            }
        }(item)  // Pass as parameter to avoid capture issues
    }

    wg.Wait()
    close(errs)

    // Check for errors
    for err := range errs {
        if err != nil {
            return err
        }
    }
    return nil
}
```

**Common mistake:**

```go
// WRONG - variable capture problem
for _, item := range items {
    wg.Add(1)
    go func() {
        defer wg.Done()
        process(item)  // All goroutines might use same 'item'!
    }()
}
```

### sync.Once for One-Time Initialization

Use `sync.Once` for lazy initialization or one-time setup.

**Correct:**

```go
type Service struct {
    once   sync.Once
    client *Client
}

func (s *Service) getClient() *Client {
    s.once.Do(func() {
        s.client = newClient()  // Only runs once
    })
    return s.client
}
```

### Select for Multiple Channel Operations

Use `select` to wait on multiple channel operations.

**Correct:**

```go
func worker(ctx context.Context, jobs <-chan Job, results chan<- Result) {
    for {
        select {
        case <-ctx.Done():
            return
        case job, ok := <-jobs:
            if !ok {
                return  // Jobs channel closed
            }
            results <- process(job)
        }
    }
}
```

**Pattern for timeout:**

```go
select {
case result := <-ch:
    return result, nil
case <-time.After(5 * time.Second):
    return nil, errors.New("timeout")
case <-ctx.Done():
    return nil, ctx.Err()
}
```

### Don't Leak Goroutines

Ensure goroutines can exit when work is done or cancelled.

**Correct (goroutine can exit):**

```go
func process(ctx context.Context) error {
    done := make(chan bool)

    go func() {
        defer close(done)
        for {
            select {
            case <-ctx.Done():
                return  // Goroutine exits
            default:
                doWork()
            }
        }
    }()

    <-done
    return nil
}
```

**Incorrect (goroutine leaks):**

```go
func process() error {
    go func() {
        for {
            doWork()  // No way to stop this!
        }
    }()
    return nil
}
```
