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

### Quality gate

`make check` (lint + type-check + test) **must pass before every commit** — no exceptions. If it
fails, diagnose and fix before continuing.

### Golden rules

- Every feature commit ships with a test; every bug fix ships with a regression test.
- Requirements are the source of truth — implement exactly what is specified, no more.
- The base path must work without any optional step; enrichment is opt-in and degrades gracefully.
- Validate untrusted input at the API boundary; trust internal types.
- Secrets are server-side only — never echoed in responses or logs.
