# AGENTS.md

**Guide for AI agents working in this dotfiles/workspace repository**

## Repository Overview

This is a personal workspace and dotfiles repository for macOS development. It contains:

- **Shell configuration**: Bash profile, Git config, input customization
- **Development tools**: Brewfile for package management, installation scripts
- **Editor setup**: Neovim configuration with Lua plugins
- **Crush configuration**: AI agent tool settings (crush.json)
- **Skills**: Reusable AI agent workflow patterns for development tasks
- **Contagent config**: Container environment configuration

The repository is designed to be cloned to `~/workspace/ryanmoran/workspace` and symlinked into the home directory.

## Essential Commands

### Installation & Setup

```bash
# Initial installation (macOS)
./install.sh

# Reload bash configuration
reload

# Reinstall from remote (pulls and re-runs install.sh)
reinstall

# Update all workspace repositories
update::workspace
# Or with filter:
./pull.sh --match "pattern"
```

### Git Workflows

```bash
# Useful aliases (from .gitconfig)
git st              # status
git co              # checkout
git ci              # commit
git lg              # pretty log graph
git prune-branches  # remove branches that are gone on remote

# Default branch is 'main'
# Auto-prune on fetch is enabled
```

### Development Tools

Available via Brewfile:

- **Languages**: go (1.25.5 via GOTOOLCHAIN), node, python@3.11, typescript
- **Package managers**: pnpm, yarn, pipx
- **Build tools**: just (task runner)
- **Container tools**: docker-desktop, dive, ctop
- **Code quality**: shellcheck, golangci-lint (via .golangci.yml)
- **CLI tools**: gh (GitHub CLI), jq, yq, ripgrep, fd, glow
- **IaC**: opentofu, vault
- **Kubernetes**: k9s, kubectx, kubelogin

### Neovim

```bash
# Launch neovim (aliased)
vim <file>
vi <file>

# Editor: nvim
# Leader key: ,
# Plugin manager: lazy.nvim
```

Configuration in `/app/nvim/`:

- `init.lua` - Entry point
- `lua/ryanmoran/default.lua` - Core settings
- `lua/ryanmoran/plugins/` - Plugin configurations

**Neovim Settings:**

- Tab/indent: 2 spaces (expandtab)
- Text width: 120 chars
- Spell check: enabled (en_us)
- Line numbers: enabled
- Mouse: enabled
- Clipboard: system clipboard

## Project Structure

```
/app/
├── .bash_profile       # Shell configuration, aliases, prompt
├── .gitconfig          # Git aliases and settings
├── .inputrc            # Readline configuration
├── .golangci.yml       # Go linting configuration
├── .contagent.yaml     # Container agent configuration
├── Brewfile            # Homebrew packages/casks
├── install.sh          # Setup script for macOS
├── pull.sh             # Bulk repo update script
├── crush/
│   └── crush.json      # Crush AI tool configuration
├── nvim/
│   ├── init.lua        # Neovim entry point
│   ├── .yamllint       # YAML linting config
│   └── lua/ryanmoran/  # Neovim Lua configuration
└── skills/             # AI agent workflow patterns
    ├── brainstorming/
    ├── development-workflow/
    ├── product-vision-document/
    ├── test-driven-development/
    └── writing-skills/
```

## Code Conventions & Patterns

### Shell Scripts

- **Shebang**: `#!/bin/bash` or `#!/usr/bin/env bash`
- **Error handling**: Use `set -e`, `set -u`, `set -o pipefail`
- **Functions**: Define helper functions, call `main` at end
- **Cleanup**: Unset functions after use in bash_profile
- **Colors**: Use ANSI codes for colored output (see pull.sh for patterns)

### Go Development

**Linting**: Use `golangci-lint` with comprehensive ruleset (`.golangci.yml`)

**Enabled linters:**

