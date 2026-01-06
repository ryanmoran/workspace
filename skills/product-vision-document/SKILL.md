---
name: product-vision-document
description: Use when creating product vision documents, product strategy docs, or communicating product ideas to non-technical stakeholders like investors, executives, or cross-functional teams
---

# Writing Product Vision Documents

## Overview

Create product vision documents that non-technical stakeholders can understand, act on, and share. Focus on **why** the product matters, **who** it serves, and **how** users accomplish their goals—not technical implementation.

**Core principle:** If a stakeholder needs to ask "what does this mean?" or "why should I care?", the document has failed.

## When to Use

- Creating pitch documents for investors or executives
- Aligning cross-functional teams on product direction
- Documenting product strategy for new initiatives
- Communicating vision to non-technical team members

## Document Structure

Follow this structure in order. Each section builds on the previous.

### 1. Vision Statement (Required)

Use Geoffrey Moore's template:

> **For** [target users] **who** [have this need/problem], **the** [product name] **is a** [product category] **that** [key benefit]. **Unlike** [alternatives], **our product** [key differentiator].

**Example:**
> For busy parents who struggle to manage their children's screen time, ScreenTime Guardian is a family wellness app that creates healthy digital boundaries through collaboration. Unlike surveillance-focused competitors, our product teaches children self-regulation skills.

### 2. Problem Statement (Required)

Define the problem in human terms:

| Element | Description |
|---------|-------------|
| **Who feels the pain** | Specific user segment, not "everyone" |
| **What the pain is** | Observable behavior or frustration |
| **Why it matters** | Consequences of not solving it |
| **Current workarounds** | How people cope today (and why it fails) |

**Bad:** "Users need better analytics"
**Good:** "Parents currently guess how much time their kids spend on devices. They resort to arguments at bedtime, damaging relationships and creating anxiety."

### 3. Stakeholder Map (Required)

Use a Power-Interest Grid to categorize stakeholders:

```
        HIGH INTEREST                    LOW INTEREST
    ┌─────────────────────────────┬─────────────────────────────┐
    │                             │                             │
H   │   MANAGE CLOSELY            │   KEEP SATISFIED            │
I   │   (Key decision makers)     │   (Executives, board)       │
G   │   • Primary users           │   • C-suite sponsors        │
H   │   • Product team            │   • Advisory board          │
    │   • Key investors           │                             │
P   │                             │                             │
O   ├─────────────────────────────┼─────────────────────────────┤
W   │                             │                             │
E   │   KEEP INFORMED             │   MONITOR                   │
R   │   (Engaged supporters)      │   (Minimal effort)          │
    │   • Secondary users         │   • General public          │
L   │   • Customer support        │   • Indirect competitors    │
O   │   • Marketing team          │                             │
W   │                             │                             │
    └─────────────────────────────┴─────────────────────────────┘
```

For each stakeholder group, document:
- **Who they are** (role, not name)
- **What they need** from this product
- **How we communicate** with them
- **Their success criteria**

### 4. User Personas (Required)

Create 2-3 personas using Jobs-to-be-Done (JTBD) format:

```markdown
## Persona: [Name] ([Role])

**Situation:** [Context when they need this product]

**Job to be Done:** 
When I [situation/trigger], I want to [action/capability], so I can [desired outcome].

**Functional needs:** [What they need to accomplish]
**Emotional needs:** [How they want to feel]
**Social needs:** [How they want to be perceived]

**Current alternatives:** [What they do today]
**Why alternatives fail:** [Specific shortcomings]
```

### 5. User Workflow Diagrams (Required)

Visualize key user journeys using swimlane diagrams. These show:
- Different actors (parent, child, system)
- Steps in their process
- Decision points
- Handoffs between actors

**Format:** Use ASCII diagrams with clear labels. See diagrams.md for templates.

**Every workflow must show:**
1. **Trigger** — What starts this flow?
2. **Happy path** — Main success scenario
3. **Decision points** — Where users make choices
4. **End state** — What success looks like

### 6. Use Cases (Required)

