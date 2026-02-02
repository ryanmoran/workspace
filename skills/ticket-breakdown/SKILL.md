---
name: ticket-breakdown
description: Use when asked to break down a ticket or feature specification into smaller implementable issues for independent completion by agents
---

# Ticket Breakdown

## Overview

**Systematic approach to decomposing large feature specifications into focused, independent issues.**
Creates a structured set of issue files that enable parallel work by multiple agents while maintaining
clear dependencies.

## When to Use

Use this skill when:

- Asked to "break down a ticket" or "create issues"
- Given a large feature specification (TICKET.md, feature doc)
- Need to split work into parallelizable units
- Starting implementation of multi-component features
- Project uses issues/ directory for work tracking

**Don't use when:**

- Feature is already small enough for single implementation session
- No formal issue tracking structure needed
- Working on ad-hoc fixes or single-file changes
- Ticket has fewer than 3 distinct implementation steps

## Core Pattern

**Without this skill:**

```text
User: "Break down this ticket"
Agent: Creates files ISSUE-001.md, ISSUE-002.md...
      Prescriptive implementation instructions
      No clear dependencies or sequence
      Incompatible with issue-management expectations
```

**With this skill:**

```text
User: "Break down this ticket"
Agent: 1. Read and understand ticket requirements
       2. Consult architecture docs
       3. Design issue structure with phases
       4. Create issues/ directory structure
       5. Write README.md with dependencies
       6. Create individual ISSUE-*.md files
       7. Focus on WHAT and WHY, not HOW
       8. Lint/format with rumdl
```

## Breakdown Process

### Step 1: Understand Requirements

**Read the ticket thoroughly:**

- What is the feature or capability?
- What are the acceptance criteria?
- What are the technical constraints?
- What existing patterns should be followed?

**Consult architecture documentation:**

- Read `AGENTS.md` for repository conventions
- Check `docs/architecture/` for system design
- Review `docs/guides/` for implementation workflows
- Look at similar existing implementations as reference

### Step 2: Design Issue Structure

**Identify natural boundaries:**

- Database changes (migrations, schema)
- API contracts (protobuf, REST definitions)
- Implementation layers (datastore, domain, request handlers)
  - Each layer includes its own tests
- Service wiring and integration
  - Includes integration/end-to-end tests
- Documentation updates

**Do NOT create separate testing issues.** Testing is part of implementing each layer, not a separate phase.

**Common issue structure pattern:**

```text
Phase 1: Foundation
├── Database migration
└── API definitions (protobuf/contract)

Phase 2: Implementation Layers
├── Datastore layer (SQL queries + tests)
├── Domain layer (business logic + tests)
├── Request handlers (validation/coordination + tests)
└── Service layer (wiring + integration tests)

Phase 3: Documentation
└── Documentation updates
```

**CRITICAL: Tests are NOT separate issues.** Each implementation issue includes writing and verifying tests
for that layer. The agent implementing a feature should write tests when writing the implementation code,
following test-driven development practices.

**Define clear dependencies:**

- Each issue should list what it depends on
- Dependencies should form a DAG (no cycles)
- Document which issues can be done in parallel

### Step 3: Create Directory Structure

**Required files:**

```text
issues/
├── README.md              # Overview, phases, dependencies
├── .status.json           # DO NOT CREATE - issue-management skill creates this
├── ISSUE-001-name.md      # Individual issues
├── ISSUE-002-name.md
└── ...
```

**CRITICAL: Do not create `.status.json`**

The `issue-management` skill expects to create and own the `.status.json` file. Creating it yourself
will cause conflicts. The issue-management skill will initialize it when an agent first works on an
issue.

### Step 4: Write README.md

**README.md structure:**

```markdown
# [Feature Name] Implementation Issues

## Overview

[Brief description of overall feature]

## Implementation Order

[List all issues with phases and dependencies]

### Phase 1: [Phase Name]

1. **[ISSUE-001: Title](ISSUE-001-file.md)**
   - [One-line description]
   - **Depends on**: Nothing / ISSUE-XXX

### Phase 2: [Phase Name]

...

## Key Features

[Bullet list of what the feature provides]

## Design Decisions

[Important architectural or technical choices]

## Testing Strategy

[How the feature will be tested]

## Common Patterns

[Existing patterns this follows]

## Acceptance Criteria

[Overall completion criteria with checkboxes]
```