- Standard: govet, staticcheck, gosimple, typecheck, ineffassign, unused
- Error handling: errcheck, errorlint, rowserrcheck
- Style: stylecheck, goimports, gocritic, whitespace, misspell
- Security: gosec
- Structure: exhaustruct (with stdlib/common lib exclusions)
- Dependencies: depguard (blocks deprecated packages)

**Key rules:**

- Use `log/slog` (not `golang.org/x/exp/slog` or `github.com/pingcap/log`)
- Use stdlib `errors`, `slices` (not `github.com/pkg/errors`, `golang.org/x/exp/slices`)
- Use `testify/require` (not `testify/assert`)
- Use `connectrpc.com/connect` (not old `github.com/bufbuild/connect-go`)
- Check blank error assignments: `check-blank: true`
- Check type assertions: `check-type-assertions: true`
- Require nolint explanations: `require-explanation: true`
- US spelling: `locale: US` (but allow "cancelled")

**Exclusions:**

- Tests: exhaustruct checks disabled for `_test.go` files
- Directories: `generated/proto`, `internal/datastores/generated`

### Neovim/Lua

- **Indentation**: 2 spaces (tabstop=2, shiftwidth=2)
- **Structure**: Modular plugin setup in `lua/ryanmoran/plugins/`
- **Plugin manager**: lazy.nvim (auto-bootstrapped)
- **Leader key**: `,` (comma)

### Git Commit Messages

- **Text width**: 72 characters (auto-configured for gitcommit filetype)
- Default push: simple
- Auto-prune on fetch
- SSH for GitHub (auto-rewrite HTTPS to SSH)

### Markdown

- **No text wrapping**: `textwidth=0`, `wrapmargin=0`, `linebreak=false`
- This allows long lines without auto-wrapping

## Skills: AI Agent Workflows

This repository includes **skills** - reusable workflow patterns for AI agents. Skills are found in `/app/skills/` and are referenced in the main agent system prompt.

### Available Skills

#### brainstorming

**When to use:** Before any creative work - creating features, building components, adding functionality

**Process:**

1. Understand current project context
2. Ask questions one at a time to refine the idea
3. Propose 2-3 approaches with trade-offs
4. Present design in 200-300 word sections, checking after each
5. Write validated design to `docs/plans/YYYY-MM-DD-<topic>-design.md`
6. Commit the design document

**Key principle:** Natural collaborative dialogue, not a requirements extraction interview

#### test-driven-development (TDD)

**When to use:** Implementing any feature or bugfix

**Iron Law:** NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST

**Process:**

1. RED: Write test, watch it fail (proves test works)
2. GREEN: Write minimal code to pass
3. REFACTOR: Clean up while keeping tests green
4. COMMIT: Commit with descriptive message

**Violations:** If you write code before the test, delete it and start over. No exceptions.

#### development-workflow

**When to use:** Starting features, bugs, or significant changes requiring multiple commits

**Phases:** (May repeat)

1. DESIGN: Understand & plan (use brainstorming skill)
2. IMPLEMENT: Build with TDD (use test-driven-development skill)
3. REFINE: Simplify & improve
4. DOCUMENT: Explain & guide
5. REVIEW: Verify quality

**Not for:** Trivial one-line fixes, emergency hotfixes, throwaway prototypes

#### writing-skills

**When to use:** Creating new skills, editing existing skills, verifying skills work

**Core principle:** Writing skills IS Test-Driven Development applied to process documentation

**Process:**

1. RED: Run baseline scenario WITHOUT skill, document violations
2. GREEN: Write skill addressing specific violations, verify compliance
3. REFACTOR: Find new rationalizations, plug loopholes, re-verify

**Skills are:** Reusable techniques, patterns, tools, reference guides
**Skills are NOT:** Narratives about how you solved a problem once

See `/app/skills/writing-skills/` for comprehensive guidance:

