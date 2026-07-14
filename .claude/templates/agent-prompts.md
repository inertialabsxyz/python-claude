# Agent Prompts — [Project Name]

<!-- ============================================================
HOW TO USE THIS TEMPLATE
================================================================

This file is a scaffold for creating self-contained agent briefs
for a phased implementation project. Each step in this file becomes
a prompt handed directly to a Claude Code agent.

TO GENERATE THE FILLED-IN VERSION FOR YOUR PROJECT:

  Spawn an agent with the following prompt (substituting your
  project's planning doc path):

  ---
  You are generating an agent-prompts.md file for a new project.

  Read the full specification in `planning/<spec-file>.md` and
  use it to produce a completed version of the template at
  `.claude/templates/agent-prompts.md`.

  Save the result to `planning/agent-prompts.md` in this project.

  Rules for filling in the template:
  1. Identify all implementation phases in the spec.
  2. Determine which phases are sequentially dependent and which
     can run in parallel. A phase can run in parallel only if it
     touches different files/modules than its sibling.
  3. For each phase, write a self-contained prompt that includes:
     - Branch name
     - Context: what is already built when this agent starts
     - Task: numbered steps matching the spec, referencing the
       exact section of the planning doc
     - Do Not Touch: files/modules owned by other phases
     - Verification: concrete commands and expected output
  4. Add a stub pattern to the earliest phase that adds empty
     placeholder types/structures for later phases. This prevents
     merge conflicts when parallel agents run.
  5. Each agent must not need to read another agent's prompt.
     All context must be self-contained within its own step.
  6. Use the project's actual file paths, module names, and
     technology stack — do not use generic placeholders.
  7. Follow the branch naming convention from the project's
     CLAUDE.md if one exists.

  Do not invent features not in the spec. If the spec is
  ambiguous about ordering, prefer sequential over parallel —
  parallel is an optimisation, not a requirement.
  ---

PRINCIPLES BEHIND THE FORMAT:

  - Self-contained prompts: each agent starts fresh with no
    memory of other agents. Every prompt must include all
    context needed to complete its phase.
  - Boundary protection: "Do Not Touch" lists prevent agents
    from accidentally breaking each other's work.
  - Stubs first: the first phase adds empty placeholder types
    for all later phases. This lets parallel agents type-check /
    import against each other's future types without merge conflicts.
  - Verification is concrete: commands with expected output,
    not vague "make sure it works" instructions.
  - Sequencing is explicit: the diagram and per-step
    dependency notes make dispatch order unambiguous.

============================================================ -->

These prompts are designed to be handed directly to a Claude Code agent. Each is self-contained. Agents work on git branches and do not share state during execution. Read the sequencing notes before dispatching.

---

## Sequencing Overview

<!--
Draw the dependency graph. Sequential steps go top to bottom.
Parallel steps branch left/right from a common node.
Example layout (adjust to your project):

Step 1 (single agent):   Phase 1 — Foundation
                              │
              ┌───────────────┴───────────────┐
Step 2 (parallel):  Phase 2a — Feature A    Phase 2b — Feature B
              └───────────────┬───────────────┘
                         merge to main
                              │
Step 3 (single agent):   Phase 3 — Integration
-->

```
Step 1 (single agent):   Phase 1 — [Name]
                              │
              ┌───────────────┴───────────────┐
Step 2 (parallel):  Phase 2a — [Name]    Phase 2b — [Name]
              └───────────────┬───────────────┘
                         merge to main
                              │
Step 3 (single agent):   Phase 3 — [Name]
```

Do not start Step 2 until Step 1 is merged to main. Each parallel pair should use separate git branches.

---

## Step 1 — Phase 1: [Phase Name]

**Branch:** `feat/phase-1-[short-name]`

**Prompt:**

You are implementing Phase 1 of [Project Name]. The full specification is in `planning/[spec-file].md` under "[Phase 1 Section Name]". Read that section carefully before writing any code.

### Context

<!--
Describe the current state of the codebase as the agent will
find it. Be specific: name the files, modules, or components
that already exist and what they do. Include what the system
can do end-to-end right now.
-->

[Describe current codebase state. Name existing files/modules and their roles. State what the system can do today and what constraint must not be broken — e.g. "the app starts and exits cleanly".]

### Your Task

<!--
Number every discrete action. Reference the spec section for
each requirement so the agent can verify completeness.
Group related actions under sub-headings if the phase is large.

Include a stub pattern if later phases will need types/interfaces
that don't exist yet. Stubs prevent merge conflicts when parallel
agents type-check / import against each other's future work.
-->

**Part A — Implement Phase 1** as specified in `planning/[spec-file].md`:

1. [Action 1 — be specific: file to create/modify, type/function to add]
2. [Action 2]
3. [Action 3]

**Part B — Add stubs for later phases** (prevents merge conflicts when parallel agents start)

Add the following empty placeholder definitions to `[shared-types-file]`. Mark each with a `# Phase N stub` comment (use the project language's comment syntax) — later phases will replace them with full implementations:

```
[language-appropriate stub definitions]
# Phase 2 stub
[stub 1]

# Phase 3 stub
[stub 2]
```

### Verification

<!--
Concrete commands with expected output. The agent runs these
to confirm success. Include negative checks where relevant
(e.g. "does not crash", "still exits cleanly").
-->

Run `[build/run command]` and confirm:
- [Expected observable output 1]
- [Expected observable output 2]
- [The system still does X end-to-end]

Do not implement Phase 2, 3, or later content beyond the stubs listed above.

---

## Step 2a — Phase 2a: [Phase Name]

**Branch:** `feat/phase-2a-[short-name]`
**Depends on:** Step 1 merged to main

**Prompt:**

You are implementing [Phase 2a Name] of [Project Name]. The full specification is in `planning/[spec-file].md` under "[Phase 2a Section Name]". Read that section carefully before writing any code.

### Context

<!--
State everything that is already complete when this agent starts.
Be specific — name components, APIs, or modules. The agent must
know exactly what it can rely on without reading other prompts.
-->

[List what Phase 1 delivered. Name the specific files, types, and behaviours this agent can build on. State any interface contracts this agent must not break.]

### Your Task

1. [Action 1]
2. [Action 2]
3. [Action 3]

### Do Not Touch

<!--
Name every file or module owned by another phase. This prevents
agents from accidentally stepping on parallel or later work.
-->

- `[file]` — [Phase N]'s domain
- `[file]` — does not exist yet, [Phase N]'s domain
- The `# Phase N stub` definitions in `[shared-types-file]` — leave them as stubs

### Verification

```bash
[command 1]
# → [expected output]

[command 2]
# → [expected output]
```

---

## Step 2b — Phase 2b: [Phase Name]

**Branch:** `feat/phase-2b-[short-name]`
**Depends on:** Step 1 merged to main

**Prompt:**

You are implementing [Phase 2b Name] of [Project Name]. The full specification is in `planning/[spec-file].md` under "[Phase 2b Section Name]". Read that section carefully before writing any code.

### Context

[Same pattern as 2a — describe what Phase 1 delivered and what this agent can rely on.]

### Your Task

1. [Action 1]
2. [Action 2]
3. [Action 3]

### Do Not Touch

- `[file]` — [Phase 2a]'s domain
- `[file]` — does not exist yet, [Phase N]'s domain

### Verification

```bash
[command]
# → [expected output]
```

---

## Step 3 — Phase 3: [Phase Name]

**Branch:** `feat/phase-3-[short-name]`
**Depends on:** Steps 2a and 2b merged to main

**Prompt:**

You are implementing Phase 3 of [Project Name]. The full specification is in `planning/[spec-file].md` under "[Phase 3 Section Name]". Read that section carefully before writing any code.

### Context

All prior phases are complete:

- Phase 1: [one-line summary of what was built]
- Phase 2a: [one-line summary]
- Phase 2b: [one-line summary]

[State the current end-to-end capability and any CLI or interface contracts this agent must not break.]

### Your Task

1. [Action 1]
2. [Action 2]
3. [Action 3]

### Do Not Touch

- `[file]` — [Phase N] owns this; only read from it, do not modify
- `[file]` — not your domain

### Verification

```bash
[command 1]
# → [expected output]

[command 2]
# → [expected output]

[command 3]
# → [expected output]
```

---

<!--
Add further steps following the same pattern as needed.
Each step gets its own H2 section with the same sub-sections:
Branch, Depends on, Prompt intro, Context, Task, Do Not Touch, Verification.

Tips:
- Keep "Do Not Touch" lists current — add new files as they are
  introduced by earlier phases.
- Verification commands should be runnable in CI with no manual
  steps. Avoid "check the logs" — assert specific output.
- If a phase is very large, split it into sub-parts (A, B) within
  the same step rather than adding a new sequential step.
-->
