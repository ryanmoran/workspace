---
name: development-workflow
description: Use when starting work on features, bugs, or significant changes requiring multiple commits and coordination of design, implementation, testing, and documentation
---

# Development Workflow

## Overview

**Coordinate design, implementation, refinement, documentation, and review into a cohesive development process.**

Development is not linear - it's iterative. Good development alternates between building and refining, with documentation and testing integrated throughout.

## When to Use

**Use this skill when:**

- Starting a new feature or significant change
- Working on bugs that need design thinking
- Any work spanning multiple commits
- Coordinating brainstorming, TDD, and documentation

**Don't use for:**

- Trivial one-line fixes
- Emergency hotfixes (go direct to TDD)
- Throwaway prototypes

## The Development Cycle

Development follows five phases that may repeat:

```dot
digraph dev_cycle {
    rankdir=LR;
    design [label="DESIGN\nUnderstand & plan", shape=box, style=filled, fillcolor="#e6f3ff"];
    implement [label="IMPLEMENT\nBuild with TDD", shape=box, style=filled, fillcolor="#ccffcc"];
    refine [label="REFINE\nSimplify & improve", shape=box, style=filled, fillcolor="#fff4cc"];
    document [label="DOCUMENT\nExplain & guide", shape=box, style=filled, fillcolor="#ffe6cc"];
    review [label="REVIEW\nVerify quality", shape=box, style=filled, fillcolor="#ffcccc"];

    design -> implement;
    implement -> refine;
    refine -> document;
    document -> review;
    review -> implement [label="need changes"];
    review -> design [label="major issues"];
}
```

### Phase 1: DESIGN

**Goal:** Understand what to build before building it.

**For complex work:**

- Use brainstorming skill for design exploration
- Write design doc: `docs/plans/YYYY-MM-DD-topic-design.md`
- Commit design before implementing
- Break down plan into bd epic and issues:
  ```bash
  # Create epic for the feature
  bd create "Feature name from plan" -t epic -p 1 --json
  
  # Create issues for each major component/phase
  bd create "Implement component X" --parent <epic-id> -p 1 --json
  bd create "Add tests for Y" --parent <epic-id> -p 1 --json
  bd create "Document feature" --parent <epic-id> -p 2 --json
  ```

**For simpler work:**

- Write brief plan in issue tracker (bd)
- List components that need changes
- Identify edge cases upfront

**Outputs:**

- Design document OR
- Detailed issue description
- bd epic with subtasks (for complex work)
- Mental checklist of requirements

### Phase 2: IMPLEMENT

**Goal:** Build the feature test-first, incrementally using outside-in development.

**Process:**

- Use test-driven-development skill (REQUIRED)
- Build outside-in: integration test → unit tests → implementation
  1. **Start with failing integration test** - specify the public API
  2. **Let the integration test guide you** - it reveals what components you need
  3. **Write unit tests** for those components
  4. **Implement** to make unit tests pass
  5. **Return to integration test** - it should eventually pass
- Make small, focused commits
- Each commit should have single clear purpose

**Outside-in flow:**

```
Integration Test (failing)
    ↓
  Reveals: "Need component X"
    ↓
Unit Tests for X (failing)
    ↓
Implement X (unit tests pass)
    ↓
Repeat for components Y, Z...
    ↓
Integration Test (passing)
```

**The integration test stays red** until all components are implemented - this is expected and normal.

**Commit patterns:**

```bash
# ✅ Good: Focused, clear
"Implement loader.go with file discovery and parsing"
"Add integration tests for config file loading"

# ❌ Bad: Too large, vague
"Add configuration feature"
"Update everything"
```

**Commit frequency:**

- After completing each logical unit (function, module, test suite)
- When switching contexts (implementation → refactoring)
- Before taking breaks (save progress)

**Outputs:**

- Working, tested code
- Multiple small commits
- All tests passing

### Phase 3: REFINE

**Goal:** Simplify and improve without adding features.

**Look for:**

- Custom code that could use stdlib
- Functions that could be inlined
- Duplicate logic that could be shared
- Complex code that could be clearer

**Process:**

- Make one refinement at a time
- Keep tests green throughout
- Commit each refinement separately

**Example refinements:**

```bash
# Real examples from contagent/1510:
"Replace cutEnv with strings.Cut"
"Inline buildVolumes function and remove function definition"
"Refactor expand_test.go to use t.Run subtests"
```

**When to stop:**

- Code is as simple as you can make it
- No obvious improvements remain
- You're about to add features (stop, that's Phase 2)

**Outputs:**

- Simpler, clearer code
- Same functionality
- More focused commits

### Phase 4: DOCUMENT

**Goal:** Explain what you built and how to use it.

**Update as you go:**

