---
name: wiwa-code-taste
description: My personal code standards (readability, time handling, settings defaults, test style, backend vs frontend logic) and how to review against them. Use when I ask for a review of a diff, branch, PR or file, before committing, or when writing or changing code where these come up.
---

# My code taste

## The rules

### Readability
- People read top to bottom. Keep logic inline where it's used.
- Be sceptical of single-use functions and methods. Most of them work like a glorified goto: the reader
  has to jump away and back to follow one linear flow. Extract only when it names a real concept, is
  reused, or isolates something that is genuinely separate (I/O, a boundary, a hard algorithm).

### Time
- Use `timedelta` / `datetime` (or the language's equivalent) for durations and instants. Arithmetic
  like `60 * 60 * 24 * 365` or a bare `86400` is where bugs come from: write `timedelta(days=365)`.
- Keep the unit in the type, not in a variable name like `timeout_seconds` holding a raw int, where
  the API allows it.

### Settings
- Defaults are production values. Assume the code is going to production.
- Development conveniences (DEBUG, relaxed security, local hosts, console email backends) are opt-in
  overrides for local dev, never the default.

### Tests
- Test at the boundaries: through the public API, HTTP endpoints, management commands. Don't mock
  internal code. Mock only what you don't own and can't run (third-party network calls, payment
  providers), and prefer a fake at that boundary.
- Build test objects with factories. In Django, that means factory_boy. No hand-built fixtures, and no
  long `Model.objects.create(...)` calls repeated across tests.

### Where logic lives
- The backend holds the business logic. If the frontend filters, reshapes or derives data from an API
  we control, that belongs in the backend (a query param, a field, an endpoint).
- Frontend validation is only UX on top of backend validation. Every frontend rule needs a backend rule
  that enforces it. If keeping the two in sync automatically is awkward, remove the frontend
  validation and show the backend's errors instead.

## Reviewing against the rules

### Scope
- Default to the current diff (`git diff` plus staged changes, or the branch against its base). If I
  name a PR, branch or path, review that instead.
- Read enough of the surrounding code to judge each change in context: callers of a new function, the
  backend that serves a frontend change, and the settings module a new setting goes into.

### What to look for

#### Single-use functions
- A function or method added in this change with exactly one caller. Search for its callers before
  flagging it.
- Flag it when inlining would let the caller read top to bottom. Leave it when it names a real concept,
  isolates I/O or a boundary, or hides a genuinely hard piece.
- Suggest the inlined version, not just "consider inlining".

#### Raw time arithmetic
- Products of 60, 24, 7, 365, 1000, or literals like 3600, 86400, 604800, 31536000.
- Durations or timestamps passed around as bare ints/floats (`expires_in=3600`, `time.time() + ...`).
- Naive datetimes where the project uses aware ones (`datetime.now()` instead of `timezone.now()` in
  Django).
- The fix is `timedelta(...)` / `datetime`, or the framework's equivalent.

#### Settings defaults
- A new setting whose default is the development value: `DEBUG = True`, `ALLOWED_HOSTS = ["*"]`, an
  insecure cookie, a console email backend, a localhost URL, a placeholder secret, or disabled HTTPS or
  CSRF.
- `env("X", default=<dev value>)`. The default should be the production value, or missing secrets
  should fail loudly.
- The dev override belongs in local or dev settings, `.env.example`, or a devcontainer.

#### Tests
- `mock.patch`, `MagicMock`, `monkeypatch` or `unittest.mock` aimed at our own code. Ask what boundary
  the test could go through instead (the test client, a public function, the DB).
- Mocks of third-party network services are fine.
- Hand-built objects (`Model.objects.create(...)` with many fields, dict fixtures, JSON fixtures)
  where a factory_boy factory exists or should exist. Suggest the factory.
- Tests that assert on internal calls ("was called with") instead of observable results.

#### Logic in the frontend
- Frontend code that filters, sorts, groups, joins or derives values from a response from our own API.
  Suggest the backend change: a query param, a serializer field, an annotation, an endpoint.
- Business rules duplicated in the frontend (pricing, permissions, status transitions).

#### Frontend validation
- For each frontend validation rule in the change, find the backend rule that enforces it (serializer,
  form, model, or DB constraint).
- If there is no backend rule, that's a bug: add one.
- If both exist but are maintained by hand and could drift, recommend dropping the frontend rule and
  surfacing the backend error, unless they're kept in sync automatically (a shared schema or generated
  rules).

#### Also
Flag correctness bugs, security problems and unclear naming, even when they aren't on this list.

### Output
- Findings ranked most important first. Each one gives `file:line`, what's wrong, and the concrete fix,
  with a short code snippet where that helps.
- Mark each one **must fix** (bug, prod-unsafe default, missing backend validation) or **taste**.
- Say plainly when a category has nothing to report. Don't pad.
- Don't edit files unless I ask.
