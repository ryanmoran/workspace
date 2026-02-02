---
title: Testing Best Practices
impact: MEDIUM
impactDescription: General principles for writing maintainable tests
tags: best-practices, isolation, error-testing, test-data
---

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

### Testing Checklist

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
