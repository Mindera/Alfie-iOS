## Phase 1: Error model + timeout

### Goal

Extend `BFFRequestError` with the new typed cases the rest of the work depends on, and enforce an explicit request timeout on the Apollo transport.

### Steps

1. **Extend `BFFRequestErrorType`** (file: `AlfieKit/Sources/Model/Services/BFFService/BFFRequestError.swift:4`)
   - Add cases:
     ```swift
     case rateLimited(retryAfter: TimeInterval?)
     case timeout
     case serverError(status: Int)
     ```
   - Update `Equatable` synthesis (compiler-generated — verify `.rateLimited(nil) == .rateLimited(nil)` holds in tests).
   - Leave `isNotFound` unchanged (none of the new cases are not-found).
   - **Why:** typed cases are required for downstream interceptors, telemetry, and UI to switch on.
   - **Test:** `AlfieKit/Tests/CoreTests/HelperTests/BFFRequestErrorTests.swift` — add equality + `isNotFound = false` assertions for each new case.

2. **Configure session timeouts** (file: `AlfieKit/Sources/Core/Services/BFFService/BFFClientService.swift:18`)
   - In `init`, before constructing `URLSessionClient`:
     ```swift
     sessionConfiguration.timeoutIntervalForRequest = 30
     sessionConfiguration.timeoutIntervalForResource = 60
     ```
   - **Why:** without these, Apollo inherits `.default` (60s request / 7d resource) — calls can hang the UI.
   - **Note:** `sessionConfiguration` is a `let` param defaulting to `.default`. `URLSessionConfiguration` is a class so mutation works; but `.default` returns a *new* copy each call, so this is safe. Confirm with an `assert` in tests.

3. **Map `URLError.timedOut` in `resultAsFailure`** (file: `AlfieKit/Sources/Core/Services/BFFService/BFFClientService.swift:155`)
   - Inside the `.failure(let error)` branch, before the existing `as? BFFRequestError` check:
     ```swift
     if let urlError = error as? URLError, urlError.code == .timedOut {
         return BFFRequestError(type: .timeout, error: error)
     }
     ```
   - **Why:** surface timeout as a discrete typed error rather than `.generic`.
   - **Test:** stub a `URLError(.timedOut)` through Apollo (or call `resultAsFailure` directly with a synthesized `.failure(URLError(.timedOut))`) — assert `.timeout` returned.

4. **Decide call site for the timeout config**
   - Option A (chosen): mutate the incoming `sessionConfiguration` in `BFFClientService.init` — keeps the contract that callers can pass `.default` and get sane behaviour.
   - Option B (rejected): require callers to set timeouts. Rejected — easy to forget; the service owns its network semantics.

### Verification

- Run `./Alfie/scripts/verify.sh` — build + tests must pass.
- Inspect `BFFRequestErrorTests` output — new cases covered.
- (Manual, deferred to Phase 4) point app at a slow endpoint and confirm timeout surfaces.

### Estimated Effort

**S** — ~30 LoC across 2 source files + ~40 LoC of tests.
