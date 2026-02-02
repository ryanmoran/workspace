# PROMPT

## Context

1. Read the AGENTS.md file for general repository context.

## Objective

We're in the process of developing a new skill in the ./skills/go-style-guide
directory.

The skill is based upon the lessons of the [Google Go Styleguide](https://google.github.io/styleguide/go/).

The skill is structured as a single SKILL.md file, but I would like to redesign
it in keeping with the ideas of progressive disclosure.

You can read about progressive disclosure in [Anthropic's blog post](https://claude.com/blog/equipping-agents-for-the-real-world-with-agent-skills).

As far as the structure of the skill, the [Vercel React Best Practices](https://github.com/vercel-labs/agent-skills/tree/main/skills/react-best-practices)
skill is a good example.

The thing I think is good about the Vercel skill is that the top-level SKILL.md
document is just a directory for find the rules that outline the best practices.
The actual content is stored in smaller files elsewhere. This means that agents
will spend more time doing lookup to find what they need, but also load less
extra context that they don't. This is preferred so that we can reduce the
overall number of tokens loaded into the context window.

Redesign the existing skill with this in mind.

Also, use `rumdl` to format any markdown files.

## On Successful Completion of the Objective

Commit the changes and push to the current branch.
