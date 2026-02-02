---
name: issue-management
description: Use when tasked with working on an issue from an issues/ directory, especially when asked to "work on an issue", "work on the next issue", or "continue working"
---

# Issue Management

## Overview

**Systematic approach to discovering, tracking, and completing one issue at a time in a project.** Prevents skipping tracking setup, working on wrong issues, and marking incomplete work as done.

## When to Use

Use this skill when:

- Asked to "work on an issue" or "work on the next issue"
- Project has an `issues/` directory with multiple issue files
- You need to determine which issue to work on next
- Multiple issues exist with potential dependencies

**Don't use when:**

- Single issue provided directly in prompt
- No formal issue tracking structure exists
- Working on ad-hoc tasks without issue files

## Core Pattern

**Without this skill:**

```text
User: "Work on the next issue"
Agent: Reads all files, starts with ISSUE-001, does them in order
      No status tracking, relies on memory/git
```

**With this skill:**

```text
User: "Work on the next issue"
Agent: 1. Read issues/README.md
       2. Check/create issues/.status.json
       3. Evaluate dependencies
       4. Mark issue in_progress BEFORE starting
       5. Complete thoroughly (all acceptance criteria)
       6. Verify completion (tests, lint)
       7. Mark completed AFTER verification
       8. Commit and STOP
```

## Issue Discovery Process

### Step 1: Read Project Structure

**ALWAYS start by reading `issues/README.md`:**

- Overall project goal
- List of issues and sequence
- Dependencies between issues
- Implementation phases

### Step 2: Check Status Tracking

**Look for `issues/.status.json`**

**If exists:** Read it to understand current state

**If missing:** Create it with this structure:

```json
{
  "issues": {
    "ISSUE-001": {"status": "pending", "started_at": null, "completed_at": null},
    "ISSUE-002": {"status": "pending", "started_at": null, "completed_at": null}
  },
  "last_updated": "2025-01-15T10:30:00Z",
  "current_issue": null
}
```

### Step 3: Determine Next Available Issue

**An issue is available when:**

1. Status is "pending"
2. All dependencies have status "completed"
3. No other issue is "in_progress"

**Select the first available issue in numerical order.**

## Work Execution Process

### Before Starting Work

**REQUIRED:** Update status file BEFORE any implementation:

```json
{
  "status": "in_progress",
  "started_at": "2025-01-15T10:35:00Z"
}
```

Update `current_issue` to the issue ID.

**Use todos tool** to track acceptance criteria as tasks.

### During Implementation

Follow all acceptance criteria. Common criteria include:

- Implementation complete
- Unit tests written and passing
- Integration tests written and passing
- Documentation updated
- All tests pass
- All linting passes

### Completion Verification

**CRITICAL: Only mark "completed" when ALL acceptance criteria are met.**

Before marking complete, verify:

- ✅ Every acceptance criterion is satisfied
- ✅ All tests pass (unit + integration + database)
- ✅ All linting passes
- ✅ Code is formatted
- ✅ Generated code is up to date
- ✅ Documentation updated if required

**If any criterion fails: Issue is NOT complete.**

## Status Values

- **pending**: Not started, may have unmet dependencies
- **blocked**: Cannot proceed due to external factors (document why in "notes")
- **in_progress**: Currently being worked on (ONLY ONE at a time)
- **completed**: All acceptance criteria met and verified
- **skipped**: Intentionally skipped (requires note explaining why)

## Common Rationalizations

| Excuse                                       | Reality                                                                              |
| -------------------------------------------- | ------------------------------------------------------------------------------------ |
| "Small project, don't need status tracking"  | Without tracking, you'll lose state and work on wrong issues                         |
| "I can track it mentally"                    | Mental tracking fails with >3 issues or complex dependencies                         |
| "Git history shows what's done"              | Git shows commits, not issue status or dependencies met                              |
| "My code is done, environment issue blocked" | Issue isn't complete until acceptance criteria are met, including passing tests      |
| "I'll create tracking if needed"             | "If needed" = never. Create it upfront per the process                               |
| "Just doing them in order is fine"           | Dependencies may not follow numerical order                                          |
| "Integration tests failing isn't my fault"   | Acceptance criteria define completion, not whose fault blockers are                  |
| "Most of the work is done"                   | "Most" ≠ "all". Mark as blocked, not completed                                       |
| "Setting up tracking wastes time"            | Tracking saves time by preventing wrong issue selection and lost state               |
| "I'll update status at the end"              | Status must be updated after each issue. Out-of-date status defeats the purpose      |
| "I'm in flow, I'll update later"             | Flow without tracking = working on wrong issues. Update immediately                  |

**All of these mean: Follow the discovery process. Create status tracking. Mark complete only when verified.**

## Red Flags - STOP

If you catch yourself thinking:

- "I'll skip creating .status.json"
- "I'll just start with ISSUE-001"
- "Close enough, I'll mark it done"
- "My part is complete" (when acceptance criteria aren't met)
- "I'll track status later"
- "The tests are failing but not because of my code"

**All of these mean: STOP. Go back to Issue Discovery Process.**

## After Completing an Issue

1. Update status to "completed"
2. Set "completed_at" timestamp
3. Set "current_issue" to null
4. Update "last_updated" timestamp
5. Commit the work with status file
6. **STOP and report completion to user**

## When to Stop

**ALWAYS stop after completing one issue.**

After marking an issue as completed:

1. Update the status file
2. Commit the work
3. Report completion
4. STOP - do not continue to the next issue

The user will explicitly ask to continue if they want to work on the next issue.

## Quick Reference

```text
Read issues/README.md
  ↓
Check/create .status.json
  ↓
Find first available issue (pending + dependencies met)
  ↓
Mark in_progress + started_at
  ↓
Complete ALL acceptance criteria
  ↓
Verify (tests + lint + criteria)
  ↓
Mark completed + completed_at
  ↓
Commit and STOP
```

## Example Status File

```json
{
  "issues": {
    "ISSUE-001": {
      "status": "completed",
      "started_at": "2025-01-15T10:00:00Z",
      "completed_at": "2025-01-15T11:30:00Z"
    },
    "ISSUE-002": {
      "status": "in_progress",
      "started_at": "2025-01-15T11:35:00Z",
      "completed_at": null
    },
    "ISSUE-003": {
      "status": "pending",
      "started_at": null,
      "completed_at": null
    },
    "ISSUE-004": {
      "status": "blocked",
      "started_at": "2025-01-15T09:00:00Z",
      "completed_at": null,
      "notes": "Waiting for external API credentials"
    }
  },
  "last_updated": "2025-01-15T11:35:00Z",
  "current_issue": "ISSUE-002"
}
```
