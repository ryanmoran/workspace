---
title: Test Assertions
impact: CRITICAL
impactDescription: Ensures tests fail fast and provide clear error messages
tags: assertions, require, testify
---

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

## Common Pitfall

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

### Use EqualValues when comparing numbers

❌ **Wrong**: Using Equal instead of EqualValues

```go
require.Equal(t, int64(7), actual)
```

✅ **Right**: Always use EqualValues

```go
require.EqualValues(t, 7, actual)
```
