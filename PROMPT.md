# PROMPT

## Context

1. Read the AGENTS.md file for general repository context.

## Objective

Let's make some modifications to the ./skills/pull-request-description skill.

When I ran the skill, the agent skipped over Phase 4 and just wrote the description out on disk.
I want to add some extra instructions to prevent this from happening again.

1. In Phase 4, add explicit instructions that the agent must WAIT for user feedback before proceeding
2. In Phase 5, add a clear prerequisite: "Only proceed to this phase after the user has approved the description in
Phase 4"
3. Consider adding a checkpoint reminder between phases: "STOP - Do not generate files yet. Present the description
to the user first."

## On Successful Completion of the Objective

Commit the changes and push to the current branch.
