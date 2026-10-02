# Agent Coordination — Methodology for Phased, Parallel Agent Prompts

<!-- ============================================================
WHAT THIS IS

A reusable *process* document. Given a single detailed implementation
spec, it leads Claude to decompose that spec into a `prompts/` folder of
self-contained, phased agent briefs — some of which run in parallel across
multiple agents — without those agents colliding.

Relationship to the sibling template `agent-prompts.md`:
  - `agent-prompts.md`  = the SCAFFOLD: the shape of one filled-in prompt set.
  - `agent-coordination.md` (this file) = the METHODOLOGY: how to derive that
    decomposition from a spec, output as ONE FILE PER PHASE plus an index.

Use this when you have a non-trivial build that benefits from (a) splitting
across multiple agents and (b) running independent work in parallel to save
wall-clock time.
============================================================ -->

These prompts are designed to be handed directly to Claude Code agents. Each agent starts
fresh with no memory of the others, works on its own git branch, and must never need to
read another agent's prompt. The job of this methodology is to make that safe.

---

## 0. When to use this

Use it when **all** of these hold:
- There is (or you can first write) a **single master spec** with enough detail that every
  formula, schema, interface, and contract lives in one place.
- The work is large enough that splitting it across agents is worth the coordination cost.
- The system decomposes into **modules with distinct file ownership** (so parallel agents
  can touch disjoint files).

If the work is small, or every change touches the same files, skip this — write one prompt.
**Parallelism is an optimisation, not a goal.** When unsure whether two phases are
independent, make them sequential.

---

## 1. Inputs: the master spec

Everything downstream references **one master spec** (e.g. `docs/<spec>.md`, optionally with a
companion architecture doc). It is the single source of truth. Before decomposing, confirm the
spec contains: the tech stack (decided, not "pick one"), the architecture, the data
model/schema, the core algorithms/formulas, the external interfaces (API/contracts), error
& failure requirements, out-of-scope guardrails, and a definition of done. If any are
missing, fix the spec first — the phase files will *reference it by section*, not restate
it, so gaps propagate.

---

## 2. Output: the `prompts/` folder

```
prompts/
├── README.md                     # the schedule: sequencing diagram, phase table, dispatch rules
├── phase-1-<foundation>.md       # Step 1 — single agent
├── phase-2a-<module>.md          # Step 2 ┐
├── phase-2b-<module>.md          #        ├ parallel agents (disjoint files)
├── phase-2c-<module>.md          #        ┘
├── phase-3-<module>.md           # Step 3 — single agent (depends on Step 2)
└── phase-4-<integration>.md      # Step 4 — integration, verify, docs
```

One file per phase. The master spec stays where it is (e.g. `docs/`) and is **not** duplicated.

---

## 3. HOW TO USE (invocation)

Hand Claude this instruction, substituting your spec path:

> Read the full specification in `<master-spec>.md`. Using the methodology in
> `.claude/templates/agent-coordination.md`, decompose it into a `prompts/` folder of
> phased agent briefs. Produce a `prompts/README.md` schedule plus one self-contained file
> per phase. Follow the module-ownership, stubs-first, freeze-shared-contracts, and
> self-containment rules. Do not invent features not in the spec; prefer sequential over
> parallel when independence is uncertain.

---

## 4. The process

### Step A — Derive the module/file ownership map (do this FIRST)

Parallelism is bought entirely by **disjoint file ownership**, so decide the file layout
before anything else. From the spec's architecture, list the modules and assign each a
directory/file. Every later phase will *own* a set of these and *not touch* the rest.

Example shape (adapt names to the project):
```
src/
  config / constants / types        → Phase 1 (frozen shared contracts)
  db/schema + db/client             → Phase 1 (schema frozen after P1)
  <leaf-module-A>/                  → one parallel phase
  <leaf-module-B>/                  → another parallel phase
  <interface-layer>/ (api/cli/...)  → another parallel phase
  <orchestrator>/ (uses A + B)      → a later sequential phase
  scripts/verify, README, docs      → final integration phase
```

