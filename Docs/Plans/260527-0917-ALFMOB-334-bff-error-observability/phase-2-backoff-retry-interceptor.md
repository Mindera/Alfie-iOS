## Phase 2: Backoff retry interceptor

### Goal

Add a custom `BackoffRetryInterceptor` that retries transient failures with exponential backoff and honours `Retry-After`. Add a `RateLimitMappingInterceptor` so un-retried 429/430 responses surface as typed errors. **Keep** Apollo's `MaxRetryInterceptor` at the front of the chain as a safety cap — do **not** remove it (see Apollo iOS interceptor review for rationale).

### Apollo iOS v1.19 chain semantics (read before implementing)

- Chain is **forward-only**: each interceptor's `interceptAsync(chain:request:response:completion:)` is invoked in declared order. On first pass through a front interceptor, `response` is `nil`. The `response` is only populated after `NetworkFetchInterceptor` runs.
- `ResponseCodeInterceptor` throws on 4xx/5xx via `chain.handleErrorAsync` — this **short-circuits subsequent interceptors**. Any interceptor that needs to act on a 4xx/5xx response must run **before** `ResponseCodeInterceptor`.
- Retries are triggered by calling `chain.retry(request:completion:)` — this restarts the chain from position 0 with fresh interceptor instances? No — same instances. Per-operation `InterceptorProvider.interceptors(for:)` is called once per operation; the same array is reused across retries of that operation. State on interceptor instances persists across retries (this is what `MaxRetryInterceptor` relies on to count).
- `Operation.operationType` discriminates queries vs mutations. Guard mutation retries.

### Steps

1. **Add `RateLimitMappingInterceptor`** (file: `AlfieKit/Sources/Core/Services/BFFService/Interceptors/RateLimitMappingInterceptor.swift` — **NEW**)
   - Implement `ApolloInterceptor`.
   - In `interceptAsync`, if `response?.httpResponse.statusCode` is 429 or 430:
     - Parse `Retry-After` header — try `Int` first (seconds), then all **three RFC 7231 §7.1.1.1 date formats** (IMF-fixdate, RFC 850, asctime) → `TimeInterval` delta from now. On any parse failure, return `nil` (lets `BackoffRetryInterceptor` fall back to its own backoff math).
     - Call `chain.handleErrorAsync(BFFRequestError(type: .rateLimited(retryAfter: parsed)), …)`.
   - Otherwise: `chain.proceedAsync(...)`.
   - **Pattern reference:** `NetworkPreConditionInterceptor.swift:14` for `handleErrorAsync` usage.
   - **Order:** must run *after* `BackoffRetryInterceptor` (so backoff gets first crack at retrying 429) and *before* `ResponseCodeInterceptor` (which would otherwise throw a generic `ResponseCodeError`). Reads `response.httpResponse.statusCode`, available after `NetworkFetchInterceptor`.

2. **Add `BackoffRetryInterceptor`** (file: `AlfieKit/Sources/Core/Services/BFFService/Interceptors/BackoffRetryInterceptor.swift` — **NEW**)
   - Implement `ApolloInterceptor`.
   - State: `private var retryCount: Int = 0`. `NetworkInterceptorProvider.interceptors(for:)` constructs a fresh array per operation, so per-instance state is per-operation. **Add an explanatory comment** on the property documenting this contract — a future refactor that caches the array would silently break retry counting.
   - Config struct (defaults from `plan.md`):
     ```swift
     struct RetryConfig {
         var baseDelay: TimeInterval = 0.5
         var multiplier: Double = 2.0
         var maxRetries: Int = 3
         var perAttemptCap: TimeInterval = 8
         var retryAfterCap: TimeInterval = 30
     }
     ```
   - **Placement:** sits **after** `ResponseLogInterceptor` and **before** `RateLimitMappingInterceptor` + `ResponseCodeInterceptor`. This position is the only one where the interceptor can both (a) inspect `response.httpResponse.statusCode` (populated by `NetworkFetchInterceptor` upstream) and (b) decide whether to call `chain.retry(...)` before `ResponseCodeInterceptor` throws on 4xx/5xx.
   - In `interceptAsync`:
     - **DO NOT retry mutations:** guard with `guard Operation.operationType == .query else { chain.proceedAsync(...); return }`. Confirm v1's `GraphQLOperationType` casing (likely `.query` / `.mutation` / `.subscription`).
     - Read `response?.httpResponse.statusCode` (non-nil here since we sit post-fetch). On retryable condition:
       - Status `500, 502, 503, 504` → retry with computed backoff. (Skip 501/505 — permanent.)
       - Status `429, 430` → retry honouring `Retry-After` if `<= retryAfterCap`, else `chain.proceedAsync(...)` so `RateLimitMappingInterceptor` maps the surviving error to `.rateLimited`.
       - Anything else → `chain.proceedAsync(...)`.
     - **Transport errors (URLError) are NOT auto-retried** in Apollo v1.19. `NetworkFetchInterceptor` calls `chain.handleErrorAsync` on transport failure, which bypasses subsequent interceptors. Transport errors surface to `resultAsFailure` (Phase 1) as `.timeout` / `.generic` and rely on user-tap retry. (v2 migration would unlock auto-retry here via `.mapErrors`.)
     - Backoff math: `delay = min(baseDelay * pow(multiplier, Double(retryCount)), perAttemptCap)`.
     - **Retry:** wrap `Task.sleep(nanoseconds:)` in a `Task { … }`. On wake, call `chain.retry(request:completion:)`. Increment `retryCount` **before** sleeping so the counter survives if `chain.retry` re-enters this same instance.
     - After `maxRetries` exhausted → `chain.proceedAsync(...)` (let downstream map and surface the final error). Set `retryCount` into the final propagated `BFFRequestError` (Phase 3, Plan B).
   - **Cancellation:** check `Task.checkCancellation()` before and after sleep; on `CancellationError`, call `chain.handleErrorAsync(CancellationError(), …)` instead of retrying.
   - **APQ interaction:** `AutomaticPersistedQueryInterceptor` surfaces APQ-not-found as a GraphQL error code `PersistedQueryNotFound` (HTTP 200) — *not* a 5xx — and triggers its own retry internally. `BackoffRetryInterceptor`'s status-based logic naturally skips this case. Verify with the APQ-passthrough test below.

