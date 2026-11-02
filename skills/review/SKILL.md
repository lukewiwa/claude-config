---
name: review
description: Review code against my personal standards (readability, time handling, settings defaults, test style, backend vs frontend logic). Use when I ask for a review of a diff, branch, PR or file, or before committing.
---

# Review against my standards

The standards are in `~/.claude/CLAUDE.md`. This is how to check a change against them.

## Scope
- Default to the current diff (`git diff` plus staged changes, or the branch against its base). If I
  name a PR, branch or path, review that instead.
- Read enough of the surrounding code to judge each change in context: callers of a new function, the
  backend that serves a frontend change, and the settings module a new setting goes into.

## What to look for

### Single-use functions
- A function or method added in this change with exactly one caller. Search for its callers before
  flagging it.
- Flag it when inlining would let the caller read top to bottom. Leave it when it names a real concept,
  isolates I/O or a boundary, or hides a genuinely hard piece.
- Suggest the inlined version, not just "consider inlining".

### Raw time arithmetic
- Products of 60, 24, 7, 365, 1000, or literals like 3600, 86400, 604800, 31536000.
- Durations or timestamps passed around as bare ints/floats (`expires_in=3600`, `time.time() + ...`).
- Naive datetimes where the project uses aware ones (`datetime.now()` instead of `timezone.now()` in
  Django).
- The fix is `timedelta(...)` / `datetime`, or the framework's equivalent.

### Settings defaults
- A new setting whose default is the development value: `DEBUG = True`, `ALLOWED_HOSTS = ["*"]`, an
  insecure cookie, a console email backend, a localhost URL, a placeholder secret, or disabled HTTPS or
  CSRF.
- `env("X", default=<dev value>)`. The default should be the production value, or missing secrets
  should fail loudly.
- The dev override belongs in local or dev settings, `.env.example`, or a devcontainer.

### Tests
- `mock.patch`, `MagicMock`, `monkeypatch` or `unittest.mock` aimed at our own code. Ask what boundary
  the test could go through instead (the test client, a public function, the DB).
- Mocks of third-party network services are fine.
- Hand-built objects (`Model.objects.create(...)` with many fields, dict fixtures, JSON fixtures)
  where a factory_boy factory exists or should exist. Suggest the factory.
- Tests that assert on internal calls ("was called with") instead of observable results.

### Logic in the frontend
- Frontend code that filters, sorts, groups, joins or derives values from a response from our own API.
  Suggest the backend change: a query param, a serializer field, an annotation, an endpoint.
- Business rules duplicated in the frontend (pricing, permissions, status transitions).

### Frontend validation
- For each frontend validation rule in the change, find the backend rule that enforces it (serializer,
  form, model, or DB constraint).
- If there is no backend rule, that's a bug: add one.
- If both exist but are maintained by hand and could drift, recommend dropping the frontend rule and
  surfacing the backend error, unless they're kept in sync automatically (a shared schema or generated
  rules).

### Also
Flag correctness bugs, security problems and unclear naming, even when they aren't on this list.

## Output
- Findings ranked most important first. Each one gives `file:line`, what's wrong, and the concrete fix,
  with a short code snippet where that helps.
- Mark each one **must fix** (bug, prod-unsafe default, missing backend validation) or **taste**.
- Say plainly when a category has nothing to report. Don't pad.
- Don't edit files unless I ask.
