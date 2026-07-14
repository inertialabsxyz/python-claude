# Review Gate

After completing a feature or bug fix — before opening a PR — the implementation agent **must** spawn a review agent to verify the work against the source requirements. This is a hard gate, equivalent to `make check`.

## When to trigger

Spawn the review agent once:
- All implementation commits are done
- `make check` passes on the current branch
- You are about to open the PR

## How to spawn the review agent

Call the `Agent` tool with a prompt that includes:
1. The requirements/spec doc and the section that specifies the requirements
2. The files that were changed
3. A one-sentence summary of what was implemented

**Template:**

```
Agent({
  description: "Requirements review: <feature name>",
  prompt: """
You are a review agent. Your job is to verify a completed implementation against its
source requirements, fix any gaps, and commit the fixes.

## What was implemented
<one-sentence summary of the feature/fix>

## Requirements source
Read the requirements from: <path/to/spec>, section "<Section Name>".

## Files changed
<list the changed files>

## Your task
1. Read the named requirements section(s)
2. Read each changed file
3. For every requirement in that section, verify it is fully implemented
4. For any gap found: fix it, then run `make check` to confirm it passes
5. If the project has evals and the change touches the covered behaviour, also run
   `make test-eval` and confirm the relevant eval stays green
6. If you made any fixes, commit each one with: fix(scope): <description>

Do not refactor, rename, or improve code beyond what the requirements specify.
Do not add features that are not in the requirements section.
If make check fails after your fix, diagnose and resolve before committing.

## Your output

Return a structured markdown report using exactly this format:

### Requirements Checked
- <requirement 1> — PASS / FAIL / FIXED
- <requirement 2> — PASS / FAIL / FIXED
...

### Gaps Found
<bullet list of gaps, or "None">

### Fixes Made
<bullet list of commits made, each with message and one-line description, or "None">

### Quality Gate
`make check`: PASS / FAIL
`make test-eval`: PASS / FAIL / N/A
"""
})
```

Capture the review agent's returned report — you will need it for the PR comment.

## What the review agent checks

- Every requirement bullet in the spec section is present in the implementation
- Types / schemas defined in the spec exist with the correct fields
- Logic named in the spec is implemented in the correct module
- Tests required by the spec exist and pass; any relevant eval covers the change
- No spec-required behaviour is silently skipped or stubbed
- Every new behaviour has at least one test; every bug fix has a regression test that would have caught it
- The project's design invariants are preserved (see `CLAUDE.md` → Design principles)

The review agent does **not** open the PR. Once it reports back, proceed to open the draft PR.
