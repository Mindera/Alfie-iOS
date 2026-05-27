## Phase 4: UI mapping + L10n + integration tests

### Goal

Surface `rateLimited` and `serverError` as distinct UI states across all feature ViewModels that currently consume `BFFRequestError`, with appropriate copy and a retry affordance.

### Steps

1. **Extend feature error-type enums**
   - File: `AlfieKit/Sources/Model/Models/ProductListing/ProductListingViewErrorType.swift:3`
   - File: `AlfieKit/Sources/Model/Models/ProductDetails/ProductDetailsViewErrorType.swift:3`
   - File: `AlfieKit/Sources/Model/Models/CategorySelector/Protocols/CategoriesViewModelProtocol.swift` (CategoriesViewErrorType)
   - File: `AlfieKit/Sources/Model/Models/CategorySelector/Protocols/BrandsViewModelProtocol.swift` (BrandsViewErrorType)
   - In each, add:
     ```swift
     case rateLimited
     case serverError
     ```
   - **Why:** keeps feature-level enums in step with shared BFF error vocabulary; the ViewModel is the boundary that translates `BFFRequestError` → feature `ErrorType`.

2. **Map BFF → feature error in ViewModels**
   - File: `AlfieKit/Sources/ProductListing/UI/ProductListingViewModel.swift` (catch sites near lines 147, 152, 177, 182)
   - File: `AlfieKit/Sources/ProductDetails/UI/ProductDetailsViewModel.swift` (around line 235 — the existing `isNotFound` switch)
   - File: `AlfieKit/Sources/CategorySelector/UI/CategoriesViewModel.swift` (lines 139, 199, 204)
   - File: `AlfieKit/Sources/CategorySelector/UI/BrandsViewModel.swift`
   - Pattern (apply to each):
     ```swift
     switch (error as? BFFRequestError)?.type {
     case .rateLimited: state = .error(.rateLimited)
     case .serverError: state = .error(.serverError)
     case .noInternet:  state = .error(.noInternet)
     case .timeout:     state = .error(.generic)   // Timeout treated as generic for v1; revisit if design wants distinct copy
     case .some(let bff) where (error as? BFFRequestError)?.isNotFound == true:
                        state = .error(.noResults)  // or .notFound, per existing enum
     default:           state = .error(.generic)
     }
     ```
   - Each feature already has its own enum vocabulary (`noResults` for lists, `notFound` for PDP). Preserve.
   - **Note:** `WebViewModel` is excluded — it has no BFF dependency; web errors are loader-side. Confirm during implementation.

3. **Update Views to vary ErrorView copy by error type**
   - File: `AlfieKit/Sources/ProductListing/UI/ProductListingView.swift:142`
   - File: `AlfieKit/Sources/ProductDetails/UI/ProductDetailsView.swift:220, 516`
   - File: `AlfieKit/Sources/CategorySelector/UI/CategoriesView.swift:66`
   - File: `AlfieKit/Sources/CategorySelector/UI/BrandsView.swift:161`
   - Switch on the feature error type when constructing the `ErrorView` title/message:
     ```swift
     let (title, message): (String, String) = {
         switch errorType {
         case .rateLimited: return (L10n.Plp.ErrorView.RateLimited.title, L10n.Plp.ErrorView.RateLimited.message)
         case .serverError: return (L10n.Plp.ErrorView.ServerError.title, L10n.Plp.ErrorView.ServerError.message)
         default:           return (L10n.Plp.ErrorView.title, L10n.Plp.ErrorView.message)
         }
     }()
     ```
   - Retry button: existing `ErrorView` already supports a CTA; reuse the per-feature retry handler that's already wired for the generic case.

4. **Add L10n strings** (file: `AlfieKit/Sources/SharedUI/Resources/Localization/L10n.xcstrings`)
   - New keys (English defaults — placeholder pending design):
     | Key | EN |
     |---|---|
     | `plp.error_view.rate_limited.title` | Too many requests |
     | `plp.error_view.rate_limited.message` | Please wait a moment and try again. |
     | `plp.error_view.server_error.title` | Service unavailable |
     | `plp.error_view.server_error.message` | We're having trouble reaching our servers. Please try again. |
     | `pdp.error_view.rate_limited.title` | Too many requests |
     | `pdp.error_view.rate_limited.message` | Please wait a moment and try again. |
     | `pdp.error_view.server_error.title` | Service unavailable |
     | `pdp.error_view.server_error.message` | We're having trouble reaching our servers. Please try again. |
     | `shop.categories.error_view.rate_limited.title` | Too many requests |
     | `shop.categories.error_view.rate_limited.message` | Please wait a moment and try again. |
     | `shop.categories.error_view.server_error.title` | Service unavailable |
     | `shop.categories.error_view.server_error.message` | We're having trouble reaching our servers. Please try again. |
     | `shop.brands.error_view.rate_limited.title` | Too many requests |
     | `shop.brands.error_view.rate_limited.message` | Please wait a moment and try again. |
     | `shop.brands.error_view.server_error.title` | Service unavailable |
     | `shop.brands.error_view.server_error.message` | We're having trouble reaching our servers. Please try again. |
   - **Process:** follow `Docs/Localization.md` — add via Xcode String Catalog editor; codegen (`L10n+Generated.swift`) regenerates automatically.
   - **Flag for design / copywriter review** — these are placeholder strings.

5. **ViewModel tests** (existing files)
   - `AlfieKit/Tests/ProductListingTests/ProductListingViewModelTests.swift:231` — add cases for `.rateLimited`, `.serverError`.
   - `AlfieKit/Tests/ProductDetailsTests/ProductDetailsViewModelTests.swift`.
   - `AlfieKit/Tests/CategorySelectorTests/CategoriesViewModelTests.swift`.
   - `AlfieKit/Tests/CategorySelectorTests/BrandsViewModelTests.swift`.
   - Pattern: stub the use-case / service to `throw BFFRequestError(type: .rateLimited(retryAfter: nil))` and assert the resulting `ViewState.error(.rateLimited)`.

6. **End-to-end manual verification**
   - Point the app at a controllable staging endpoint (or local mock) that returns 429, 500, and timeout — confirm:
     - 429 → "Too many requests" copy; retry button works.
     - 500 → "Service unavailable" copy; retry button works after ~3.5s of internal retries.
     - Timeout (slow endpoint) → generic error (v1 behaviour; revisit per Open Question).
     - 200 after transient 503 (mock script) → succeeds silently (no error UI).

### Verification

- Run `./Alfie/scripts/verify.sh`.
- Inspect `L10n+Generated.swift` regenerated and includes new accessors.
- Manual checks above.

### Estimated Effort

**M** — ~120 LoC of ViewModel/View edits across 4 features + ~80 LoC of L10n + ~150 LoC of test additions.