- `SKILL.md` - Main skill documentation
- `anthropic-best-practices.md` - Official Anthropic guidance on skill authoring
- `testing-skills-with-subagents.md` - How to test skills with pressure scenarios
- `persuasion-principles.md` - Applying persuasion to agent instruction
- `graphviz-conventions.dot` - Visual diagram standards
- `render-graphs.js` - Script for rendering Mermaid/Graphviz diagrams

#### product-vision-document

**When to use:** Creating product vision documents for non-technical stakeholders

**Outputs:** Compelling product strategy documents for investors, executives, cross-functional teams

**Diagram preference:** Use Mermaid diagrams (not ASCII art) for visual communication

### Skill Conventions

All skills:

- Have a `SKILL.md` file with YAML frontmatter (name, description)
- Include clear "When to Use" sections
- May include supporting files (examples/, references/, scripts/)
- Are read-only mounted at `/skills` in contagent containers

## Contagent Configuration

File: `.contagent.yaml`

```yaml
dockerfile: ~/Desktop/Dockerfile.contagent
env:
  CRUSH_SKILLS_DIR: /skills
  CRUSH_GLOBAL_CONFIG: /crush
volumes:
  - ~/workspace/ryanmoran/workspace/skills:/skills:ro
  - ~/workspace/ryanmoran/workspace/crush:/crush:ro
```

- Skills and Crush config are mounted read-only into containers
- Allows consistent agent behavior across container sessions

## Crush Configuration

File: `crush/crush.json`

**LSP Settings:**

- Go: `gopls` with `GOTOOLCHAIN=go1.25.5`

**Options:**

- Attribution: `trailer_style: none`, `generated_with: false`
- No "Generated with" footers in AI-generated content

## Important Patterns & Gotchas

### Bash Profile

- **Functions**: Use local variables, call main at end, unset functions after setup
- **Prompt**: Custom PS1 with git status, background job count, exit code
- **Git status parsing**: Shows counts for Modified, Added, Deleted, Renamed, Copied, Updated, Untracked
- **Completions**: Auto-source git and docker completions from `.config/`
- **direnv**: Automatically hooked for per-directory environment

### Installation Script

- **Checks**: Verifies CommandLineTools and Homebrew before proceeding
- **Sets up symlinks**: All configs symlinked from repo to home directory
- **Creates workspace**: `~/workspace` directory for repositories
- **Python setup**: Installs pynvim with `--break-system-packages` flag (required on modern macOS)
- **Neovim plugins**: Auto-installs via `nvim --headless "+Lazy! sync" +qa`

### Pull Script

- **Bulk updates**: Finds all repos in `~/workspace/*/*/.git` (depth 3)
- **Safe**: Won't pull if uncommitted changes exist
- **Informative**: Shows status with colored output
- **Filter**: Use `--match` to update subset of repos
- **Submodules**: Updates recursively after pull

### Neovim

- **Keybindings:**
  - `<space>` - Clear search highlights
  - `<leader>y` - Yank to system clipboard
  - `<leader>i` - Toggle Go inlay hints
  - `n`/`N` - Center screen on search results
- **Undo history**: Persisted between sessions in `~/.config/nvim/undo/`
- **Special filetypes:**
  - Git commits: 72 char textwidth
  - Markdown: No wrapping or textwidth limits

### Go Linting

- **Run manually**: `golangci-lint run` (uses `~/.golangci.yml`)
- **Timeout**: 3 minutes
- **Concurrency**: 4
- **Mode**: `modules-download-mode: readonly` (no go.mod updates during lint)
- **Test files**: exhaustruct disabled for tests (struct initialization checks)

## Environment Details

### Paths

```bash
GOPATH=${HOME}/go
PATH includes:
  - ${GOPATH}/bin
  - /usr/local/sbin
  - ${HOME}/.local/share/nvim/mason/bin  # Neovim LSPs/tools
  - ${HOME}/.local/bin                    # Local binaries
  - $(brew --prefix python@3.11)/libexec/bin
  - /opt/homebrew/bin                     # Homebrew
```

### Workspace Layout

Expected structure: `~/workspace/OWNER/REPO/`

