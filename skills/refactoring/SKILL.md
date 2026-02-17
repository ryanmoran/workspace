---
name: refactoring
description: "Use when refactoring existing code that lacks tests, has unclear structure, or shows code smells. Applies safety-first, incremental refactoring to codebases without breaking functionality."
---

# Code Refactoring

## Overview

This skill provides a disciplined, safety-first approach to refactoring code you didn't write and may not fully understand. Unlike greenfield development where you can be bold, refactoring requires caution, testing, and incremental progress.

**Core Principle:** Never refactor without a safety net. Always work in small, testable steps.

## When to Use This Skill

Use this skill when:

- Refactoring code without adequate test coverage
- Working with unfamiliar or poorly documented code
- Code shows clear code smells (duplication, complexity, coupling)
- Preparing code for new features or bug fixes
- Code is frequently modified and causing problems

**Do NOT use this skill for:**

- New code you're currently writing (use TDD skill instead)
- Code with comprehensive test coverage (standard refactoring is fine)
- Trivial changes (renaming variables, fixing typos)
- Emergency bug fixes (fix first, refactor later)

## The Four Phases

### Phase 1: Understand & Assess

Before touching any code, invest time understanding what you're working with. **This phase ends with explaining your plan to the user and getting approval before implementation.**

#### 1.1 Exploration (Time Box: 30 minutes)

**Map the territory:**

- Read the code thoroughly
- Trace execution paths from entry points
- Identify dependencies (imports, global state, database calls)
- Note side effects (I/O, mutations, external calls)
- Document areas of confusion

**Tools to use:**

- `lsp_references` - Find where functions/types are used
- `grep` - Search for patterns across the codebase
- `git log` and `git blame` - Understand change history
- Manual tracing - Follow the code execution mentally

#### 1.2 Identify Code Smells

Systematically check for these categories:

**Bloaters** (code grown too large):

- Long Method (>20-30 lines)
- Large Class (>200-300 lines, multiple responsibilities)
- Long Parameter List (>3-4 parameters)
- Primitive Obsession (using primitives instead of small objects)
- Data Clumps (same group of variables appearing together)

**Change Preventers** (changes require many edits):

- Shotgun Surgery (one change requires edits across many files)
- Divergent Change (one class changes for different reasons)
- Parallel Inheritance Hierarchies (adding subclass requires changes elsewhere)

**Dispensables** (unnecessary code):

- Duplicate Code (same structure in multiple places)
- Dead Code (unused functions, variables, parameters)
- Speculative Generality (unused abstractions "for future use")
- Lazy Class (class doing too little to justify existence)

**Couplers** (excessive dependencies):

