# PROMPT

## Context

1. Read the AGENTS.md file for general repository context.

## Objective

We're in the process of developing a new skill in the ./skills/go-style-guide
directory.

The skill is based upon the lessons of the [Google Go Styleguide](https://google.github.io/styleguide/go/).

I'd like to make the following changes:

1. Don't reference editors or IDEs. Assume that the audience for this is an LLM
   coding agent which doesn't use those. If the content of the reference is
   important, describe how an LLM agent would achieve the same outcome.
2. The package design rule should have the following changes:
   - command-line applications can just be at the root directory, they don't need to be under a `cmd` directory
   - public library code can also just be at the root, they don't need to be under a `pkg` directory
3. Remove the specific rules related to testing

## On Successful Completion of the Objective

Commit the changes and push to the current branch.
