# Code taste

These apply to code I write and code I review. The `review` skill covers how to check for them.

## Readability
- People read top to bottom. Keep logic inline where it's used.
- Be sceptical of single-use functions and methods. Most of them work like a glorified goto: the reader
  has to jump away and back to follow one linear flow. Extract only when it names a real concept, is
  reused, or isolates something that is genuinely separate (I/O, a boundary, a hard algorithm).

## Time
- Use `timedelta` / `datetime` (or the language's equivalent) for durations and instants. Arithmetic
  like `60 * 60 * 24 * 365` or a bare `86400` is where bugs come from: write `timedelta(days=365)`.
- Keep the unit in the type, not in a variable name like `timeout_seconds` holding a raw int, where
  the API allows it.

## Settings
- Defaults are production values. Assume the code is going to production.
- Development conveniences (DEBUG, relaxed security, local hosts, console email backends) are opt-in
  overrides for local dev, never the default.

## Tests
- Test at the boundaries: through the public API, HTTP endpoints, management commands. Don't mock
  internal code. Mock only what you don't own and can't run (third-party network calls, payment
  providers), and prefer a fake at that boundary.
- Build test objects with factories. In Django, that means factory_boy. No hand-built fixtures, and no
  long `Model.objects.create(...)` calls repeated across tests.

## Where logic lives
- The backend holds the business logic. If the frontend filters, reshapes or derives data from an API
  we control, that belongs in the backend (a query param, a field, an endpoint).
- Frontend validation is only UX on top of backend validation. Every frontend rule needs a backend rule
  that enforces it. If keeping the two in sync automatically is awkward, remove the frontend
  validation and show the backend's errors instead.
