# PROMPT

## Context

1. Read the AGENTS.md file for general repository context.

## Objective

Let's make some modifications to the ./skills/ticket-breakdown skill.

The skill should discourage the agent from making issues that just layout
foundational work.

For instance, the agent should not create issues that just install dependencies
or create directories.

Instead, those concerns should be embedded into the issues that need that foundational
work done. For instance, if an issue requires that a dependency be installed,
then that issue should be the one to include its installation.

## On Successful Completion of the Objective

Commit the changes and push to the current branch.
