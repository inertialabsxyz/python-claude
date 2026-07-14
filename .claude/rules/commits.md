# Commits

**Gate:** `make check` (lint + type-check + test) must pass before every commit. No exceptions.

**Auto-commit:** Commit each logical change as it is completed, without waiting to be asked. Use judgment to determine when a change is coherent and complete — do not commit mid-feature or bundle unrelated changes.

**Message format:** `type(scope): short description`

- `type` — `feat`, `fix`, `refactor`, `test`, `docs`, `chore`
- `scope` — the package or module most affected (e.g. `api`, `config`, `schemas`, `tests`,
  `docs`, `repo`, `ci`). Define the project's real scopes here as they emerge.
- Description — imperative, lowercase, no period. 72 characters total max.

```
feat(api): add pagination to the list endpoint
fix(config): default missing timeout to 30s instead of crashing
refactor(providers): move adapter behind a Protocol
test(parser): assert malformed input raises a clean error
docs(readme): document the environment variables
```

**Scope:** One logical change per commit. Don't bundle unrelated fixes.
