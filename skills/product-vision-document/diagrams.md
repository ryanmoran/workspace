# Diagram Templates for Product Vision Documents

**Prefer Mermaid diagrams** — they render consistently across GitHub, Notion, VS Code, and most documentation tools. Use ASCII as fallback when Mermaid can't represent the layout.

## Flowchart (Mermaid) — User Workflows

Use for showing step-by-step processes with decision points.

```mermaid
flowchart TD
    A[Start: User Action] --> B{Decision Point?}
    B -->|Yes| C[Path A]
    B -->|No| D[Path B]
    C --> E[End State]
    D --> E
```

### Example: Child Requests More Time

```mermaid
flowchart TD
    A[⏰ Time Limit Reached] --> B[Child sees: '5 minutes left']
    B --> C{Request more time?}
    C -->|Yes| D[Pick reason]
    C -->|No| E[Device locks gracefully]
    D --> F[Parent gets notification]
    F --> G{Parent approves?}
    G -->|Yes| H[✅ +30 min granted]
    G -->|No| I[Device locks with kind message]
```

## Sequence Diagram (Mermaid) — Actor Interactions

Use for showing how different actors interact over time.

```mermaid
sequenceDiagram
    participant P as Parent
    participant S as System
    participant C as Child
    
    P->>S: Set 2-hour daily limit
    S->>C: Sync new limit
    C->>S: Uses device
    S->>C: 15-min warning
    S->>C: 5-min warning
    S->>C: Time's up - graceful lock
    C->>S: Request more time
    S->>P: Notification
    P->>S: Approve request
    S->>C: +30 minutes granted
```

### Example: Parent Onboarding Flow

```mermaid
sequenceDiagram
    participant P as Parent
    participant App as App
    participant CD as Child's Device
    
    P->>App: Download & create account
    App->>P: Welcome! Add your children
    P->>App: Add child profile
    App->>P: Install on child's device?
    P->>CD: Install app
    CD->>App: Link to family
    App->>P: Set initial limits
    P->>App: Save settings
    App->>CD: Sync limits instantly
    App->>P: ✅ Setup complete!
```

## Quadrant Chart (Mermaid) — Stakeholder Maps

Use for Power-Interest grids and similar 2x2 matrices.

```mermaid
quadrantChart
    title Stakeholder Map
    x-axis Low Interest --> High Interest
    y-axis Low Power --> High Power
    quadrant-1 Manage Closely
    quadrant-2 Keep Satisfied
    quadrant-3 Monitor
    quadrant-4 Keep Informed
    
    Parents: [0.85, 0.8]
    Product Team: [0.9, 0.75]
    Investors: [0.3, 0.85]
    Children: [0.8, 0.25]
    Pediatricians: [0.7, 0.3]
    Competitors: [0.2, 0.2]
```

## User Journey (Mermaid)

Use for showing emotional experience across touchpoints.

```mermaid
journey
    title Parent Finding a Screen Time Solution
    section Discovery
      Googles solutions: 3: Parent
      Feels overwhelmed: 2: Parent
    section Evaluation
      Reads reviews: 4: Parent
      Compares apps: 3: Parent
    section First Use
      Downloads app: 5: Parent
      Sets up family: 4: Parent
    section Daily Use
      Checks dashboard: 5: Parent
      Fewer arguments: 5: Parent
```

## Flowchart with Subgraphs — Complex Workflows

Use when showing multiple actors in parallel.

```mermaid
flowchart TB
    subgraph Parent[Parent Phone]
        P1[Open app] --> P2[Set limits]
        P2 --> P3[Save]
    end
    
    subgraph System[Cloud]
        S1[Sync settings]
    end
    
    subgraph Child[Child Device]
        C1[Receive new limits]
        C2[See notification]
    end
    
    P3 --> S1
    S1 --> C1
    C1 --> C2
```

---

## ASCII Fallback Templates

Use ASCII when Mermaid can't represent the layout or when you need more visual control.

### Swimlane Diagram (ASCII)

For complex multi-actor flows that need precise alignment:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           [PROCESS NAME]                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  [ACTOR 1]    ──►[Action]──►[Action]──────────────────►[End State]         │
│                      │                                      ▲               │
│                      ▼                                      │               │
│  [ACTOR 2]         [Action]──►[Decision?]──►[Action]───────┘               │
│                                    │                                        │
│                                    ▼ (alternative)                          │
│  [SYSTEM]                      [Action]──►[Notification]                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Power-Interest Grid (ASCII)

When you need more text in each quadrant than Mermaid allows:

```
                          INTEREST IN PRODUCT
                    Low                        High
                ┌─────────────────────┬─────────────────────┐
                │                     │                     │
           High │  KEEP SATISFIED     │  MANAGE CLOSELY     │
                │  • Investors        │  • Parents (buyers) │
                │  • App store teams  │  • Product team     │
     POWER      │                     │  • Early adopters   │
                ├─────────────────────┼─────────────────────┤
           Low  │  MONITOR            │  KEEP INFORMED      │
                │  • General public   │  • Children (users) │
                │  • Competitors      │  • Pediatricians    │
                └─────────────────────┴─────────────────────┘
```

### Simple System Overview (ASCII)

For showing user-visible components:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           HOW IT WORKS                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│    ┌───────────────┐                         ┌───────────────┐              │
│    │   📱 Parent   │                         │  📱 Child's   │              │
│    │   Phone       │                         │    Device     │              │
│    │               │      ┌─────────┐        │               │              │
│    │ • View usage  │◄────►│ ☁️ Cloud │◄──────►│ • See limits  │              │
│    │ • Set rules   │      │ (Secure)│        │ • Track time  │              │
│    │ • Approve     │      └─────────┘        │ • Request     │              │
│    └───────────────┘                         └───────────────┘              │
│                                                                             │
│    Changes sync instantly across all family devices                         │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## When to Choose Each Format

| Scenario | Use Mermaid | Use ASCII |
|----------|-------------|-----------|
| Simple flowchart | ✅ `flowchart` | |
| Actor interactions | ✅ `sequenceDiagram` | |
| User journey with emotions | ✅ `journey` | |
| 2x2 matrix with few points | ✅ `quadrantChart` | |
| 2x2 matrix with detailed lists | | ✅ Grid template |
| Complex swimlane with precise alignment | | ✅ Swimlane template |
| System overview with icons | | ✅ Box diagram |
| Decision tree | ✅ `flowchart` | |

## Tips for Creating Diagrams

### Do:
- Use simple, descriptive labels
- Show the user's perspective, not technical internals
- Include start and end states
- Keep diagrams under 10-12 nodes for readability
- Use emoji sparingly for visual interest in ASCII (📱 ✅ ⏰)

### Don't:
- Show technical architecture (databases, servers, APIs)
- Use technical abbreviations without explanation
- Create diagrams so complex they need explanation
- Rely on color alone to convey meaning

### Accessibility:
- Mermaid renders with good contrast by default
- ASCII diagrams use text that screen readers can parse
- Always provide text descriptions alongside complex diagrams
