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

## Quick Reference by Test Type

| Test Type | Priority | Purpose | Rule File |
|-----------|----------|---------|-----------|
| Unit Tests | CRITICAL | Test business logic in isolation | `unit-tests.md` |
| Database Tests | HIGH | Verify SQL queries with real PostgreSQL | `database-tests.md` |
| Integration Tests | HIGH | Test full request-to-response flow | `integration-tests.md` |
| Assertions | CRITICAL | Use require for assertions | `assertions.md` |
| Organization | MEDIUM | Structure and naming conventions | `test-organization.md` |
| Best Practices | MEDIUM | General testing principles | `best-practices.md` |

## How to Use

Read individual rule files for detailed patterns, examples, and pitfalls:

```text
rules/unit-tests.md
rules/database-tests.md
rules/integration-tests.md
rules/assertions.md
rules/test-organization.md
rules/best-practices.md
```

Each rule file contains:

- Impact level and description
- Purpose and characteristics
- Complete code examples
- Key patterns to follow
- Common pitfalls to avoid

## Progressive Application

Apply these guidelines progressively based on the layer you're testing:

**Domain/Request layer**: Start with `unit-tests.md` for fast, isolated tests with mocks

**Datastore layer**: Use `database-tests.md` for SQL verification with real PostgreSQL

**End-to-end scenarios**: Apply `integration-tests.md` for full service testing

**All tests**: Follow `assertions.md` and `best-practices.md` across all layers

## Related Patterns

- **Three-Layer Service**: Architecture that defines what to test at each layer
- **Dependency Injection**: Enables mock-based testing
- **Interface-Based Testing**: Use interfaces for all dependencies
- **Test-Driven Development**: Write tests first, implementation second

## References

- [Counterfeiter](https://github.com/maxbrunsfeld/counterfeiter)
- [Testify](https://github.com/stretchr/testify)
- [Testcontainers](https://golang.testcontainers.org/)