3. **Rewire chain** (file: `AlfieKit/Sources/Core/Services/BFFService/NetworkInterceptorProvider.swift:27`)
   - **Keep** `MaxRetryInterceptor()` at position 1 (line 33) — safety cap against runaway retry loops. Bump its limit if needed so it doesn't collide with `BackoffRetryInterceptor.maxRetries=3` (use `MaxRetryInterceptor(maxRetriesAllowed: 5)` if v1.19 exposes it; otherwise the default).
   - After `NetworkFetchInterceptor` (line 40) and `ResponseLogInterceptor` (line 42), insert `BackoffRetryInterceptor` then `RateLimitMappingInterceptor`, before `ResponseCodeInterceptor` (line 44):
     ```swift
     interceptors.append(MaxRetryInterceptor())              // keep — safety cap
     interceptors.append(CacheReadInterceptor(store: self.store))
     interceptors.append(NetworkPreConditionInterceptor(...))
     interceptors.append(AuthorizationInterceptor())
     if logRequests { interceptors.append(RequestLogInterceptor(log: log)) }
     interceptors.append(NetworkFetchInterceptor(client: self.client))
     if logRequests { interceptors.append(ResponseLogInterceptor(log: log)) }
     interceptors.append(BackoffRetryInterceptor())          // NEW — retries 5xx / 429 / 430 / transient
     interceptors.append(RateLimitMappingInterceptor())      // NEW — maps surviving 429/430 to .rateLimited
     interceptors.append(ResponseCodeInterceptor())
     // …unchanged from here
     ```
   - **Ordering rationale:** BackoffRetry gets first crack (can call `chain.retry` and reset the whole chain); RateLimitMapping handles the survivors (429s that exceed `retryAfterCap`); ResponseCode catches everything else (other 4xx/5xx → generic). MaxRetryInterceptor at position 1 is re-entered on each `chain.retry()` and caps total passes.

4. **Tests** (files: `AlfieKit/Tests/CoreTests/BFFService/BackoffRetryInterceptorTests.swift`, `RateLimitMappingInterceptorTests.swift` — **NEW**)
   - `BackoffRetryInterceptorTests`:
     - Retries on 500 → assert 3 retries → 4 total attempts.
     - Retries on `URLError(.networkConnectionLost)` → same.
     - **Does NOT retry mutations** — pass a fake `GraphQLMutation`, assert 0 retries.
     - Backoff sequence: with `baseDelay=0.5, multiplier=2, cap=8` the delays must be `[0.5, 1.0, 2.0]` (use an injectable clock).
     - `Retry-After: 5` honoured (delay overrides computed).
     - `Retry-After: 60` exceeds cap → no retry, error propagates.
     - Mid-backoff cancellation → no further retry.
   - `BackoffRetryInterceptorTests` additionally:
     - **APQ passthrough** — response with HTTP 200 + GraphQL error `extensions.code == "PersistedQueryNotFound"` → no retry (let APQ's own retry handle it).
   - `RateLimitMappingInterceptorTests`:
     - 429 with `Retry-After: 10` → maps to `.rateLimited(retryAfter: 10)`.
     - 430 with no header → maps to `.rateLimited(retryAfter: nil)`.
     - 200 → passes through untouched.
     - 503 → passes through untouched (handled by ResponseCodeInterceptor / backoff).
     - `Retry-After` IMF-fixdate (`Sun, 06 Nov 1994 08:49:37 GMT`) → parsed.
     - `Retry-After` RFC 850 (`Sunday, 06-Nov-94 08:49:37 GMT`) → parsed.
     - `Retry-After` asctime (`Sun Nov  6 08:49:37 1994`) → parsed.
     - `Retry-After` garbage → `nil` returned, error still mapped to `.rateLimited(retryAfter: nil)`.
   - **Pattern reference:** existing `BFFRequestErrorTests.swift` for test style (Swift Testing, `#expect`).
   - Mock Apollo `RequestChain` via a minimal fake — see if Apollo iOS test utils ship one; otherwise hand-roll a `MockRequestChain` that records `proceed` / `retry` / `handleError` calls.

### Verification

- Run `./Alfie/scripts/verify.sh`.
- Manually point the app at a staging endpoint that returns 503 thrice then 200 — confirm a single user-visible call succeeds after backoff.
- Manually point the app at a 429 endpoint — confirm rate-limit error surfaces immediately when `Retry-After > 30`.

### Estimated Effort

**M** — ~200 LoC across 2 new interceptors + ~250 LoC of tests. Tricky bit is the chain mock and getting backoff timing deterministic in tests (inject a clock / sleep abstraction).
