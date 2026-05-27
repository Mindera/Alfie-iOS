---
title: BFF error handling & observability
ticket: ALFMOB-334
status: completed
mode: auto
blockedBy: []
blocks: []
created: 2026-05-27
---

## Overview

Close the five concrete gaps in BFF error handling on top of the existing infra (`BFFRequestError`, `NetworkInterceptorProvider`, Alicerce → Crashlytics logger, Firebase Analytics):

1. Typed rate-limit error (HTTP 429/430) with `Retry-After`.
2. Custom exponential-backoff retry interceptor (replaces Apollo's default `MaxRetryInterceptor`).
3. Explicit request timeout on the Apollo transport → typed error.
4. Structured BFF error telemetry to Firebase / Crashlytics.
5. UI mapping for rate-limit and server-error states with retry affordance.

Existing pieces that already work (logging interceptors, `ViewState`, `ErrorView`, `FirebaseLogDestination`) are left intact and extended in place — no refactors.

## Acceptance Criteria

- HTTP **429** and **430** responses produce a distinct `BFFRequestError` case and a distinct UI state.
- Apollo BFF calls retry transient failures (network errors, 5xx, 429/430) with **exponential backoff**, honouring `Retry-After` when present.
- Apollo transport enforces a **request timeout**; timeouts surface as a typed `BFFRequestError` case.
- BFF errors reach **Firebase Analytics** and **Crashlytics** with structured context: operation name, HTTP status, GraphQL error codes, retry count.
- UI surfaces rate-limit and server-error states **distinctly** from generic errors with a retry affordance.
- `./Alfie/scripts/verify.sh` passes.

## Approach

Single plan, 4 phases, bottom-up (error model → interceptor → telemetry → UI). All work concentrated in `AlfieKit/Sources/Core/Services/BFFService/` plus a thin slice of UI mapping in each feature ViewModel. No feature flag — error handling is foundational and improves all paths; default-on with rollback via git revert.

**Locked decisions** (revisit only if Open Questions surface objections):

| Decision | Value | Rationale |
|---|---|---|
| Backoff base delay | `500 ms` | Comfortable for mobile, avoids hammering on transient blips |
| Backoff multiplier | `2.0` | Standard exponential |
| Max retries | `3` | Worst case ~3.5s of waits → still under 30s total budget |
| Per-attempt cap | `8 s` | Caps a single sleep to keep cancel-responsiveness |
| `Retry-After` cap | `30 s` | Beyond that, fail fast — surface UI rate-limit screen instead |
| Request timeout | `30 s` | `URLSessionConfiguration.timeoutIntervalForRequest` |
| Resource timeout | `60 s` | `timeoutIntervalForResource` |
| 430 handling | Same as 429 | Both are rate-limit signals (Cloudflare/Shopify variants) |
| 5xx retry policy | Retry 500, 502, 503, 504 only | Skip 501/505 — they are permanent |
| Retry UX | User-tap button (existing `ErrorView`) | Auto-retry already happens in the interceptor; UI is the final fallback |

## Phases

1. **Error model + timeout** — Extend `BFFRequestError`, configure Apollo `URLSessionConfiguration` timeouts, map `URLError.timedOut`.
2. **Backoff retry interceptor** — New `BackoffRetryInterceptor`, replace `MaxRetryInterceptor` in chain. Detect 429/430/5xx and `Retry-After`.
3. **Structured telemetry** — New `BFFErrorTelemetry` helper + `AnalyticsAction.bffError` + parameters. Wire from `resultAsFailure` and interceptor retry path.
4. **UI mapping + tests + L10n** — Add `rateLimited` / `serverError` to feature `*ViewErrorType` enums, update ViewModel switches, add L10n keys, snapshot + unit tests.

## File Changes (Summary Table)

| File | Module | Type | Change |
|---|---|---|---|
| `AlfieKit/Sources/Model/Services/BFFService/BFFRequestError.swift` | Model | Type | Add `.rateLimited(retryAfter:)`, `.timeout`, `.serverError(status:)` |
| `AlfieKit/Sources/Core/Services/BFFService/BFFClientService.swift` | Core | Service | Configure session timeouts; map `URLError.timedOut` in `resultAsFailure` |
| `AlfieKit/Sources/Core/Services/BFFService/NetworkInterceptorProvider.swift` | Core | DI | Keep `MaxRetryInterceptor` as safety cap (position 1); insert `BackoffRetryInterceptor` + `RateLimitMappingInterceptor` after `ResponseLogInterceptor` |
| `AlfieKit/Sources/Core/Services/BFFService/Interceptors/BackoffRetryInterceptor.swift` | Core | **NEW** | Exp backoff for network / 5xx / 429 / 430, honours `Retry-After` |
| `AlfieKit/Sources/Core/Services/BFFService/Interceptors/RateLimitMappingInterceptor.swift` | Core | **NEW** | After `ResponseCodeInterceptor`, maps 429/430 to `BFFRequestError.rateLimited` |
| `AlfieKit/Sources/Core/Services/BFFService/Telemetry/BFFErrorTelemetry.swift` | Core | **NEW** | Helper: emits Analytics event + Crashlytics non-fatal |
| `AlfieKit/Sources/Model/Services/Analytics/AnalyticsAction.swift` | Model | Enum | Add `bffError = "bff_error"` |
| `AlfieKit/Sources/Model/Services/Analytics/AnalyticsParameter.swift` | Model | Enum | Add `operationName`, `httpStatus`, `graphqlErrorCode`, `retryCount`, `errorCategory` |
| `AlfieKit/Sources/Core/Services/Analytics/AlfieAnalyticsTracker+Extensions.swift` | Core | Ext | Add `trackBFFError(...)` |
| `AlfieKit/Sources/Model/Models/ProductListing/ProductListingViewErrorType.swift` | Model | Enum | Add `rateLimited`, `serverError` |
| `AlfieKit/Sources/Model/Models/ProductDetails/ProductDetailsViewErrorType.swift` | Model | Enum | Add `rateLimited`, `serverError` |
| `AlfieKit/Sources/Model/Models/CategorySelector/Protocols/CategoriesViewModelProtocol.swift` | Model | Enum | Add `rateLimited`, `serverError` to `CategoriesViewErrorType` |
| `AlfieKit/Sources/Model/Models/CategorySelector/Protocols/BrandsViewModelProtocol.swift` | Model | Enum | Add `rateLimited`, `serverError` to `BrandsViewErrorType` |
| `AlfieKit/Sources/ProductListing/UI/ProductListingViewModel.swift` | Feature | VM | Map new BFF error cases (lines 147, 152, 177, 182) |
| `AlfieKit/Sources/ProductDetails/UI/ProductDetailsViewModel.swift` | Feature | VM | Map new BFF error cases (line 235) |
| `AlfieKit/Sources/CategorySelector/UI/CategoriesViewModel.swift` | Feature | VM | Map new BFF error cases |
| `AlfieKit/Sources/CategorySelector/UI/BrandsViewModel.swift` | Feature | VM | Map new BFF error cases |
| `AlfieKit/Sources/ProductListing/UI/ProductListingView.swift` | Feature | View | Switch ErrorView copy by error type (line 142) |
| `AlfieKit/Sources/ProductDetails/UI/ProductDetailsView.swift` | Feature | View | Switch ErrorView copy by error type (lines 220, 516) |
| `AlfieKit/Sources/CategorySelector/UI/CategoriesView.swift` | Feature | View | Switch ErrorView copy by error type |
| `AlfieKit/Sources/CategorySelector/UI/BrandsView.swift` | Feature | View | Switch ErrorView copy by error type |
| `AlfieKit/Sources/SharedUI/Resources/Localization/L10n.xcstrings` | Localization | Strings | Add 8 new keys (4 features × {title, message}) for rate-limit and server-error |
| `AlfieKit/Tests/CoreTests/HelperTests/BFFRequestErrorTests.swift` | Tests | Unit | New cases coverage |
| `AlfieKit/Tests/CoreTests/BFFService/BackoffRetryInterceptorTests.swift` | Tests | **NEW** | Backoff math, retry caps, `Retry-After` honoured |
| `AlfieKit/Tests/CoreTests/BFFService/RateLimitMappingInterceptorTests.swift` | Tests | **NEW** | 429/430 mapping |
| `AlfieKit/Tests/CoreTests/BFFService/BFFErrorTelemetryTests.swift` | Tests | **NEW** | Analytics + Crashlytics emitted with expected fields |
| `AlfieKit/Tests/ProductListingTests/ProductListingViewModelTests.swift` | Tests | Unit | Rate-limit + server-error state |
| `AlfieKit/Tests/ProductDetailsTests/ProductDetailsViewModelTests.swift` | Tests | Unit | Rate-limit + server-error state |
| `AlfieKit/Tests/CategorySelectorTests/CategoriesViewModelTests.swift` | Tests | Unit | Rate-limit + server-error state |
| `AlfieKit/Tests/CategorySelectorTests/BrandsViewModelTests.swift` | Tests | Unit | Rate-limit + server-error state |

## Feature Flag

- Name: **n/a**
- Rationale: error handling is foundational; default-off behind a flag would mean shipping a worse UX silently. Rollback is `git revert` if regression observed.

## Testing Strategy

- **Unit**
  - `BFFRequestError` — new cases equatable, `isNotFound` behaviour unchanged.
  - `BackoffRetryInterceptor` — retries on network err / 500 / 502 / 503 / 504 / 429 / 430; gives up after 3; backoff sequence asserts (500ms, 1000ms, 2000ms); `Retry-After: 5` honoured; `Retry-After: 60` exceeds cap → fails fast.
  - `RateLimitMappingInterceptor` — 429 + 430 + parses `Retry-After` integer & HTTP-date forms; passes through other statuses.
  - `BFFErrorTelemetry` — Analytics event fires with operation name, HTTP status, error category, retry count; Crashlytics non-fatal recorded.
  - ViewModel mapping — each feature ViewModel maps `.rateLimited` and `.serverError` to its own enum.
- **Snapshot** — Not added (ErrorView is parameterised over copy; existing snapshot tests cover the component).
- **XCUITest** — Not in scope (no new screens, only copy variants on existing `ErrorView`).
- **Manual** — Use the BFF mock server / a feature-branch staging endpoint that returns 429 and 503 to verify end-to-end retry + UI surfacing.

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| Custom backoff retry over-eagerly retries non-idempotent mutations | Medium | Restrict retry to `GraphQLQuery` operations only; never retry `GraphQLMutation` — assert in `BackoffRetryInterceptor` via `Operation.operationType` |
| `Retry-After` header parsing wrong format (seconds vs HTTP-date) | Medium | Support both forms; default to 0 on parse failure (interceptor falls back to its own backoff) |
| Crashlytics noise from low-severity 429s drowns real signal | Medium | Send 429/timeouts as Analytics events only (not Crashlytics non-fatals); only 5xx + unmapped errors become non-fatals |
| Adding new `BFFRequestError` cases breaks exhaustive `switch` in other ViewModels not listed | Low | Compile-time enforced — `verify.sh` catches; ViewModel scan in Phase 4 covers all known consumers |
| Backoff sleeps block actor / hold cancellation | Low | Use `Task.sleep(nanoseconds:)` inside Apollo's completion callback path; respect `chain` cancellation; verified by interceptor test that cancels mid-backoff |
| `URLSessionConfiguration` mutation after `URLSessionClient` init has no effect | Low | Set `timeoutIntervalForRequest` / `timeoutIntervalForResource` on the config **before** passing to `URLSessionClient` (Phase 1) |
| GraphQL-level rate-limit (status 200 + `extensions.code: RATE_LIMITED`) not detected | Medium | Phase 3: also check `result.errors[].extensions["code"]` in `resultAsFailure` and map to `.rateLimited(retryAfter: nil)` |
| State bleed if `NetworkInterceptorProvider.interceptors(for:)` ever caches the array | Low | Add code comment + assertion on `BackoffRetryInterceptor.init` capturing a fresh-instance contract. Apollo v1 contract is fresh-per-operation; safe today |
| Custom `BackoffRetryInterceptor` becomes throwaway on Apollo v2 migration | Medium | Decision recorded: defer v2 migration until epic ALFMOB-327 closes. ~50 LoC of timing logic will be reimplemented atop v2's `MaxRetryInterceptor(configuration:)`; surrounding decision logic (statuses, mutation guard, `Retry-After`, telemetry) survives |

## Out of Scope

- Apollo cache invalidation strategy (separate ticket if needed).
- Latency / performance metrics dashboards.
- Refactor of `AuthorizationInterceptor` (currently a placeholder — unrelated).
- Network-level offline queueing / replay.
- Updating `getHeaderNav`, `getProduct`, `getBrands`, `getSearchSuggestion` — these still throw `.generic` pending ALFMOB-332/333. New error mapping only takes effect once those queries land.

## Open Questions

0. **Apollo v2 migration** — Decided: defer to dedicated ticket after epic ALFMOB-327 closes. ALFMOB-334 ships on v1.19.0.

1. **Design copy** — rate-limit and server-error strings need design / copywriter sign-off. Suggested defaults:
   - Rate-limit title: "Too many requests" / message: "Please wait a moment and try again."
   - Server-error title: "Service unavailable" / message: "We're having trouble reaching our servers. Please try again."
2. **HTTP 430** — Confirm with BFF team whether it's actually used. If never emitted, we can drop it (but no harm leaving the mapping in).
3. **GraphQL-level rate-limit signalling** — Need a sample BFF response. Plan currently belt-and-suspenders both HTTP and `extensions.code: RATE_LIMITED`.
4. **Crashlytics non-fatal volume** — Confirm with PM/oncall whether 5xx should become non-fatals on each occurrence, or sampled.
5. **`bff_error` event in GA4** — Confirm event name acceptable to analytics owner (we register it via the existing `AnalyticsAction` enum, no Firebase console action needed).
