# PROJECT_NAME

> Template project. Fill in the sections below for your project, then delete this quote block.
> Rename the `app` package (`src/app/`, `pyproject.toml`, `Makefile`, tests) to your package name.

One-paragraph description of what this project is and does: the problem it solves, who consumes
it, and the shape of its inputs and outputs. Keep it tight — this is the first thing an agent
reads.

Full spec (if any): `docs/…`.

## Tech stack

- **Language:** Python (>=3.11).
- **Tooling:** ruff (format + lint), mypy (strict), pytest.
- _Add the frameworks/libraries this project actually uses (web framework, DB, LLM provider,
  etc.). Keep it to what is real — no speculative dependencies._

## Design principles

- _List the load-bearing invariants for this project — the rules an agent must not violate._
- _E.g. determinism, fail-soft behaviour, validation only at boundaries, no secrets in logs._

## Working conventions

The `.claude/rules/` directory holds the enforceable rules — read them before working:

- **`.claude/rules/testing.md`** — the quality gate and the test mandate.
- **`.claude/rules/commits.md`** — commit format and scopes; auto-commit each logical change.
- **`.claude/rules/review-gate.md`** — spawn a review agent before every PR (hard gate).
- **`.claude/rules/pull-requests.md`** — draft PRs to `main` + the agent run report comment.

### Phased / parallel builds

When a build is large enough to split across multiple agents and decomposes into modules with
disjoint file ownership (e.g. delivery phases laid out in a `docs/…-architecture.md`), decompose
the spec into a `prompts/` folder of self-contained phased briefs rather than one monolithic
prompt. Two checked-in templates drive this:

- **`.claude/templates/agent-coordination.md`** — the **methodology**: read it first. Derives the
  module/file-ownership map, the dependency graph → phase assignment, parallel-vs-sequential rules,
  the Phase 1 foundation/frozen-contracts/stubs pattern, and the final integration phase. Output is
  one file per phase plus a `prompts/README.md` schedule.
- **`.claude/templates/agent-prompts.md`** — the **scaffold**: the shape of one filled-in prompt set
  (sequencing diagram + per-phase Branch / Context / Task / Do Not Touch / Verification).

Invariants: one source of truth (phase files reference the spec by section, never restate it);
self-contained prompts (no agent reads another's); disjoint ownership enforced by "Do Not Touch";
stubs first (Phase 1 stubs later modules); freeze shared contracts (types, schema, config) in
Phase 1; a consumer mocks a producer's stub, never implements it; concrete verification (commands +
expected output); sequential by default — parallelise only when independence is proven.

### Quality gate

`make check` (lint + type-check + test) **must pass before every commit** — no exceptions. If it
fails, diagnose and fix before continuing.

### Golden rules

- Every feature commit ships with a test; every bug fix ships with a regression test.
- Requirements are the source of truth — implement exactly what is specified, no more.
- The base path must work without any optional step; enrichment is opt-in and degrades gracefully.
- Validate untrusted input at the API boundary; trust internal types.
- Secrets are server-side only — never echoed in responses or logs.
