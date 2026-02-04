---
name: code-review
description: "Comprehensive code review skill for AI agents reviewing Git branches. Performs multi-layer analysis including architecture compliance, code quality, testing strategy, and style guidelines. Use when asked to review code changes, perform code review, or analyze a branch for merge readiness."
---

# Code Review Skill

## Overview

This skill guides AI agents through comprehensive code reviews of Git branches. Unlike traditional PR-based reviews, this skill operates on local branches and produces structured review reports covering architecture compliance, code quality, testing, and style.

## When to Use

Apply this skill when:

- Asked to "review this code" or "perform code review"
- Analyzing changes on a branch before merge
- Evaluating code quality and merge readiness
- Checking architectural compliance of changes
- Reviewing test coverage and quality

## Core Principles

Based on industry best practices from Google, InfoQ, and Palantir:

1. **Improve code health** - Changes should make the codebase better, not perfect
2. **Maintain velocity** - Complete reviews efficiently, avoid endless iterations
3. **Be constructive** - Focus on code, not coder; explain reasoning
4. **Catch real issues** - Prioritize bugs, design problems, security over style nitpicks
5. **Teach and mentor** - Use reviews as learning opportunities

## Review Workflow

### Phase 1: DISCOVER

**Objective**: Understand what changed and why

1. **Ask user for base branch** (typically `main`, `master`, or `develop`)

   ```text
   "What's the base branch to compare against?"
   ```

2. **Gather change information**

   ```bash
   # Get commit history
   git log <base>..HEAD --oneline

   # Get overall diff stats
   git diff <base>...HEAD --stat

   # Get file change types
   git diff <base>...HEAD --name-status

   # View full diff
   git diff <base>...HEAD
   ```

