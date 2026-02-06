# PROMPT

## Context

1. Read the AGENTS.md file for general repository context.

## Objective

Let's make some modifications to the ./skills/pull-request-description skill.

During Phase 2, some more questions to ask might be:

- What part of the PR do you want reviewed?
  - Are you unsure of some requirements?
  - Do you want to establish a new pattern?
  - Are you concerned about some performance or resiliency issue?
  - etc.
- What other work do I need to be aware of to situate myself in the PR?
  - Is there more stuff coming later?
  - Something in a different repo?
  - etc.

In Phase 3, urge the agent to:

- Focus on brevity and clarity
- Don't repeat yourself
- Place the most important things near the top.

In Phase 5:

1. Assume that you will not be making the PR directly. You will be
   providing the user with a PR_DESCRIPTION.md file that they can paste into the
   PR they make themselves.
2. Also generate a COMMIT_MSG.md file that contains a much shorter summary of
   the PR description, focused on the "what".

## On Successful Completion of the Objective

Commit the changes and push to the current branch.
