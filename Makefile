.PHONY: check lint typecheck test test-unit test-integration test-eval fix install

# CI gate: must pass before every commit.
check: lint typecheck test

lint:
	ruff format --check .
	ruff check .

typecheck:
	mypy src/app

# All tests except the slow, optional evals.
test:
	pytest tests/unit tests/integration

test-unit:
	pytest tests/unit

test-integration:
	pytest tests/integration

# Optional pre-PR gate: deterministic evals over a golden set. Drop if the project has no evals.
test-eval:
	pytest tests/eval

fix:
	ruff format .
	ruff check --fix .

# One-time local setup: install the package with its dev tooling.
install:
	pip install -e ".[dev]"
