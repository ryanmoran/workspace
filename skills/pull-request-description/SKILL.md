# Pull Request Description

```yaml
name: pull-request-description
description: Use when creating a pull request or writing a PR description. Guides the developer through an interactive process to create clear, comprehensive PR descriptions that follow industry best practices.
```

## When to Use

Trigger this skill when:

- User asks to "create a PR"
- User asks to "write a PR description"
- User says "make/open a pull request"
- User asks for help with a PR
- Code is ready for review and needs a PR created

## Core Philosophy

Great PR descriptions make reviews faster, safer, and more effective. They should:

- **Guide reviewers** through the changes
- **Explain motivation** beyond what code reveals
- **Enable testing** with clear steps
- **Be scannable** for quick understanding
- **Assume no prior context** from the reviewer

This skill uses **natural dialogue** to gather context and generate descriptions, not interrogation-style forms.

## Process Flow

### Phase 1: Analyze Current State

Before asking questions, understand what's being proposed:

1. **Check git status**

   ```bash
   git status
   git diff main...HEAD  # or compare against default branch
   git log main..HEAD --oneline
   ```

2. **Identify context clues**
   - Branch name (e.g., `feature/user-auth` → authentication feature)
   - Commit messages (look for issue refs like `fixes #123`)
   - Files changed (UI files → need screenshots, migrations → schema changes)
   - Size of changes (small fix vs large refactor)

3. **Check for linked issues**
   - Look in commit messages for issue references
   - Check if branch name includes ticket number
   - Use `gh issue list --search "text"` if relevant keywords found

### Phase 2: Gather Context Through Dialogue

Ask questions **one at a time**, adapting based on responses and analysis:

#### Essential Questions (Always Ask)

**1. What problem does this solve?** (The "Why")

- For users: "What user problem or need does this address?"
- For technical: "What technical issue or limitation does this fix?"
- For features: "What business goal or requirement drove this?"

Listen for:

- Business motivation
- User stories
- Technical debt reduction
- Bug descriptions
- Performance improvements

**2. How should reviewers test this?** (The "How to Test")

- "What steps should reviewers follow to verify these changes?"
- "Are there specific scenarios or edge cases to test?"
- "What should they see when it works correctly?"

Listen for:

- Commands to run
- URLs to visit
- User flows to exercise
- Expected results
- Required setup (permissions, feature flags, env vars)

#### Conditional Questions (Ask When Relevant)

**For UI changes** (detected: HTML, CSS, JS, React files):

- "Should I include screenshots or a demo GIF?"
- If yes, prompt: "Please provide screenshots or describe what you'd like me to capture"

**For large changes** (>300 lines):

- "Where should reviewers start? Any guidance on review order?"
- "Are there specific files or sections that need extra attention?"

**For breaking changes** (detected: migrations, API changes, config changes):

- "What's the migration path or upgrade process?"
- "Are there backwards compatibility concerns?"

**For security-sensitive code** (detected: auth, permissions, crypto, secrets):

- "Are there security considerations reviewers should focus on?"

**For incomplete work** (TODOs, FIXMEs in diff):

- "I see some TODOs. Are there follow-up tasks or known limitations?"
- "Should we create follow-up issues for these?"

#### What NOT to Ask

- **Don't ask "What changed?"** - You can see the diff
- **Don't ask for commit-by-commit explanations** - Synthesize from analysis
- **Don't ask obvious things** - If the diff shows a bug fix in error handling, don't ask "what's the main change"

### Phase 3: Generate Description

Use this proven template structure:

```markdown
## What

[2-4 sentences explaining the changes clearly and concisely]

**Key changes:**
- [Bullet point: specific change]
- [Bullet point: specific change]
- [Bullet point: specific change]

## Why

[Explain the motivation: business need, user problem, technical debt, bug impact, etc.]

[If relevant: architectural decisions, tradeoffs, or approach rationale]

## How to Test

**Prerequisites:**
- [Any setup needed: feature flags, permissions, env vars, data fixtures]

**Steps:**
1. [Specific, actionable step with commands/URLs]
2. [Expected result or what to verify]
3. [Additional scenarios to test]

**Expected behavior:**
- [What success looks like]
- [Edge cases to verify]

## Screenshots

[If UI changes: include screenshots or note "Coming soon" if needed]

## Related Issues

Closes #[issue]
Relates to #[issue]

## Notes

[Optional section for:]
- [Known limitations or incomplete work]
- [Follow-up tasks needed]
- [Areas requiring careful review]
- [Backwards compatibility notes]
- [Performance implications]
- [Security considerations]

```

#### Writing Principles to Apply

1. **Use active voice**
   - ✅ "This PR adds authentication support"
   - ❌ "Authentication support is added by this PR"

2. **Use simple, clear language**
   - ✅ "Replace slow database query"
   - ❌ "Replace a really slowly performing database query"