3. **Infer intent from commits**
   - Parse commit messages (feat:, fix:, refactor:, etc.)
   - Look for issue numbers (#123)
   - Examine file names and patterns
   - Check for documentation changes

4. **Check for architecture documentation**

   ```bash
   # Find docs directories
   find . -type d -name "doc*" -o -name "architecture" -o -name "design" 2>/dev/null

   # Look for architecture files
   find ./docs -name "*architecture*" -o -name "*design*" -o -name "ADR*" 2>/dev/null
   ```

5. **Read relevant documentation**
   - `./docs/architecture.md` - Overall architecture
   - `./docs/design/` - Design documents
   - `./docs/ADR/` - Architecture Decision Records
   - `ARCHITECTURE.md` - Root-level architecture docs

### Phase 2: UNDERSTAND

**Objective**: Build context about the codebase and changes

1. **Read all changed files**
   - Use `view` tool to read each modified/added file
   - Understand current implementation
   - Note any obvious issues

2. **Identify architecture layer** (for layered architectures)
   - Requests/handlers layer
   - Domain/business logic layer
   - Datastores/persistence layer
   - Infrastructure/utilities

3. **Search for related patterns**

   ```bash
   # Find similar implementations
   grep -r "similar_function" --include="*.go"

   # Check for existing tests
   find . -name "*_test.go" -path "*/changed_area/*"
   ```

4. **Check existing test coverage**
   - Identify which test files exist
   - Note testing patterns used
   - Check if changed code has tests

### Phase 3: ANALYZE

**Objective**: Evaluate code quality across multiple dimensions

#### 3.1 Architecture Compliance

**Check if changes align with documented architecture**

- **Layer violations**
  - Datastores should not import domain code
  - Requests should not bypass domain layer
  - No circular dependencies between layers

- **Technology constraints**
  - Using approved libraries only
  - Following documented patterns (e.g., raw SQL vs ORM)
  - No deprecated dependencies

- **API contracts**
  - No breaking changes to public APIs
  - Proto/schema files updated if needed
  - Endpoint naming follows conventions

- **Data model alignment**
  - Schema changes have migration scripts
  - Changes documented in data model docs
  - Foreign key relationships preserved

- **Security/compliance**
  - Authentication/authorization checks present
  - Audit logging included where required
  - No secrets in code

**Severity levels:**

- **BLOCKING**: Violates documented architectural constraints, breaks API contracts, introduces forbidden dependencies
- **SUGGESTED**: Documentation should be updated, alternative approach more aligned
- **INFO**: New pattern worth documenting, related ADR exists for reference

#### 3.2 General Code Quality

**Design and complexity:**

- Does the change fit well with existing code?
- Is it over-engineered or unnecessarily complex?
- Could it be simpler while still being correct?
- Are edge cases handled?

**Functionality:**

- Does the code do what it's supposed to?
- Are there obvious bugs?
- What about error cases?
- Are there race conditions or concurrency issues?

**Security:**

- Are inputs validated?
- Are errors handled without leaking sensitive info?
- Are there SQL injection or other vulnerability risks?
- Are secrets properly managed?

**Performance:**

- Any obvious performance bottlenecks?
- Unnecessary allocations or copies?
- Inefficient algorithms?
- Database query optimization needed?

#### 3.3 Go-Specific Analysis (apply go-style-guide skill)

**Read and apply relevant Go style guide rules:**

1. **Formatting** (`go-style-guide/rules/formatting-gofmt.md`)

   ```bash
   # Verify gofmt compliance
   gofmt -l .
   ```

2. **Naming conventions** (`go-style-guide/rules/naming-conventions.md`)
   - MixedCaps, not snake_case
   - Context-aware names
   - Concise but clear

3. **Error handling** (`go-style-guide/rules/error-handling-basics.md`)
   - Errors wrapped with context
   - Sentinel errors defined properly
   - Error messages informative

4. **Package design** (`go-style-guide/rules/package-design.md`)
   - Minimal dependencies
   - Focused purpose
   - Clean imports

5. **Documentation** (`go-style-guide/rules/documentation.md`)
   - Exported items documented
   - Comments explain "why" not "what"
   - Package docs present

#### 3.4 Test Quality Analysis (apply testing skill)

**Read and apply relevant testing rules:**

1. **Identify appropriate test type** for each layer:
   - **Domain/requests**: Unit tests with mocks (`testing/rules/unit-tests.md`)
   - **Datastores**: Database tests with real PostgreSQL (`testing/rules/database-tests.md`)
   - **End-to-end**: Integration tests (`testing/rules/integration-tests.md`)

2. **Check assertions** (`testing/rules/assertions.md`)
   - Must use `require` not `assert`
   - Fail fast on errors

3. **Verify test organization** (`testing/rules/test-organization.md`)
   - Proper naming conventions
   - Table-driven tests where appropriate
   - Clear test structure

4. **Apply best practices** (`testing/rules/best-practices.md`)
   - Tests are deterministic
   - No flaky tests
   - Tests cover edge cases
   - Error paths tested

#### 3.5 Code Smells Analysis (apply refactoring skill)

**Systematically evaluate code for common smells from refactoring skill:**

1. **Check for Bloaters** (code grown too large)
   - **Long Method**: Functions >20-30 lines doing multiple things
   - **Large Class**: Classes >200-300 lines with multiple responsibilities
   - **Long Parameter List**: Functions with >3-4 parameters
   - **Primitive Obsession**: Using primitives instead of domain objects
   - **Data Clumps**: Same variables appearing together repeatedly

2. **Check for Object-Orientation Abusers**
   - **Switch Statements**: Complex switch/case chains based on type codes
   - **Temporary Field**: Fields only used in certain circumstances
   - **Refused Bequest**: Subclasses using only fraction of inherited methods

3. **Check for Change Preventers**
   - **Divergent Change**: Class commonly changed for different reasons
   - **Shotgun Surgery**: Single change requires edits across many classes
   - **Parallel Inheritance Hierarchies**: Adding subclass requires changes elsewhere

4. **Check for Dispensables** (unnecessary code)
   - **Duplicate Code**: Same structure in multiple places (Rule of 3)
   - **Dead Code**: Unused functions, variables, parameters (use `lsp_references`)
   - **Speculative Generality**: Unused abstractions "for future use"
   - **Lazy Class**: Class doing too little to justify existence
   - **Comments**: Excessive comments explaining bad code

5. **Check for Couplers** (excessive dependencies)
   - **Feature Envy**: Method uses data from another class more than its own
   - **Inappropriate Intimacy**: Classes too coupled to each other's internals
   - **Message Chains**: a.getB().getC().doSomething() chains
   - **Middle Man**: Class just delegates to another class

**Reference documentation:**

- See `refactoring/references/code-smells-catalog.md` for detailed descriptions
- See `refactoring/SKILL.md` for refactoring guidance
- Use `lsp_references` to verify dead code
- Look for patterns across changed files

**Severity guidelines:**

- **BLOCKING**: Dead code that confuses, duplicate code causing bugs, extremely long methods (>100 lines)
- **SUGGESTED**: Most code smells (long methods, large classes, feature envy, data clumps)
- **NITS**: Minor duplication (only 2 instances), slight parameter list issues (4 params)

### Phase 4: VERIFY

**Objective**: Run automated checks and tests

1. **Run linters**

   ```bash
   # Use project's golangci-lint config if present
   golangci-lint run

   # Or run gofmt
   gofmt -l .
   ```

2. **Run test suite**

   ```bash
   # Run all tests
   go test ./...

   # Run with race detector
   go test -race ./...

   # Run specific changed packages
   go test ./path/to/changed/package/...
   ```

3. **Check for breaking changes**
   - Use `lsp_references` on changed public functions/types
   - Verify all call sites still work
   - Check if API consumers need updates

4. **Verify test coverage**

   ```bash
   # Check coverage for changed packages
   go test -cover ./path/to/changed/package/...
   ```

### Phase 5: REPORT

**Objective**: Provide structured, actionable feedback

Generate a comprehensive review report following this format:

```markdown
# Code Review: <branch-name>

## Summary

- Base branch: <base>
- Commits: <count>
- Files changed: <X> added, <Y> modified, <Z> deleted
- Language: Go
- Architecture docs reviewed: <list>
- Inferred purpose: <based on commits and changes>

## Architecture Compliance

<Status of architectural alignment>
✅ Follows documented architecture patterns
✅ Dependencies flow in correct direction
⚠️ <Any concerns or missing pieces>

## Findings

### BLOCKING ⛔

<Issues that must be fixed before merge>

- **<Issue title>** (<file>:<line>)
  <Description of the problem>
  See: <reference to docs/rules>
  Fix: <specific actionable fix>

### SUGGESTED 💡

<Improvements that should be considered>

- **<Suggestion title>** (<file>:<line>)
  <Description of improvement>
  See: <reference to docs/rules>
  Consider: <alternative approach>

### CODE SMELLS 👃

<Refactoring opportunities identified>

- **<Smell type>** (<file>:<line>)
  <Description of the smell>
  Impact: <Why this matters>
  See: refactoring/references/code-smells-catalog.md
  Refactor: <Suggested technique from refactoring skill>

### NITS 🔍

<Minor style/convention issues>

- **<Nit title>** (<file>:<line>)
  <Description>
  See: <reference to style guide>

### POSITIVE ✅

<Things done well - be specific>

- <Specific positive callout>
- <Good pattern usage>
- <Well-tested scenario>

## Test Verification

- [ ] Tests exist for new functionality
- [ ] All tests pass
- [ ] Edge cases covered
- [ ] Error paths tested
- [ ] Appropriate test type for layer
- [ ] Using `require` for assertions

## Overall Recommendation

<APPROVE | REQUEST_CHANGES | COMMENT>

<Brief explanation of decision with reasoning>
```

## Feedback Guidelines

### Writing Effective Comments

**Be specific and actionable:**

- ❌ "This is unclear"
- ✅ "Variable name `x` doesn't indicate it holds user IDs. Consider `userID` or `userIDs`"

**Explain the "why":**

- ❌ "Don't use this pattern"
- ✅ "This pattern can cause race conditions because the map is accessed from multiple goroutines without synchronization. Use sync.RWMutex or channels."

**Label severity:**

- **BLOCKING**: Bugs, security issues, architecture violations, broken tests
- **SUGGESTED**: Design improvements, missing tests, documentation gaps
- **NITS**: Style, naming, minor conventions

**Reference documentation:**

- Link to relevant architecture docs
- Cite specific go-style-guide rules
- Reference testing skill rules
- Point to examples in codebase

**Be constructive:**

- Focus on the code, not the developer
- Offer alternatives, not just criticism
- Celebrate good practices
- Use questions when appropriate: "Have you considered...?"

### When to Approve vs Request Changes

**APPROVE if:**

- Code improves overall code health (even if not perfect)
- All blocking issues resolved
- Tests pass and cover new functionality
- Follows architectural constraints
- No security vulnerabilities
- Minor suggestions can be addressed in follow-up

**REQUEST CHANGES if:**

- Bugs or incorrect functionality
- Security vulnerabilities
- Architecture violations
- Broken or missing tests
- Breaking changes without justification
- Significant design problems

**COMMENT (no approval) if:**

- Only informational feedback
- Suggestions for future improvements
- Questions about approach
- Context for other reviewers

## Agent-Specific Capabilities

Leverage these capabilities that humans often skip:

### 1. Comprehensive Cross-Reference Checking

```bash
# Check all usages of changed functions
lsp_references <function_name>

# Find all call sites
grep -r "ChangedFunction" --include="*.go"
```

### 2. Thorough Test Verification

```bash
# Run tests multiple times to check for flakiness
for i in {1..5}; do go test ./...; done

# Run with race detector
go test -race ./...

# Check coverage
go test -cover ./...
```

### 3. Pattern Consistency Checking

```bash
# Find similar error handling patterns
grep -A 3 "if err != nil" path/to/package/*.go

# Check existing implementations
grep -r "similar_pattern" --include="*.go"
```

### 4. Dependency Impact Analysis

```bash
# Check for new dependencies
git diff <base>...HEAD -- go.mod

# Look for dependency version changes
git diff <base>...HEAD -- go.sum
```

## Common Pitfalls to Avoid

### Anti-Patterns

**Bikeshedding**: Don't argue about trivial style choices that don't matter

- ❌ Debating whether to use `i` or `index` in a 3-line loop
- ✅ Focus on meaningful variable names in public APIs

**Perfectionism**: Don't block good changes for minor improvements

- ❌ "This could be 5% more efficient, rewrite it"
- ✅ "Consider this optimization in future if profiling shows it's hot"

**Vagueness**: Don't give unclear feedback

- ❌ "This needs improvement"
- ✅ "This function is 200 lines. Consider extracting the validation logic into a separate function"

**Scope creep**: Don't demand unrelated changes

- ❌ "While you're here, refactor this entire package"
- ✅ "This change looks good. FYI, there's technical debt in this area we should address separately"

**Missing context**: Don't assume intent

- ❌ "Why did you do it this way?" (confrontational)
- ✅ "I notice this uses approach X. Could you explain the reasoning? I'm wondering if approach Y might be simpler"

### Review Blockers

**Don't attempt review if:**

- No changes between branches (`git diff` is empty)
- Branch has unresolved merge conflicts
- Code doesn't compile/build
- Base branch doesn't exist
- Unable to run tests due to missing dependencies

**Report blockers immediately:**

```markdown
# Review Blocked: <reason>

Unable to perform code review due to: <specific blocker>

Required action: <what needs to be fixed>
```

## Integration with Other Skills

### go-style-guide Skill

When reviewing Go code, reference specific rule files:

- `go-style-guide/rules/formatting-gofmt.md` - Formatting issues
- `go-style-guide/rules/naming-conventions.md` - Naming problems
- `go-style-guide/rules/error-handling-basics.md` - Error handling
- `go-style-guide/rules/package-design.md` - Package structure
- `go-style-guide/rules/documentation.md` - Comment quality

Example feedback:

```markdown
### BLOCKING ⛔

- **Error handling violation** (pkg/users/service.go:45)
  Errors not wrapped with context, making debugging difficult
  See: go-style-guide/rules/error-handling-basics.md
  Fix: return fmt.Errorf("failed to get user %d: %w", id, err)
```

### testing Skill

When reviewing tests, reference specific rule files:

- `testing/rules/unit-tests.md` - Unit test patterns
- `testing/rules/database-tests.md` - Database test patterns
- `testing/rules/integration-tests.md` - Integration test patterns
- `testing/rules/assertions.md` - Assertion usage
- `testing/rules/test-organization.md` - Test structure
- `testing/rules/best-practices.md` - General testing principles

Example feedback:

```markdown
### SUGGESTED 💡

- **Test type mismatch** (pkg/users/service_test.go:15)
  Domain layer test using real database instead of mocks
  See: testing/rules/unit-tests.md
  Consider: Use counterfeiter to generate mocks for UserStore interface
```

### refactoring Skill

When identifying code smells, reference the refactoring skill:

- `refactoring/references/code-smells-catalog.md` - Comprehensive smell catalog
- `refactoring/references/refactoring-techniques.md` - How to fix each smell
- `refactoring/SKILL.md` - Safety-first refactoring approach

Example feedback:

```markdown
### CODE SMELLS 👃

- **Long Method** (pkg/orders/processor.go:45)
  ProcessOrder function is 87 lines doing validation, calculation, and persistence
  Impact: Hard to test, understand, and reuse individual pieces
  See: refactoring/references/code-smells-catalog.md#long-method
  Refactor: Extract Method - separate into validateOrder, calculateTotal, and saveOrder

- **Feature Envy** (pkg/invoice/calculator.go:23)
  CalculateTotal uses only Order's data, none of Calculator's fields
  Impact: Method is in wrong place, increases coupling
  See: refactoring/references/code-smells-catalog.md#feature-envy
  Refactor: Move Method to Order class where data lives

- **Duplicate Code** (pkg/users/service.go:45, pkg/users/handler.go:78, pkg/admin/service.go:102)
  Email validation logic appears 3+ times with slight variations
  Impact: Bug fixes must be applied in multiple places, inconsistent behavior
  See: refactoring/references/code-smells-catalog.md#duplicate-code
  Refactor: Extract Method into shared validation package
```

## Quick Reference

### Essential Git Commands

```bash
# Commit history
git log <base>..HEAD --oneline
git log <base>..HEAD --pretty=format:"%h - %s"

# Changes overview
git diff <base>...HEAD --stat
git diff <base>...HEAD --name-status

# Full diff
git diff <base>...HEAD

# Individual commits
git show <commit-hash>

# File history
git log -p <base>..HEAD -- path/to/file
git blame path/to/file
```

### Essential Review Commands

```bash
# Formatting
gofmt -l .

# Linting
golangci-lint run

# Testing
go test ./...
go test -race ./...
go test -cover ./...

# Build verification
go build ./...

# Find patterns
grep -r "pattern" --include="*.go"
find . -name "*_test.go"
```

### Architecture Discovery

```bash
# Find docs
find . -type d -name "doc*" -o -name "architecture"
ls ./docs/
ls ./ARCHITECTURE.md

# Find specific files
find ./docs -name "*architecture*"
find ./docs -name "ADR*"
```

## Success Criteria

A successful code review should:

1. **Catch real issues** - Bugs, security vulnerabilities, design problems
2. **Improve code health** - Changes make codebase better
3. **Maintain velocity** - Complete in reasonable time, not endless iterations
4. **Be educational** - Explain principles, teach patterns
5. **Be actionable** - Clear, specific feedback with references
6. **Be respectful** - Constructive tone, focus on code not coder

## References

- [Google Code Review Guidelines](https://google.github.io/eng-practices/review/reviewer/)
- [InfoQ: Effective Code Reviews](https://www.infoq.com/articles/effective-code-reviews/)
- go-style-guide skill (../go-style-guide/SKILL.md)
- testing skill (../testing/SKILL.md)