Example:

```
~/workspace/
├── ryanmoran/
│   └── workspace/          # This repo
├── ORG1/
│   ├── repo1/
│   └── repo2/
└── ORG2/
    └── repo3/
```

The `pull.sh` script assumes this 3-level depth for discovery.

## Working with This Repository

### Making Changes

1. **Edit files** in the cloned repository (`~/workspace/ryanmoran/workspace/`)
2. **Test changes**: For shell config, run `reload`; for install script, run `reinstall`
3. **Commit** with descriptive messages
4. **Push** to remote (never auto-pushed by scripts)

### Testing Installation

The `reinstall` function:

- Checks for uncommitted changes (blocks if found)
- Pulls latest from remote
- Re-runs `install.sh`

Safe to run repeatedly - uses symlinks so changes take effect immediately.

### Adding Skills

Follow the **writing-skills** skill pattern:

1. Run baseline scenario WITHOUT the skill (document failures)
2. Write `SKILL.md` with YAML frontmatter
3. Test with subagent pressure scenarios
4. Iterate until compliance is consistent
5. Add supporting files as needed (examples/, references/, scripts/)

Skills should be:

- Reusable across projects
- Technique-focused (not narrative)
- Tested with pressure scenarios
- Clear about when to use

### Adding Brew Packages

1. Edit `Brewfile`
2. Run `brew bundle` (or `reinstall`)
3. Commit the change

## Common Tasks

### Setting up a new machine

```bash
# Clone this repo
git clone git@github.com:ryanmoran/workspace ~/workspace/ryanmoran/workspace

# Run installation
cd ~/workspace/ryanmoran/workspace
./install.sh

# Result: All configs symlinked, packages installed, tools ready
```

### Adding a git alias

1. Edit `.gitconfig` under `[alias]`
2. Symlink is already in place, immediately available
3. Commit the change

### Updating all workspace repos

```bash
# All repos
update::workspace

# Or directly with filter
cd ~/workspace/ryanmoran/workspace
./pull.sh --match "myorg"
```

### Modifying neovim config

1. Edit files in `nvim/` directory
2. Reload neovim (`:so $MYVIMRC` or restart)
3. Plugin changes: `:Lazy sync`

### Running Go linters

```bash
golangci-lint run
# Uses ~/.golangci.yml configuration
# Output goes to stderr with colored formatting
```

## Security & Privacy

- **Git config**: Hardcoded email `ryan.moran@gmail.com`, name `Ryan Moran`
- **SSH for GitHub**: HTTPS URLs auto-converted to SSH (push and fetch)
- **1Password**: Installed via Brewfile (likely used for SSH keys, secrets)
- **Vault**: Installed for secrets management

When working in this repo, be aware these are personal dotfiles with personal information.

## References

### Official Documentation Links

- **Crush**: https://charm.land/crush.json (schema reference)
- **golangci-lint**: https://golangci-lint.run/
- **Neovim**: https://neovim.io/doc/
- **lazy.nvim**: https://github.com/folke/lazy.nvim

### Key Files to Reference

- `.bash_profile` - Shell functions, aliases, prompt customization
- `.golangci.yml` - Comprehensive linting rules for Go projects
- `skills/writing-skills/anthropic-best-practices.md` - Official skill authoring guidance
- `skills/writing-skills/testing-skills-with-subagents.md` - How to verify skills work

## Philosophy & Approach

This workspace embodies several key principles:

1. **Automation over documentation**: Scripts handle setup/updates rather than manual steps
2. **Symlinks for consistency**: One source of truth, immediately effective changes
3. **Skills over ad-hoc**: Codify effective patterns as reusable skills
4. **TDD everywhere**: Apply test-first thinking to code AND process documentation
5. **Minimal but complete**: Include what's needed, exclude what's not
6. **Opinionated defaults**: Strong preferences (2-space tabs, slog over alternatives, etc.)

When in doubt: Check existing patterns, follow conventions, test before committing.