3. **Be scannable**
   - Use bullet points for lists
   - Keep paragraphs short (2-4 sentences)
   - Bold key terms or file names
   - Use headings to organize

4. **Be specific, not generic**
   - ✅ "Add JWT-based authentication to API endpoints"
   - ❌ "Add authentication stuff"

5. **Include "Why" context**
   - Don't just describe what changed (code shows that)
   - Explain motivation, impact, and reasoning

6. **Make testing actionable**
   - Specific commands: `npm test` or `go test ./...`
   - Exact URLs: `http://localhost:3000/login`
   - Clear steps: "1. Click login, 2. Enter credentials, 3. Verify redirect"

### Phase 4: Present and Refine

1. **Show the generated description**
   - Present the full markdown
   - Don't ask "does this look good?" - be specific

2. **Ask for targeted feedback**
   - "Does this capture the motivation correctly?"
   - "Are the testing steps clear and complete?"
   - "Anything important I missed?"

3. **Iterate based on feedback**
   - Make adjustments
   - Re-present updated sections
   - Confirm when ready

### Phase 5: Create the Pull Request

1. **Verify branch is pushed**

   ```bash
   git status
   # If not pushed:
   git push -u origin <branch-name>
   ```

2. **Create PR using gh CLI**

   ```bash
   gh pr create --title "Title" --body "$(cat <<'EOF'
   [Generated description here]
   EOF
   )"
   ```

3. **Confirm success**
   - Show PR URL
   - Remind about self-review before requesting reviewers
   - Suggest: "Review the PR on GitHub, add any inline comments to guide reviewers, then request reviews when ready"

## Special Cases

### When User Says "Just Generate It"

If the user wants minimal interaction:

1. Do full analysis (git diff, commits, context)
2. Generate best-effort description from available info
3. Present for approval with: "I've generated a description based on the code changes. Review and let me know if anything needs adjustment."
4. Create PR once approved

### When PR Already Exists

If PR is already created but description is poor:

1. Fetch existing PR: `gh pr view <number> --json title,body`
2. Analyze gaps (missing Why, no testing steps, etc.)
3. Guide user through filling gaps
4. Update PR: `gh pr edit <number> --body "$(cat <<'EOF' ... EOF)"`

### When Changes Are Too Large

If diff shows >500 lines or many unrelated files:

1. Point out PR size issue: "This PR has X files and Y lines changed. Smaller PRs are easier to review and safer to merge."
2. Suggest: "Would you like to break this into smaller PRs? I can help identify logical groupings."
3. If user insists on large PR: Add review guidance section explaining order and groupings

### When No Changes Staged

If git status shows no commits on branch:

1. Inform: "I don't see any commits on this branch yet."
2. Ask: "Would you like to commit your changes first, or are you planning to make a draft PR?"

## Anti-Patterns to Avoid

❌ **Don't be a form-filler**

- Not: "Please answer these 5 questions..."
- Yes: Natural conversation, one question at a time

❌ **Don't copy commit messages verbatim**

- Synthesize and improve them
- Add context commits don't have

❌ **Don't write novels**

- Concise but complete
- Scannable structure

❌ **Don't skip testing steps**

- Every PR needs "how to verify"
- Be specific, not vague ("test it" is not helpful)

❌ **Don't assume reviewer knowledge**

- Explain context, motivation, approach
- Link to relevant docs/issues

❌ **Don't leave the "Why" empty**

- Always explain motivation
- If it seems obvious, explain anyway

## Success Criteria

A great PR description should:

- ✅ Explain **what** changed (concisely)
- ✅ Explain **why** it changed (business/technical motivation)
- ✅ Explain **how** to test (specific steps)
- ✅ Link related issues (using "Closes #X" syntax)
- ✅ Be scannable (bullets, headings, short paragraphs)
- ✅ Use active voice and simple language
- ✅ Include screenshots if UI changed
- ✅ Note limitations or follow-ups if applicable
- ✅ Guide reviewers on where to focus attention

## Reference Materials

This skill is based on industry best practices from:

- [Writing A Great Pull Request Description](https://www.hackerone.com/blog/writing-great-pull-request-description)
- [Best practices for GitHub pull request descriptions](https://graphite.com/guides/github-pr-description-best-practices)
- [Good Manners of a Pull Request & Some Best Practices](https://medium.com/deliveryherotechhub/good-manners-of-a-pull-request-some-best-practices-cb2de3c3aea1)
- [Helping others review your changes (GitHub Docs)](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/getting-started/helping-others-review-your-changes)
- [A Guide to Perfecting Pull Requests](https://dev.to/karaluton/a-guide-to-perfecting-pull-requests-2b66)
- [Writing Tips for Improving Your Pull Requests](https://www.simplethread.com/writing-tips-for-improving-your-pull-requests/)

## Examples

### Example: Simple Bug Fix

**Context:** Branch `fix/null-pointer-error`, 20 lines changed, one commit "Fix NPE in user handler"

**Generated Description:**

```markdown
## What

Fix null pointer exception in user profile handler that occurred when user data was missing.

**Key changes:**
- Add nil check before accessing user profile data
- Return 404 error with clear message when user not found
- Add test case for missing user scenario

## Why

Users reported 500 errors when viewing profiles of deleted accounts. The handler didn't validate user existence before accessing profile fields, causing crashes.

## How to Test

**Steps:**
1. Run the test suite: `go test ./internal/handlers/...`
2. Manually test: `curl http://localhost:8080/users/nonexistent-id`
3. Verify response: Should return 404 with message "User not found"

**Expected behavior:**
- Test suite passes with new nil check test
- Invalid user IDs return 404 instead of 500
- Existing user lookups continue working normally

## Related Issues

Closes #342

## Notes

This is a defensive fix. Consider adding validation middleware for all handlers in a follow-up to prevent similar issues.
```

### Example: New Feature with UI

**Context:** Branch `feature/dark-mode`, 150 lines changed, React components modified

**Generated Description:**

```markdown
## What

Add dark mode theme support to the application with user preference persistence.

**Key changes:**
- New `ThemeToggle` component in navigation bar
- CSS variables for light/dark color schemes
- LocalStorage persistence of theme preference
- System preference detection on first visit

## Why

Users requested dark mode for improved readability in low-light conditions. This is a commonly expected feature in modern web applications and improves accessibility.

## How to Test

**Prerequisites:**
- Clear localStorage for fresh state: `localStorage.clear()`

**Steps:**
1. Start the dev server: `npm start`
2. Visit `http://localhost:3000`
3. Click the theme toggle button in the navigation bar
4. Verify colors switch between light and dark
5. Refresh the page - theme should persist
6. Check browser console for no errors

**Expected behavior:**
- Toggle switches between light and dark themes smoothly
- Theme preference persists across sessions
- System preference (light/dark) is respected on first visit
- All pages render correctly in both themes

## Screenshots

[Include before/after screenshots of light and dark mode]

## Related Issues

Closes #89
Relates to #102 (accessibility improvements)

## Notes

Currently covers main application pages. Dashboard charts (#102) will be styled in a follow-up PR to keep this change focused and reviewable.
```

### Example: Large Refactoring

**Context:** Branch `refactor/auth-service`, 450 lines changed, multiple files

**Generated Description:**

```markdown
## What

Refactor authentication service to separate concerns and improve testability.

**Key changes:**
- Extract JWT token generation to `TokenService`
- Move password hashing to `PasswordService`
- Create `AuthService` interface for dependency injection
- Add comprehensive unit tests (92% coverage)
- Update all handlers to use new service structure

## Why

The authentication logic was tightly coupled to HTTP handlers, making it difficult to test and reuse. This refactoring:
- Separates business logic from HTTP concerns
- Enables unit testing without HTTP mocking
- Makes auth logic reusable across different contexts (API, CLI, background jobs)
- Follows single responsibility principle

## How to Test

**Prerequisites:**
- Clean test database: `make db-reset-test`

**Steps:**
1. Run all tests: `go test ./...`
2. Check coverage: `go test -cover ./internal/auth/...`
3. Run integration tests: `make test-integration`
4. Verify login flow: `curl -X POST http://localhost:8080/login -d '{"email":"test@example.com","password":"test123"}'`
5. Verify token validation: Use returned token in Authorization header

**Expected behavior:**
- All existing tests pass
- New auth service tests show >90% coverage
- Login/logout flows work identically to before
- No behavior changes for end users

## Review Guidance

Recommended review order:
1. Start with `internal/auth/interfaces.go` - new service contracts
2. Review `internal/auth/token_service.go` - extracted token logic
3. Review `internal/auth/password_service.go` - extracted password logic
4. Check `internal/auth/auth_service.go` - main orchestration
5. Finally review handler updates in `internal/handlers/`

Pay special attention to:
- Error handling in token generation
- Password hash comparison edge cases
- Thread safety of service instances

## Related Issues

Closes #234
Relates to #240 (API key authentication - can now reuse TokenService)

## Notes

This is a pure refactoring - no behavior changes. All existing tests pass without modification. Follow-up PRs will leverage the new structure to add API key auth (#240) and refresh tokens (#255).
```

## Tips for Agents Using This Skill

1. **Read the git history first** - commits tell a story, use it
2. **Ask one question at a time** - conversation, not interrogation
3. **Be smart about what to ask** - don't ask what the diff shows
4. **Adapt the template** - not every section needed for every PR
5. **Write for humans** - clear, scannable, helpful
6. **Include actionable testing steps** - specific commands and URLs
7. **Self-review the description** - would YOU understand this without context?
8. **Remember the goal** - make review faster, safer, better