- Feature Envy (method uses data from another class more than its own)
- Inappropriate Intimacy (classes too coupled to each other's internals)
- Message Chains (a.getB().getC().doSomething())
- Middle Man (class just delegates to another class)

#### 1.3 Justify the Refactoring

Answer these questions before proceeding:

1. **Business Value:**
   - What problem does this refactoring solve?
   - Will this reduce bugs, enable features, or improve velocity?

2. **Priority:**
   - Is this code touched frequently? (high priority)
   - Is it rarely changed? (low priority)

3. **Rule of Three:**
   - Does duplication appear 3+ times?
   - If only 2 instances, wait for the third (avoid premature abstraction)

4. **Cost vs. Benefit:**
   - How long will refactoring take?
   - What's the maintenance cost of NOT refactoring?

**DECISION POINT:** If no clear justification exists, STOP. Document why refactoring isn't needed and move on.

#### 1.4 Explain Refactoring Plan & Get Approval

Before proceeding to implementation, present your refactoring plan to the user:

**Structure your explanation:**

1. **Code Smells Identified:**
   - List the specific smells found (e.g., "Long Method in ProcessOrder (185 lines)")
   - Indicate severity and impact on maintainability

2. **Proposed Refactoring Approach:**
   - Which techniques you'll apply (e.g., "Extract Method for validation, calculation, and persistence")
   - Order of operations (which refactorings first)
   - Expected intermediate states

3. **Testing Strategy:**
   - How you'll build the safety net (characterization tests, test islands, etc.)
   - Estimated test coverage before refactoring begins

4. **Estimated Scope:**
   - How many files/functions will be affected
   - Approximate time to complete (based on Phase 1 exploration)
   - Whether this is incremental (partial) or complete refactoring

**Format:**

```markdown
## Refactoring Plan

### Code Smells Found
- [List specific smells with locations]

### Proposed Changes
- [Describe refactoring techniques to apply]
- [Show order of operations]

### Testing Strategy
- [Explain how safety net will be built]

### Scope & Effort
- Files affected: X
- Estimated time: Y hours
- Approach: [Incremental/Complete]

### Risks & Mitigations
- [Any concerns about the refactoring]
- [How you'll handle them]
```

**CRITICAL: STOP and ask for user approval before proceeding to Phase 2.**

Say: "Should I proceed with this refactoring plan?"

Wait for user confirmation before continuing to Phase 2.

### Phase 2: Build Safety Net

Never refactor code without tests. This phase is non-negotiable.

#### 2.1 Testing Strategy

Apply these strategies in order until you have adequate coverage:

**Strategy 1: Characterization Tests**

Document current behavior as-is (bugs and all):

```go
// Characterization test - documents existing behavior
func TestFunction_ExistingBehavior(t *testing.T) {
    // Input -> Output mapping
    result := Function("input")
    require.Equal(t, "observed output", result)

    // Edge cases (even if they seem wrong)
    result = Function("")
    require.Equal(t, "weird behavior", result) // TODO: fix in future
}
```

**Key points:**

- Capture what the code DOES, not what it SHOULD do
- Test edge cases and error paths
- Mark known bugs with TODO comments
- Don't fix bugs yet - just document behavior

**Strategy 2: Approval Tests**

For complex outputs (JSON, HTML, reports):

```go
func TestComplexFunction_ApprovalTest(t *testing.T) {
    result := ComplexFunction(input)

    // First run: capture the output as baseline
    // Subsequent runs: compare against baseline
    goldenFile := "testdata/complex_function.golden"

    // Compare result with golden file
    // (Use library like github.com/sebdah/goldie)
}
```

**Strategy 3: Test Islands (for untestable code)**

When code is too tangled to test:

1. **Extract small testable function:**

   ```go
   // Before: large untestable function
   func BigUntestableFunction() {
       // 200 lines of tangled code
       x := someCalculation()
       // more tangled code
   }

   // After: extract testable piece
   func CalculateValue(input int) int {
       return input * 2 + 10
   }

   func BigUntestableFunction() {
       // 198 lines of tangled code
       x := CalculateValue(5)
       // more tangled code
   }
   ```

2. **Test the extracted function:**

   ```go
   func TestCalculateValue(t *testing.T) {
       require.Equal(t, 20, CalculateValue(5))
   }
   ```

3. **Gradually expand tested territory** - repeat extraction

**Strategy 4: Emergency Rescue Pattern**

For truly impossible-to-test functions:

1. **Ignore the old function** - don't try to test it
2. **Write test for function you WISH existed:**

   ```go
   func TestNewCleanFunction(t *testing.T) {
       result := NewCleanFunction(input)
       require.Equal(t, expected, result)
   }
   ```

3. **Implement new function** that passes the test
4. **Replace all call sites** (search and replace)
5. **Delete old function**

#### 2.2 Safety Checklist

Before refactoring, verify:

- [ ] Tests exist and pass
- [ ] Tests run quickly (< 5 minutes for relevant suite)
- [ ] Have git checkpoint (committed working state)
- [ ] Know how to rollback changes
- [ ] Understand what the code is supposed to do

**If checklist fails:** Invest more time in Phase 2 before proceeding.

### Phase 3: Refactoring Execution

Now you can safely modify code. Work in tiny, atomic steps.

#### 3.1 The Atomic Refactoring Loop

Each cycle takes 5-15 minutes:

1. **Pick ONE refactoring technique** (see catalog below)
2. **Apply smallest possible step** (change 1-5 lines)
3. **Run tests immediately**
4. **If tests pass:** Commit with descriptive message
5. **If tests fail:** Understand why, fix, or rollback
6. **Repeat**

**Critical rules:**

- Only one technique per cycle
- Keep tests green at all times
- Commit after every successful change
- Never skip steps or batch changes

#### 3.2 Refactoring Catalog

Choose the appropriate technique for each smell:

**For Long Method:**

1. **Extract Method** (primary)
   - Identify cohesive block of code
   - Extract into named function
   - Replace original code with function call

   ```go
   // Before
   func ProcessOrder(order Order) {
       // validation
       if order.Total < 0 { return error }
       // calculation
       tax := order.Total * 0.08
       total := order.Total + tax
       // persistence
       db.Save(order)
   }

   // After
   func ProcessOrder(order Order) {
       if err := validateOrder(order); err != nil { return err }
       total := calculateTotal(order)
       return saveOrder(order, total)
   }
   ```

2. **Replace Temp with Query**
   - Convert temporary variable to function call
   - Improves clarity and reusability

3. **Decompose Conditional**
   - Extract complex conditionals into named functions

**For Large Class:**

1. **Extract Class** (primary)
   - Identify cohesive group of fields/methods
   - Create new class for that responsibility
   - Move fields and methods to new class

2. **Extract Subclass**
   - When class has behavior used only in some cases
   - Create subclass for specialized behavior

**For Duplicate Code:**

1. **Extract Method/Function** (primary)
   - Pull duplicate code into shared function
   - Replace all occurrences with function call

2. **Pull Up Method** (if in class hierarchy)
   - Move duplicate method to parent class

3. **Form Template Method**
   - Create template in parent with variable steps in children

**For Long Parameter List:**

1. **Introduce Parameter Object** (primary)

   ```go
   // Before
   func CreateUser(name, email, phone, address, city, state, zip string) {}

   // After
   type UserInfo struct {
       Name, Email, Phone string
       Address Address
   }
   func CreateUser(info UserInfo) {}
   ```

2. **Preserve Whole Object**
   - Pass entire object instead of multiple fields

**For Feature Envy:**

1. **Move Method** (primary)
   - Move method to the class it's most interested in
   - May need Extract Method first to isolate the envious part

**For Switch Statements:**

1. **Replace Conditional with Polymorphism** (primary)

   ```go
   // Before
   func GetPrice(product Product) float64 {
       switch product.Type {
       case "book": return product.BasePrice * 0.9
       case "electronics": return product.BasePrice * 1.1
       default: return product.BasePrice
       }
   }

   // After (interface + implementations)
   type Pricer interface {
       GetPrice() float64
   }

   type Book struct { BasePrice float64 }
   func (b Book) GetPrice() float64 { return b.BasePrice * 0.9 }

   type Electronics struct { BasePrice float64 }
   func (e Electronics) GetPrice() float64 { return e.BasePrice * 1.1 }
   ```

2. **Replace Type Code with State/Strategy**

**For Primitive Obsession:**

1. **Replace Data Value with Object** (primary)

   ```go
   // Before
   type Order struct {
       PhoneNumber string // "555-1234"
   }

   // After
   type PhoneNumber struct {
       CountryCode string
       AreaCode    string
       Number      string
   }

   func (p PhoneNumber) Format() string { /* ... */ }
   func (p PhoneNumber) Validate() error { /* ... */ }

   type Order struct {
       Phone PhoneNumber
   }
   ```

**For Dead Code:**

1. **Delete it** - No alternative, just remove it
   - Use `lsp_references` to confirm nothing uses it
   - Remove the code completely
   - Commit with message documenting what was removed

**For Message Chains:**

1. **Hide Delegate**

   ```go
   // Before
   manager := employee.GetDepartment().GetManager()

   // After (add method to Employee)
   func (e Employee) GetManager() Manager {
       return e.department.manager
   }
   manager := employee.GetManager()
   ```

#### 3.3 Using gopls for Go Refactoring

The Go language server (`gopls`) provides automated refactoring capabilities that can safely transform code. These tools are available through editors that support LSP (Language Server Protocol).

**Advantages of gopls refactorings:**

- **Safety:** Updates all references across the codebase
- **Accuracy:** Handles edge cases you might miss manually
- **Speed:** Instant transformations across multiple files

**Key gopls refactoring capabilities:**

**Extraction Operations (`refactor.extract`):**

1. **Extract Function/Method** (`refactor.extract.function`, `refactor.extract.method`)
   - Select statements within a function
   - Gopls creates a new function/method with appropriate parameters and return values
   - Replaces selection with function call
   - Use for: Breaking up long methods, isolating logic for testing

2. **Extract Variable/Constant** (`refactor.extract.variable`, `refactor.extract.constant`)
   - Select an expression
   - Gopls creates a new variable/constant initialized with that expression
   - Replaces expression with variable reference
   - Use for: Naming complex expressions, avoiding duplication

3. **Extract Variable (All Occurrences)** (`refactor.extract.variable-all`)
   - Replaces ALL occurrences of an expression with a single variable
   - Use for: Eliminating duplicate calculations, improving DRY

4. **Extract to New File** (`refactor.extract.toNewFile`)
   - Select top-level declarations (types, functions, constants)
   - Gopls moves them to a new file with necessary imports
   - Use for: Splitting large files, organizing by responsibility

**Inlining Operations (`refactor.inline`):**

1. **Inline Function Call** (`refactor.inline.call`)
   - Replaces function call with the function's body
   - Preserves behavior (handles side effects, parameter substitution)
   - Use for: Removing unnecessary abstractions, simplifying single-use functions

2. **Inline Variable** (`refactor.inline.variable`)
   - Replaces variable reference with its initializer expression
   - Use for: Removing unnecessary intermediate variables

**Code Rewriting (`refactor.rewrite`):**

1. **Remove Unused Parameter** (`refactor.rewrite.removeUnusedParam`)
   - Removes unused function parameters
   - Updates all callers automatically
   - Preserves side effects in argument expressions
   - Use for: Cleaning up function signatures

2. **Move Parameters** (`refactor.rewrite.moveParamLeft`, `refactor.rewrite.moveParamRight`)
   - Reorders function parameters
   - Updates all call sites
   - Use for: Grouping related parameters, following conventions

3. **Fill Struct Literal** (`refactor.rewrite.fillStruct`)
   - Populates missing struct fields
   - Uses heuristics for field values (matches names, falls back to zero values)
   - Use for: Discovering available fields, ensuring initialization

4. **Fill Switch** (`refactor.rewrite.fillSwitch`)
   - Adds missing cases for enum types or type switches
   - Use for: Exhaustive case handling

5. **Change Quote Style** (`refactor.rewrite.changeQuote`)
   - Converts between raw (`` ` ``) and interpreted (`"`) string literals
   - Use for: Avoiding escape sequences, multiline strings

6. **Invert If Condition** (`refactor.rewrite.invertIf`)
   - Negates condition and swaps if/else blocks
   - Use for: Reducing nesting, early returns

7. **Split/Join Lines** (`refactor.rewrite.splitLines`, `refactor.rewrite.joinLines`)
   - Formats composite literals, function calls, signatures, and results
   - Use for: Readability, following style guidelines

8. **Add/Remove Struct Tags** (`refactor.rewrite.addTags`, `refactor.rewrite.removeTags`)
   - Manages JSON struct tags on fields
   - Use for: API serialization, configuration structs

9. **Eliminate Dot Import** (`refactor.rewrite.eliminateDotImport`)
   - Removes dot imports and qualifies all package uses
   - Use for: Improving code clarity, avoiding name collisions

**When to use gopls refactorings in the refactoring workflow:**

- **Phase 2 (Safety Net):** Use Extract Function to create test islands from untestable code
- **Phase 3 (Execution):** Use gopls for mechanical transformations (extract, inline, rename)
- **After manual extraction:** Use Fill Struct to discover what parameters should be in parameter objects
- **Code cleanup:** Use Remove Unused Parameter after refactoring reduces dependencies

**Limitations to be aware of:**

- Some transformations may lose comments (verify and restore if needed)
- Generated files are excluded (won't transform `*.pb.go` or similar)
- Complex extractions might need manual adjustment after gopls creates initial version
- Always run tests after gopls refactorings (they're safe but not infallible)

**Integration with the Atomic Refactoring Loop:**

```text
1. Pick ONE refactoring (e.g., "Extract validation logic")
2. Use gopls to extract function (automated, safe)
3. Run tests immediately
4. If tests pass: Commit
5. If tests fail: Review gopls output, adjust if needed, or rollback
6. Repeat
```

Gopls refactorings accelerate the loop by automating mechanical transformations, letting you focus on design decisions rather than manual code editing.

#### 3.4 Special Techniques

**For truly untestable code (Emergency Rescue Pattern):**

See Phase 2.1 Strategy 4 - write the function you wish existed, test it, replace old code.

**For complex dependencies:**

1. **Extract Interface** first
2. **Inject dependencies** (make them explicit parameters)
3. **Then refactor** the implementation

**For God Objects (>500 lines):**

1. **Don't refactor everything** at once
2. **Identify one responsibility** to extract
3. **Apply Extract Class** for that responsibility only
4. **Repeat** in future sessions for other responsibilities

#### 3.5 Commit Strategy

Commit after every successful refactoring:

```bash
git commit -m "refactor: Extract validateOrder from ProcessOrder

Moved order validation logic into separate function for clarity
and testability. No behavior change - all tests pass."
```

**Commit message format:**

- Start with `refactor:`
- Describe WHAT was changed
- Explain WHY briefly
- Note "No behavior change" if applicable

### Phase 4: Completion & Validation

Verify the refactoring accomplished its goals.

#### 4.1 Post-Refactoring Checklist

- [ ] All tests pass
- [ ] No new linter warnings (`golangci-lint run` for Go)
- [ ] Test coverage maintained or increased
- [ ] Manual smoke test of affected features
- [ ] No performance regressions (if performance-sensitive code)

#### 4.2 Code Quality Review

Ask yourself:

1. **Readability:** Is the code easier to understand?
2. **Responsibilities:** Are concerns properly separated?
3. **Future changes:** Would adding features be easier now?
4. **Duplication:** Did we remove meaningful duplication?
5. **Simplicity:** Is the code simpler (not just different)?

#### 4.3 Documentation Updates

- Update comments if behavior is now clearer
- Document discovered edge cases
- Note limitations that weren't fixed (with TODO/FIXME)
- Update architecture docs if significant structure changed

#### 4.4 When to Stop

Stop refactoring when:

- Original code smell is resolved
- Tests are green and coverage is adequate
- Code is "good enough" (don't over-engineer)
- Time box reached (can continue in next iteration)
- Diminishing returns (further changes have minimal benefit)

**Remember:** Perfect is the enemy of good. Incremental improvement is the goal.

## Anti-Patterns: What NOT to Do

### Violations (Never Do This)

**NEVER:**

1. **Refactor without tests**
   - Violation: Changing code structure without safety net
   - Consequence: Silent bugs, broken behavior
   - Fix: Go back to Phase 2, build tests first

2. **Change behavior while refactoring**
   - Violation: Fixing bugs during refactoring
   - Consequence: Can't tell if tests fail due to refactoring or fix
   - Fix: Separate commits - refactor first, THEN fix bugs

3. **Refactor code you don't understand**
   - Violation: Skipping Phase 1 exploration
   - Consequence: Breaking subtle behaviors, removing "weird" code that was intentional
   - Fix: Spend more time in Phase 1, ask questions

4. **Batch many changes together**
   - Violation: Applying multiple techniques before testing
   - Consequence: When tests fail, can't isolate which change broke it
   - Fix: Smaller steps, test after each change

5. **Ignore failing tests "temporarily"**
   - Violation: Continuing refactoring with red tests
   - Consequence: Compounding failures, lost confidence
   - Fix: Stop immediately, fix or rollback

6. **Skip commits between working states**
   - Violation: Making many changes before committing
   - Consequence: Hard to rollback to working state
   - Fix: Commit after every green test run

### Warning Signs (Stop and Reassess)

**STOP if:**

1. **Tests keep breaking**
   - Sign: More than 2-3 test failures in a row
   - Action: Need better safety net, return to Phase 2

2. **Changes cascade beyond expected scope**
   - Sign: "Just need to change one more thing..." repeatedly
   - Action: May need different approach or smaller scope

3. **Unclear what code should do**
   - Sign: Can't write tests because don't know expected behavior
   - Action: Return to Phase 1, need more exploration

4. **Fighting the code's design**
   - Sign: Refactoring feels forced, creating more complexity
   - Action: May need architectural change (Ship of Theseus pattern)

5. **Time exceeded expectations by >2x**
   - Sign: "Should take 30 min" but 2 hours in
   - Action: Reassess scope, may need to break into smaller pieces

## Ship of Theseus: When to Replace Instead of Refactor

For massive code that resists refactoring:

### Signs You Need Replacement

- Refactoring would touch >80% of code
- Architectural mismatch (wrong patterns for current needs)
- Missing modern capabilities (security, performance, scalability)
- Would take months to refactor incrementally

### Progressive Replacement Pattern

1. **Create new implementation alongside old**
2. **Write tests for new implementation**
3. **Introduce proxy/router** that can direct traffic
4. **Migrate one feature at a time** to new implementation
5. **Run both systems in parallel** during migration
6. **Remove old code** once fully migrated

**Benefits:**

- Incremental migration (lower risk)
- Can rollback feature-by-feature
- Continuous delivery throughout process
- Faster feedback than big-bang rewrite

## Quick Reference

### Decision Tree

```text
Need to change code?
│
├─ Code has good tests?
│  ├─ Yes → Standard refactoring (not this skill)
│  └─ No → Continue
│
├─ Understand the code?
│  ├─ No → Phase 1: Explore (30 min time box)
│  └─ Yes → Continue
│
├─ Code smells present?
│  ├─ No → Maybe refactoring isn't needed
│  └─ Yes → Continue
│
├─ Refactoring justified? (business value, Rule of 3, etc.)
│  ├─ No → Document why, move on
│  └─ Yes → Continue
│
├─ Explain plan to user and get approval
│  ├─ No approval → Stop
│  └─ Approved → Continue
│
├─ Tests exist?
│  ├─ No → Phase 2: Build safety net (characterization tests)
│  └─ Yes → Continue
│
├─ Tests pass?
│  ├─ No → Fix tests first
│  └─ Yes → Phase 3: Refactor (atomic loops)
│
└─ Phase 4: Validate and commit
```

### Time Estimates

- **Phase 1 (Explore & Plan):** 30-60 minutes (includes explaining plan to user)
- **Phase 2 (Safety Net):** 1-3 hours (depends on complexity)
- **Phase 3 (Refactor):** 2-8 hours (depends on scope)
- **Phase 4 (Validate):** 15-30 minutes

**Total:** Half-day to full-day for typical refactoring

## Common Scenarios

### Scenario 1: "Spaghetti Function" (200+ lines, no tests)

1. **Explore:** Trace execution, identify responsibilities
2. **Safety Net:** Use Test Islands - extract 3-4 small functions, test them
3. **Refactor:** Gradually extract more functions, each tested
4. **Result:** Network of small, tested functions replacing monolith

### Scenario 2: "Mysterious Bug in Code"

1. **DON'T refactor yet** - fix bug first
2. **Write test** that reproduces bug
3. **Fix bug** (minimal change)
4. **THEN refactor** using this skill (now have test safety net)

### Scenario 3: "Copy-Pasted Code Everywhere" (5+ duplicates)

1. **Identify most stable version** (fewest bugs reported)
2. **Write characterization tests** for that version
3. **Extract function** from that version
4. **Replace call sites one at a time** (commit between each)
5. **Test each replacement** before moving to next

### Scenario 4: "God Object" (800 lines, 30 methods)

1. **DON'T try to refactor everything**
2. **Pick ONE responsibility** to extract (e.g., validation)
3. **Extract Class** for that responsibility only
4. **Stop when that extraction is complete**
5. **Later:** Return for another responsibility

## Resources

See `references/` directory for:

- `code-smells-catalog.md` - Comprehensive smell descriptions
- `refactoring-techniques.md` - Detailed technique examples
- `testing-strategies.md` - Test pattern examples

## Summary

Refactoring is about **safety, discipline, and incremental progress**:

1. **Understand first** (exploration, smell identification)
2. **Test second** (safety net is non-negotiable)
3. **Refactor third** (atomic steps, always green)
4. **Validate last** (quality check, documentation)

Never skip phases. Never refactor without tests. Never batch changes.

**The Iron Law of Refactoring:** If you don't have tests, you're not refactoring - you're just rearranging deck chairs on the Titanic.
