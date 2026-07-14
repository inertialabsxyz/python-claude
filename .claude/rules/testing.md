# Testing & Quality

## Makefile targets

```bash
make check       # CI gate: lint + type-check + test (must pass before every commit)
make lint        # ruff format --check + ruff check
make typecheck   # mypy over the package
make test        # all tests: unit + integration
make test-unit   # pytest tests/unit  (pure functions, no network/IO)
make test-eval   # pytest tests/eval  (optional deterministic evals over a golden set)
make fix         # ruff format + ruff check --fix (auto-fix safe issues)
```

`make check` is the hard pre-commit gate — it runs lint, type-check, and tests. Run it before
every commit. If it fails, diagnose and fix before continuing; never bypass it.

`make test-eval` is an **optional pre-PR** gate for projects that carry a golden set — e.g.
anything with an LLM in the pipeline, where outputs must stay reproducible and grounded. It is not
in `make check` because it can be slow (full pipeline, external runtimes). Drop the target and
`tests/eval/` entirely if the project has no evals.

Any external service (LLM, network, browser) must be mocked or recorded in tests — the suite must
run offline and must not depend on live responses.

## Test mandate

Every feature commit must include at least one test for the new behaviour. Every bug fix must
include a regression test that would have caught the bug. These are not optional — a commit that
adds behaviour without a test, or fixes a bug without a regression test, is incomplete.

If a behaviour genuinely cannot be exercised without infrastructure that is unavailable in tests
(e.g. a real provider outage), document why in the PR description. This should be rare.

## Two test patterns

**Unit tests** — live in `tests/unit/`, importing the module under test. Use for any logic that
can be exercised without network or IO: input validation, pure transforms, prompt/string building,
config loading, accounting.

```python
# tests/unit/test_example.py
from app.thing import normalize


def test_normalize_strips_and_lowercases():
    assert normalize("  Hello ") == "hello"
```

**Integration tests** — live in `tests/integration/` and exercise the public interface end-to-end
(e.g. a web API via a test client, a CLI via subprocess), with external services mocked or
recorded. Use for: the request/response contract, auth rejection, orchestration and
partial-failure handling.

```python
# tests/integration/test_api.py
def test_endpoint_returns_expected_shape(client):
    resp = client.post("/thing", json=VALID_INPUT)
    assert resp.status_code == 200
    assert set(resp.json()) == {"a", "b", "c"}
```

## Optional: golden set & deterministic evals (`tests/eval/`)

For projects where output quality/grounding matters (typically LLM-backed), keep a fixed set of
representative inputs in the repo and run them through the full pipeline. Evals should be
objective, code-checkable assertions — no human or model judgment — asserting the contract holds
(well-formed output, required fields present, input facts preserved verbatim, partial results on
failure). Pin any model to a fixed version + low/fixed temperature so runs are reproducible.

## What to test at each layer

| Layer | Pattern | Example |
|---|---|---|
| Pure helpers (validation, transforms, string building) | Unit test in `tests/unit/` | `normalize`, formatters |
| Input validation | Unit; assert malformed input is rejected cleanly | missing required field |
| Public API/CLI contract + auth | Integration via a test client | happy path, `401` on bad key |
| Orchestration & partial failure | Integration; force one branch to fail | fail-soft partial results |
| Determinism / grounding (if applicable) | Eval over the golden set with pinned inputs | facts preserved verbatim |

## Lint & types

`make lint` runs `ruff format --check` and `ruff check`; `make typecheck` runs `mypy`. Fix
warnings rather than silencing them. If a targeted `# noqa: <rule>` or `# type: ignore[<code>]`
is genuinely required, attach a one-line comment explaining why. Never disable ruff or mypy
globally at the module or package level.
