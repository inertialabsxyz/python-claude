# python-claude

A Python project template wired for working with Claude Code. It ships the toolchain
(ruff, mypy, pytest), a `make check` quality gate, and a set of enforceable working rules under
`.claude/rules/` (commit format, review gate, PR flow, test mandate).

## What's in the box

```
.
├── CLAUDE.md              # project brief + golden rules (fill in per project)
├── Makefile               # check / lint / typecheck / test / fix / install
├── pyproject.toml         # ruff + mypy (strict) + pytest config
├── src/app/               # your package (rename `app`)
├── tests/{unit,integration,eval}/
└── .claude/
    ├── settings.json      # shared hooks (ruff format on edit)
    └── rules/             # commits, testing, review-gate, pull-requests
```

## Using it for a new project

1. Create a repo from this template (GitHub "Use this template", or clone and re-init git).
2. Rename the package `app` to your name — update `src/app/`, `pyproject.toml` (`[project].name`,
   the rename comment), `Makefile` (`typecheck` target), and `tests/unit/test_smoke.py`.
3. Fill in `CLAUDE.md`: the description, tech stack, and design principles.
4. Add real dependencies to `pyproject.toml`.
5. Install and verify the gate:

   ```bash
   make install   # pip install -e ".[dev]"
   make check     # lint + type-check + test
   ```

## Quality gate

`make check` (lint + type-check + test) must pass before every commit — no exceptions. See
`.claude/rules/` for the full working conventions.