Write use cases in plain language, not technical specifications:

```markdown
## Use Case: [Action Name]

**Actor:** [Who performs this]
**Goal:** [What they want to achieve, in their words]
**Trigger:** [What starts this use case]

**Main Flow:**
1. [Actor] does [action]
2. System [response]
3. [Actor] sees [result]
4. [Continue until goal achieved]

**Alternative Flows:**
- If [condition], then [what happens]

**Success Criteria:** [How actor knows they succeeded]
```

**Non-technical language rules:**
- Use "sees" not "renders"
- Use "saves" not "persists to database"
- Use "notifies" not "sends push notification via FCM"
- Use verbs users would use, not technical verbs

### 7. Feature Overview (Required)

Present features from user benefit perspective:

| What Users Can Do | Why It Matters | Who Benefits |
|-------------------|----------------|--------------|
| Set daily time limits | Peace of mind, consistent boundaries | Parents |
| Earn bonus time | Motivation through positive reinforcement | Children |

**Avoid:** Feature lists with technical specs
**Include:** How each feature solves a problem from Section 2

### 8. Success Metrics (Required)

Define measurable outcomes for both users AND business:

**User Success:**
- What behavior changes?
- What pain decreases?
- What goal becomes achievable?

**Business Success:**
- Adoption metrics
- Engagement metrics
- Revenue/growth metrics

### 9. Competitive Positioning (Optional)

If included, use a simple comparison:

| | Our Product | Alternative A | Alternative B |
|---|-------------|---------------|---------------|
| **Key Differentiator** | ✓ | ✗ | Partial |

Avoid: Long competitor teardowns
Include: Clear reason why users choose us

## Writing for Non-Technical Audiences

### Language Rules

| Instead of... | Write... |
|---------------|----------|
| API, SDK, backend | "the system" or "behind the scenes" |
| Database, storage | "saves your information" |
| Algorithm | "smart suggestions" |
| Real-time sync | "updates instantly" |
| Push notifications | "alerts you" |
| Authentication | "secure login" |
| UI/UX | "design" or "experience" |

### Diagram Guidelines

Use ASCII or Mermaid diagrams that can render in any environment.

**For workflows:** Use swimlane format (see diagrams.md)
**For architecture:** Use simplified box diagrams showing user-visible components only
**For comparisons:** Use tables

**Never include:**
- Technical architecture (servers, databases, APIs)
- Code snippets
- Data models
- System diagrams that require technical knowledge

### Readability Checklist

Before finalizing, verify:
- [ ] Can be read in under 10 minutes
- [ ] Every section answers "why should I care?"
- [ ] No unexplained acronyms
- [ ] Diagrams have labels a non-technical person understands
- [ ] Use cases describe what users DO, not what systems DO
- [ ] Success metrics include user outcomes, not just business metrics

## Quick Reference

| Section | Purpose | Length |
|---------|---------|--------|
| Vision Statement | Align everyone on direction | 2-3 sentences |
| Problem Statement | Create urgency and empathy | 1 paragraph + table |
| Stakeholder Map | Show who cares and why | Grid + 3-5 groups |
| Personas | Make users real | 2-3 personas |
| Workflows | Show how it works | 2-4 diagrams |
| Use Cases | Detail key interactions | 3-6 use cases |
| Features | Connect solutions to problems | Table format |
| Success Metrics | Define winning | User + Business metrics |

## Common Mistakes

| Mistake | Why It's Wrong | Fix |
|---------|----------------|-----|
| Starting with features | Puts solution before problem | Start with vision and problem |
| Technical jargon | Alienates non-technical readers | Use language rules above |
| Vague stakeholders | "Users" isn't actionable | Name specific roles and needs |
| Missing workflows | Hard to understand the experience | Add visual flows |
| No success metrics | Can't measure progress | Define user AND business metrics |
| Too long | Won't be read | Target 10-minute read time |

## Supporting Files

- **diagrams.md** — Templates for swimlane diagrams, user journeys, and stakeholder maps
- **examples/** — Sample vision documents for reference