- README sections affected by changes
- Example config files
- Inline code comments (sparingly, focus on WHY)
- Architecture docs if structure changed

**What to document:**

```markdown
# ✅ Document:

- What the feature does (user perspective)
- How to configure/use it
- Examples of common use cases
- Configuration options and defaults

# ❌ Don't document:

- How the code works (code should be self-explanatory)
- What each function does (obvious from names)
- Implementation details users don't need
```

**Outputs:**

- Updated README
- Example configurations
- Updated architecture docs if needed

### Phase 5: REVIEW

**Goal:** Verify quality and completeness before finishing.

**For significant features:**

- Create REVIEW.md with detailed analysis
- Focus on: clarity, correctness, potential bugs
- Include file:line references
- Commit the review document

**For all work:**

```markdown
## Quality Checklist

- [ ] All tests pass
- [ ] Test coverage comprehensive (happy path + edge cases + errors)
- [ ] Documentation updated
- [ ] Code simplified (no unnecessary complexity)
- [ ] Commit messages clear
- [ ] Issues referenced in commits
- [ ] No TODOs or placeholders left behind
```

**Outputs:**

- REVIEW.md (for significant features)
- Completed checklist
- Clean, shippable code

## Iteration and Refinement

**Development is iterative:**

1. Initial implementation → refine → refine again
2. Discover issue during review → back to implement
3. Realize design needs adjustment → back to design

**This is normal and expected.**

The cutEnv example from contagent/1510 shows healthy iteration:

- Commit 1: Custom cutEnv implementation
- Commit 2: Replace with strings.Cut
- Commit 3: Inline strings.Cut calls
- Commit 4: Remove cutEnv entirely

Five commits to simplify one helper. That's not waste - that's refinement.

## Integration with Issue Tracking

**Use bd (beads) for all work:**

```bash
# Start work
bd ready                           # Find unblocked work
bd update bd-42 --status in_progress

# During work - reference in commits
git commit -m "Implement X

Closes bd-42"

# Complete work
bd close bd-42 --reason "Completed"
git add .beads/issues.jsonl
git commit -m "Update issue tracking"
```

**Commit issue state changes with code changes** - keeps them in sync.

## Common Mistakes

| Mistake                 | Impact                              | Fix                                         |
| ----------------------- | ----------------------------------- | ------------------------------------------- |
| **Skip design**         | Build wrong thing, rework later     | Use brainstorming skill for complex work    |
| **Large commits**       | Hard to review, hard to revert      | Commit after each logical unit              |
| **Defer documentation** | Never gets done, or rushed and poor | Document as you go, update with each change |
| **Skip refinement**     | Accumulate technical debt           | Always refactor after features work         |
| **No code review**      | Miss bugs, unclear code ships       | Create REVIEW.md for significant features   |
| **Forget issue refs**   | Lose traceability                   | Reference issues in commit messages         |
| **Tests after code**    | Not following TDD                   | Use test-driven-development skill           |

## Skill Integration

This workflow coordinates other skills:

- **REQUIRED:** test-driven-development for all implementation
- **RECOMMENDED:** brainstorming for complex features
- **OPTIONAL:** writing-skills if creating process docs

## Example: Adding Config File Support

Real example from contagent/1510 (simplified):

**DESIGN:**

- Created PLAN.md documenting architecture
- Identified components: loader, merger, expander, integration

**IMPLEMENT:**

- 10 commits building bottom-up:
  - loader.go with tests
  - merge.go with tests
  - expand.go with tests
  - Integration with existing code
  - CLI flag handling
  - Error handling improvements

**REFINE:**

- 5 commits simplifying:
  - Replace custom helpers with stdlib
  - Inline small functions
  - Refactor tests to use subtests

**DOCUMENT:**

- 2 commits adding docs:
  - Comprehensive README section
  - Example .contagent.yaml file

**REVIEW:**

- 1 commit with detailed REVIEW.md
- Identified bugs and improvements

**Total: 18 focused commits over iterative development.**

## Quick Reference

| Phase         | Output                       | Key Tool                      |
| ------------- | ---------------------------- | ----------------------------- |
| **Design**    | PLAN.md or issue description | brainstorming skill           |
| **Implement** | Working, tested code         | test-driven-development skill |
| **Refine**    | Simplified code              | Small focused commits         |
| **Document**  | Updated README, examples     | Markdown, comments            |
| **Review**    | REVIEW.md, quality checks    | Manual review                 |

## The Bottom Line

**Development is not a waterfall - it's a rhythm.**

Design → Implement → Refine → Document → Review → Repeat.

Small commits. Test-first. Simplify continuously. Document as you go. Review before finishing.

This rhythm produces high-quality, maintainable code iteratively.
