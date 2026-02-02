---
name: go-style-guide
description: Google Go Style Guide for writing clear, idiomatic, and maintainable Go code. Use this skill when writing, reviewing, or refactoring Go code to ensure adherence to Google's best practices. Triggers on tasks involving Go packages, functions, error handling, naming, or performance optimization.
---

# Google Go Style Guide

Comprehensive style guide for Go programming based on Google's engineering
standards. Emphasizes clarity, simplicity, and maintainability through proven
patterns and idioms.

## When to Apply

Reference these guidelines when:

- Writing new Go packages, functions, or types
- Reviewing Go code for style and idiom compliance
- Refactoring existing Go codebases
- Designing APIs and package interfaces
- Handling errors
- Making naming or formatting decisions

## Core Principles (In Priority Order)

The Go Style Guide is built on five fundamental principles that should guide all
decisions:

1. **Clarity** - Code's purpose and rationale must be clear to readers
2. **Simplicity** - Write code in the simplest way possible
3. **Concision** - Maintain high signal-to-noise ratio
4. **Maintainability** - Design code for future modifications
5. **Consistency** - Follow consistent patterns across the codebase

When style choices conflict, prioritize based on this ordering.

## Quick Reference by Category

| Category           | Priority | Key Focus                          | Rule File                     |
|--------------------|----------|------------------------------------|-------------------------------|
| Formatting         | CRITICAL | Use `gofmt` always                 | `formatting-gofmt.md`         |
| Naming             | CRITICAL | MixedCaps, context-aware, concise  | `naming-conventions.md`       |
| Error Handling     | HIGH     | Explicit, idiomatic patterns       | `error-handling-basics.md`    |
| Custom Errors      | MEDIUM   | Sentinel errors, custom types      | `error-handling-custom.md`    |
| Package Design     | HIGH     | Minimal dependencies, focused      | `package-design.md`           |
| Documentation      | MEDIUM   | Explain "why", not "what"          | `documentation.md`            |
| Interfaces         | MEDIUM   | Use sparingly, clear contracts     | `interface-design.md`         |
| Concurrency        | MEDIUM   | Idiomatic channels/goroutines      | `concurrency.md`              |
| Performance        | LOW      | Optimize deliberately when needed  | `performance.md`              |

## How to Use

Read individual rule files for detailed explanations and code examples:

```text
rules/formatting-gofmt.md
rules/naming-conventions.md
rules/error-handling-basics.md
```

Each rule file contains:

- Impact level and description
- Brief explanation of why it matters
- Correct code examples with explanations
- Incorrect code examples with explanations
- Additional context and patterns

## Progressive Application

Apply these guidelines progressively based on task scope:

**New code**: Apply all relevant guidelines from the start

**Code review**: Focus on critical issues (formatting, naming, errors) first

**Refactoring**: Improve incrementally, don't rewrite everything at once

**Legacy code**: Apply style to new code and touched code, not entire codebase

## Additional Resources

- [Official Go Style Guide](https://google.github.io/styleguide/go/)
- [Effective Go](https://go.dev/doc/effective_go)
- [Go Code Review Comments](https://go.dev/wiki/CodeReviewComments)
