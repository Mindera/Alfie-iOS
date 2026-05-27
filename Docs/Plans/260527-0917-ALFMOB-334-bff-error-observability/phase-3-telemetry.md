## Phase 3: Structured BFF error telemetry

### Goal

Emit structured Analytics + Crashlytics signal whenever a BFF call fails, with enough context (operation name, HTTP status, GraphQL error code, retry count, error category) to build dashboards.

### Steps

1. **Extend analytics types**
   - File: `AlfieKit/Sources/Model/Services/Analytics/AnalyticsAction.swift:1` — add `case bffError = "bff_error"`.
   - File: `AlfieKit/Sources/Model/Services/Analytics/AnalyticsParameter.swift:3` — add:
     ```swift
     case operationName = "operation_name"
     case httpStatus = "http_status"
     case graphqlErrorCode = "graphql_error_code"
     case retryCount = "retry_count"
     case errorCategory = "error_category"  // "rate_limited" | "timeout" | "server_error" | "network" | "graphql" | "generic"
     ```

2. **Create `BFFErrorTelemetry`** (file: `AlfieKit/Sources/Core/Services/BFFService/Telemetry/BFFErrorTelemetry.swift` — **NEW**)
   - Protocol + default impl:
     ```swift
     protocol BFFErrorTelemetryProtocol {
         func record(error: BFFRequestError, operationName: String, httpStatus: Int?, retryCount: Int, graphqlErrorCode: String?)
     }
     ```
   - Default impl takes `analytics: AnalyticsTrackerProtocol` + `log: Logger`.
   - `record(...)`:
     - Compute `errorCategory` from `error.type` (mapping table — see below).
     - Emit Analytics event via existing tracker (`AnalyticsAction.bffError` + params).
     - For categories `serverError` and `generic` only: also `log.error("[BFF] …")` so `FirebaseLogDestination` records a Crashlytics non-fatal (Crashlytics already gets log messages via the existing destination — no extra plumbing needed).
     - For `rateLimited` / `timeout` / `network`: Analytics-only (avoid Crashlytics noise — these are expected operational signals).

   | `BFFRequestErrorType` | `errorCategory` |
   |---|---|
   | `.rateLimited` | `"rate_limited"` |
   | `.timeout` | `"timeout"` |
   | `.serverError` | `"server_error"` |
   | `.noInternet` | `"network"` |
   | `.product` | `"graphql"` |
   | `.emptyResponse` | `"graphql"` |
   | `.generic` | `"generic"` |

3. **Add tracker extension** (file: `AlfieKit/Sources/Core/Services/Analytics/AlfieAnalyticsTracker+Extensions.swift:7`)
   - Add `func trackBFFError(operation: String, httpStatus: Int?, retryCount: Int, category: String, graphqlErrorCode: String?)` — wraps the `logEvent` call.

4. **Wire telemetry into BFFClientService** (file: `AlfieKit/Sources/Core/Services/BFFService/BFFClientService.swift`)
   - Add `private let telemetry: BFFErrorTelemetryProtocol` (inject via `BFFClientDependencyContainer`).
   - Modify `executeFetch` (line 127) to:
     - Capture operation name: `Query.operationName` (Apollo-generated static).
     - On thrown error path (catch block at line 99-102 of `productListing` and in `executeFetch`'s continuation failures), call `telemetry.record(...)`.
   - Detect GraphQL error code: in `resultAsFailure` (line 155), when `result.errors` is non-empty, read `errors.first?.extensions?["code"] as? String` and pass into telemetry.
   - Detect GraphQL-level rate-limit: if extension code is `"RATE_LIMITED"` (or `"THROTTLED"`), upgrade the error from `.generic` to `.rateLimited(retryAfter: nil)`.

5. **Wire retry count from interceptor → telemetry**
   - `BackoffRetryInterceptor` doesn't have a clean way to ship `retryCount` to the service layer. Two options:
     - **A (chosen):** stash final `retryCount` in the request context (`HTTPRequest.additionalHeaders` is for headers; instead use Apollo's `cachePolicy` is wrong — use `Operation.Variables` is wrong). Apollo iOS lacks a per-request context bag. **Workaround:** add a custom header `X-Retry-Count: N` on retry; `BFFClientService` reads it from the final `HTTPResponse` via a `LastResponseCapture` interceptor that exposes the value. Too much plumbing for marginal value.
     - **B (chosen — simpler):** pass retry count via the error itself. Extend `BFFRequestError`:
       ```swift
       public init(type: BFFRequestErrorType, error: Error? = nil, message: String? = nil, retryCount: Int = 0)
       public let retryCount: Int
       ```
       and have `BackoffRetryInterceptor` wrap the final error with `retryCount` set before letting it propagate.
   - Going with **B**. Update Phase 1 file if not already extended (add `retryCount` field). The interceptor only needs to mutate the error in its terminal "give up" branch.

6. **Register dependency**
   - File: `Alfie/Alfie/Service/ServiceProvider.swift:44` (analytics tracker is here).
   - Inject the existing `analytics` tracker into a new `BFFErrorTelemetry` instance, and pass it to `BFFClientService` via `BFFClientDependencyContainer`. Locate `BFFClientDependencyContainer` definition (likely `AlfieKit/Sources/Core/Services/BFFService/BFFClientDependencyContainer.swift`) and add `var bffErrorTelemetry: BFFErrorTelemetryProtocol`.

7. **Tests** (file: `AlfieKit/Tests/CoreTests/BFFService/BFFErrorTelemetryTests.swift` — **NEW**)
   - Use a `MockAnalyticsTracker` + `MockLogger` (likely already in `AlfieKit/Sources/Core/.../Mocks/` — scout before creating).
   - For each `BFFRequestErrorType` case, assert:
     - Analytics event emitted with expected `errorCategory`.
     - `log.error` invoked **only** for `serverError` / `generic`.
     - All parameter keys populated when inputs provided; `nil` inputs absent (not empty-string) in the emitted dict.
   - Assert `RATE_LIMITED` extension code upgrades a `.generic` error to `.rateLimited` (test sits in `BFFClientServiceTests` if it exists, else new `BFFClientServiceErrorMappingTests`).

### Verification

- Run `./Alfie/scripts/verify.sh`.
- Manual: trigger a 429 against staging, check Firebase DebugView shows `bff_error` event with the right params.
- Manual: trigger a 500, check Crashlytics dashboard within ~10 min for a non-fatal with the operation name in the log breadcrumbs.

### Estimated Effort

**M** — ~150 LoC across analytics/telemetry/service wiring + ~120 LoC tests. Risk is locating the right mock-tracker plumbing in existing test infra; if absent, light hand-rolled mocks.