A clean map makes the "Do Not Touch" lists write themselves.

### Step B — Build the dependency graph → assign phases

Draw edges: module X depends on module Y if X imports Y's *real behaviour* at build or run
time. Then:
- **Leaf modules** (pure logic, raw I/O adapters) usually have no dependencies on siblings
  → candidates for parallel Phase 2.
- **Orchestrators** (that wire leaves together) depend on those leaves → later sequential
  phases.
- **Interface layers** (API/CLI) often depend only on the data store + shared contracts →
  can run parallel to the leaves *if* you use the stub pattern (Step D).

A phase = the set of files one agent owns + the dependencies that must be merged before it
starts.

### Step C — Decide parallel vs sequential

Two phases may run in parallel **only if** they (1) touch disjoint files and (2) depend
only on already-merged phases — not on each other's runtime behaviour. If either fails,
sequence them. When in doubt, sequence.

### Step D — Design Phase 1 as foundation + frozen contracts + stubs

Phase 1 is always a single agent and always does three things:
1. **Scaffold** — project, tooling, the single quality-gate command, infra (compose, env).
2. **Freeze the shared contracts** — the types/interfaces, the DB schema, config, and
   constants that *every* later phase compiles against. Declare these **frozen**: no later
   phase modifies them (especially the schema — a migration on a parallel branch is the
   classic conflict). If something shared genuinely needs to change later, that's a signal
   to stop and fix Phase 1, not to edit it from a parallel branch.