**Key points:**

- Clear overview of the entire feature
- Sequential numbering with descriptive filenames
- Explicit dependency declarations
- Group related issues into phases
- Link to each issue file

### Step 5: Write Individual Issue Files

**Each ISSUE-*.md structure:**

```markdown
# ISSUE-XXX: [Clear Title]

## Summary

[One-sentence description of what this issue accomplishes]

## Context

[Why this work is needed, how it fits into the larger feature]

## Requirements

[High-level requirements this issue must satisfy]
[Include testing requirements - tests must be written with implementation]

## Key Information

[Technical details, schemas, APIs, patterns to follow]
[References to existing code or documentation]
[Data structures, algorithms, validation rules]

## Technical Notes

[Implementation hints without being prescriptive]
[Commands to run, tools to use]
[Files to look at as examples]

## Related Files

[Files that will be created or modified]
[Existing files to reference]

## Acceptance Criteria

- [ ] [Implementation complete]
- [ ] [Tests written and passing]
- [ ] [All existing tests pass]
- [ ] [Linting passes]
```

**Focus on WHAT and WHY, not HOW:**

❌ **Too prescriptive (BAD):**

```markdown
## Implementation Steps

1. Create a file called `create.go` in `requests/`
2. Define a struct: `type Create struct { pool dbx.Transactor }`
3. Add method: `func (c Create) Handle(ctx context.Context...`
```

✅ **Information-focused (GOOD):**

```markdown
## Key Information

Request handlers coordinate validation and transactions:

- Validate input from protobuf messages
- Begin database transaction
- Call domain logic and datastore methods
- Return protobuf response types

See existing example: `internal/locations/requests/create.go`

## Technical Notes

- Request handlers live in `internal/*/requests/`
- Use `dbx.Transactor` for transaction management
- Follow existing patterns from Locations service
```

**Let programmers discover the implementation approach by:**

- Providing context and requirements
- Pointing to architectural documentation
- Referencing similar existing code
- Explaining patterns and conventions
- Describing validation rules and business logic

### Step 6: Ensure Testing Integration

**CRITICAL: Every implementation issue must include testing.**

When writing issue files, ensure acceptance criteria explicitly require tests:

```markdown
## Acceptance Criteria

- [ ] Implementation complete
- [ ] Unit tests written for all new code
- [ ] All tests passing (including existing tests)
- [ ] Code formatted and linted
```

**Never create issues like:**

- ❌ "ISSUE-007: Write Unit Tests"
- ❌ "ISSUE-008: Add Integration Tests"
- ❌ "ISSUE-009: Test Coverage"

**Instead, integrate testing into implementation issues:**

- ✅ "ISSUE-004: Implement Domain Layer" (includes unit tests in acceptance criteria)
- ✅ "ISSUE-006: Service Layer Wiring" (includes integration tests in acceptance criteria)

**Rationale:** Agents should write tests when they write implementation code, following test-driven
development. Separating testing into its own issue creates technical debt and encourages writing tests
after the fact, which is less effective.

### Step 7: Format with rumdl

**After creating all markdown files:**

```bash
rumdl issues/*.md
```

This lints and formats the markdown files to ensure consistency.

## Issue Naming Conventions

**Filename format:** `ISSUE-XXX-descriptive-name.md`

- Sequential numbering (001, 002, 003...)
- Descriptive kebab-case name
- Reflects what the issue does

**Examples:**

- ✅ `ISSUE-001-database-migration.md`
- ✅ `ISSUE-003-datastore-layer.md`
- ✅ `ISSUE-007-unit-tests.md`
- ❌ `ISSUE-001.md` (not descriptive)
- ❌ `issue-1-db.md` (wrong format)

**Title format:** `ISSUE-XXX: [Action Verb] [Object]`

- ✅ `ISSUE-001: Create Asset Table Migration`
- ✅ `ISSUE-004: Implement Domain Layer`
- ❌ `ISSUE-001: Asset Table` (no action)

## Compatibility with issue-management Skill

**The issue-management skill expects:**

1. **issues/ directory** with README.md and ISSUE-*.md files ✅
2. **README.md** with overview, phases, and dependencies ✅
3. **Clear dependencies** between issues documented ✅
4. **Acceptance criteria** in each issue for verification ✅
5. **No .status.json file** initially - issue-management creates this ✅

**Your issues must include:**

- Explicit "Depends on" declarations in README.md
- Acceptance criteria checkboxes in each issue
- Clear, testable outcomes
- References to verification commands (tests, linting)

**Do NOT include:**

- `.status.json` file (issue-management creates and owns this)
- Status tracking in issue files (tracked separately)
- Prescriptive implementation steps (let programmers discover)

## Common Mistakes

| Mistake                              | Fix                                                    |
| ------------------------------------ | ------------------------------------------------------ |
| Creating .status.json yourself       | Don't create it - issue-management skill owns this     |
| Too prescriptive about code          | Focus on requirements, context, and what to reference  |
| No clear dependencies                | Explicitly state dependencies in README.md             |
| Mixing multiple layers in one issue  | Separate by architectural layer or component           |
| Missing acceptance criteria          | Include testable checkboxes for verification           |
| No reference to architecture docs    | Always consult and reference docs/                     |
| Generic "implement X" without detail | Provide schemas, APIs, validation rules, context       |
| Skipping rumdl formatting            | Always lint/format markdown files                      |
| Separate testing issues              | Tests must be part of implementation issues, not separate |

## Quick Reference

```text
Read ticket + architecture docs
  ↓
Design phases and dependencies
  ↓
Create issues/ directory
  ↓
Write README.md (overview, phases, dependencies)
  ↓
Write ISSUE-*.md files (WHAT/WHY, not HOW)
  ↓
Run rumdl for formatting
  ↓
Commit and push
```

## Example Issue Dependencies

```markdown
## Implementation Order

### Phase 1: Foundation

1. **[ISSUE-001: Database Migration](ISSUE-001-database-migration.md)**
   - Create asset table
   - **Depends on**: Nothing

2. **[ISSUE-002: Protobuf Definitions](ISSUE-002-protobuf-definitions.md)**
   - Define API contract
   - **Depends on**: Nothing (parallel with ISSUE-001)

### Phase 2: Implementation

3. **[ISSUE-003: Datastore Layer](ISSUE-003-datastore-layer.md)**
   - SQL queries and DB operations with database tests
   - **Depends on**: ISSUE-001 (needs table schema)

4. **[ISSUE-004: Domain Layer](ISSUE-004-domain-layer.md)**
   - Business logic with unit tests
   - **Depends on**: ISSUE-003 (needs datastore interface)

5. **[ISSUE-005: Request Handlers](ISSUE-005-request-handlers.md)**
   - Request validation and coordination with unit tests
   - **Depends on**: ISSUE-004 (needs domain layer)

6. **[ISSUE-006: Service Layer](ISSUE-006-service-layer.md)**
   - Service wiring with integration tests
   - **Depends on**: ISSUE-005 (needs handlers)

### Phase 3: Documentation

7. **[ISSUE-007: Documentation](ISSUE-007-documentation.md)**
   - Update guides and architecture docs
   - **Depends on**: ISSUE-006 (needs complete implementation)
```

## Brainstorming Before Breakdown

**CRITICAL:** Before creating any issues, use the brainstorming skill to think through the design:

- What are the major components?
- How do they interact?
- What are the dependencies?
- What are potential issues or edge cases?
- What existing patterns should be followed?

This planning ensures a coherent breakdown that makes sense architecturally.

## After Creating Issues

**Commit the work:**

```bash
git add issues/
git commit -m "Break down [Feature Name] ticket into implementation issues"
git push
```

**Report to user:**

- Number of issues created
- Phases identified
- Note that they can start work with "work on the next issue"

**Do NOT:**

- Start implementing issues immediately
- Create .status.json file
- Mark issues as started or in progress

The breakdown is complete. Implementation happens separately using the issue-management skill.