3. **Stub every later module** — create each later phase's entry file with typed signatures
   that `raise NotImplementedError("Phase X")` (and placeholder types). Mark each
   `# Phase X stub — owner implements`. This is what lets parallel agents **type-check and
   import against each other's future work** without it existing yet. Only the designated owner
   ever implements a stub. (Adapt the raise/comment syntax to the project's language.)

### Step E — Write each phase file (self-contained)

Every phase file has the same sections (see §6 template). Rules:
- **Reference the master spec by section number** ("implement per §6") instead of copying
  formulas — keeps one source of truth and prevents divergence.
- **Restate the context** an agent needs: what prior phases delivered, which files/exports
  it can rely on. The agent must never need another agent's prompt.
- **Name the boundaries**: an explicit "Do Not Touch" list of every directory owned by
  another phase, plus "frozen" files.
- **Make verification concrete**: runnable commands with expected output, including the
  check that the phase's own stubs no longer throw.

### Step F — Handle soft cross-phase contracts

When a parallel phase needs a function another parallel phase owns (e.g. the API needs a
calculation from the core module), do **not** sequence them just for that. Instead:
- the consumer imports the **stub** signature (from Phase 1),
- the consumer **mocks** it in its own tests,
- correctness of the real wiring is **validated at the integration phase**.

State this explicitly in both the consumer's prompt and the integration prompt.

### Step G — Write the overview/schedule (`prompts/README.md`)

It contains: the sequencing diagram, a phase table (Phase | File | Owns | Depends on |
Parallel?), the dispatch rules (merge gates), and the **conventions shared by all phases**
(quality gate, commit format, branch naming, the frozen-schema rule, out-of-scope
guardrails). This is the only file a human reads to dispatch the run.

### Step H — Final integration phase

Always end with a single sequential phase that: wires the pieces end-to-end, writes the
verification script, validates the soft contracts mocked during parallel dev, produces the
docs/deliverables, and runs a **scope sweep** against the spec's out-of-scope list. Its
verification *is* the spec's definition of done.

---

## 5. Design principles (the invariants)

- **One source of truth.** Detail lives in the master spec; phase files reference it.
- **Self-contained prompts.** No agent reads another agent's prompt.
- **Disjoint ownership = parallelism.** Boundaries come from the file map, enforced by
  "Do Not Touch".
- **Stubs first.** Phase 1 stubs let parallel agents type-check/import against future work.
- **Freeze shared contracts early.** Types, schema, config, constants are set in Phase 1
  and not edited downstream.
- **Stubs stay stubs until their owner implements them.** A consumer mocks; it never
  implements another phase's stub.
- **Concrete verification.** Commands + expected output, never "make sure it works".
- **Sequential by default.** Parallel only when independence is proven.

---

## 6. Per-phase file template

````markdown
# Step <N> — Phase <id>: <Name>

**Branch:** `feat/phase-<id>-<short-name>`
**Depends on:** <prior phases merged to main, or "nothing (first phase)">
**Runs in parallel with:** <sibling phases, or omit>

**Prompt:**

You are implementing <phase> of <project>. The full specification is the master spec at
`<master-spec>.md`. Read **§<X> (<title>)** [and §…] before writing code. <One-sentence
scope statement of what this phase does and explicitly does not do.>

### Context (what prior phases delivered — you can rely on this)
- <file/module> — <what it provides; which exports are stable contracts>
- <your stub file> — **raises `NotImplementedError("Phase <id>")`** — yours to implement; keep
  signatures stable (imported by <later phase>).

### Your Task
1. <action — exact file to create/modify, referencing the spec section>
2. …
<Include any phase-specific discipline the spec requires, e.g. error handling, fixed-point math.>

### Do Not Touch
- `<dir>/**` — <other phase>'s domain.
- `<shared file>` — **frozen**; read only.
- <other phases' stubs> — leave as stubs.

### Verification
```bash
<quality-gate command>            # → pass
<phase-specific command>          # → <expected observable output>
```
Confirm <this phase's stub> no longer raises `NotImplementedError`.
````

---

## 7. Overview file template (`prompts/README.md`)

```markdown
# Project Schedule — <Project>

Self-contained phased prompts implementing `<master-spec>.md`. Each phase file is a
complete brief; agents never read each other's prompts. Single source of truth: the spec.

## Sequencing Overview
<ascii dependency diagram: Step 1 → (parallel Step 2) → Step 3 → Step 4>

**Dispatch rules:** do not start a step until its dependencies are merged; parallel
siblings use separate branches and touch disjoint files; merge all before the next step.

## Phase summary
| Phase | File | Owns (writes) | Depends on | Parallel? |
|-------|------|---------------|------------|-----------|
| …     | …    | …             | …          | …         |

## Conventions shared by every phase
- Quality gate: `<command>` must pass before every commit.
- Commits: `type(scope): description`, one logical change each.
- Branch naming: global `type/short-name` convention; phased builds use
  `feat/phase-<id>-<short-name>`.
- `<schema/contract file>` is frozen after Phase 1.
- Out-of-scope guardrails from spec §<X> apply to every phase.

## How to dispatch
1. Run Phase 1; review; merge. 2. Launch parallel phases concurrently; merge all.
3. Run later sequential phases. 4. Run integration; the build is then complete.
```

---

## 8. Decomposition heuristics

- **Cut at import boundaries, not feature boundaries.** Two "features" in the same file are
  one phase; one feature spanning two clean modules can be two.
- **Pure logic and raw-I/O adapters are the best parallel leaves** — they have the fewest
  dependencies and the cleanest test surfaces.
- **The interface layer (API/CLI) can usually parallelise with the leaves** via stubs +
  mocks + fixture seeding, because it only reads the data store + shared contracts.
- **The orchestrator that wires leaves together is sequential**, after those leaves merge.
- **3–5 phases is typical.** If you have more than ~6, you're probably cutting too fine;
  merge siblings that share files.

---

## 9. Common pitfalls

- **Schema/contract edits on parallel branches** → the #1 merge conflict. Freeze in Phase 1.
- **A consumer implementing a producer's stub** "to unblock itself" → divergent
  implementations. Mock instead; let the owner implement.
- **Duplicating spec detail into phase files** → the copies drift. Reference by section.
- **Phase files that assume knowledge from a sibling** → breaks self-containment. Restate
  the context.
- **Over-parallelising** → coordination overhead and conflicts exceed the wall-clock win.
  Sequence when unsure.
- **Vague verification** ("check it works") → agents can't self-confirm. Give commands and
  expected output, including the "stub no longer raises" check.
