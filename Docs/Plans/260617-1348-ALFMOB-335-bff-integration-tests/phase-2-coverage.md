## Phase 2: Coverage — the three operations

### Goal
Exercise `productList`, `getProduct`, and `searchProducts` end-to-end through the real service,
asserting structural invariants anchored on stable seed handles (not exact values).

> Red-team fixes applied: stable seed anchor, `slug` chaining, non-pinned error type, skip-not-fail
> on empty/no-next-page, fresh SUT per test (inherited from Phase 1 `setUp`).

### Steps
1. **Product List** (file: `Alfie/AlfieKit/Tests/BFFIntegrationTests/ProductListIntegrationTests.swift` — new; `: IntegrationTestCase`)
   - `productList(collectionHandle:after:limit:sort:filters:) async throws -> ProductListing`
     ([BFFClientServiceProtocol.swift:6](../../../Alfie/AlfieKit/Sources/Model/Services/BFFService/BFFClientServiceProtocol.swift)).
   - **Seed anchor:** use a collection handle the code already trusts — `getHeaderNav` hardcodes real
     Shopify handles `women` / `men` / `frontpage` / `womens-tops` ([BFFClientService.swift:65](../../../Alfie/AlfieKit/Sources/Core/Services/BFFService/BFFClientService.swift)). Centralize the chosen handle in one constant.
   - `test_productList_happyPath_returnsProducts` — `XCTSkipUnless(!products.isEmpty)`; each product has id/name/price well-formed.
   - `test_productList_pagination_secondPageDiffers` — page 1 (small `limit`, `after: nil`); **skip** if
     `pagination.hasNextPage == false`; else fetch page 2 with the cursor → assert non-overlapping ids / cursor advanced.
   - `test_productList_sort_returnsWellFormedPage` — valid `sort`; assert a well-formed page (monotonic order only if a deterministic key like price is asserted).
   - `test_productList_filter_appliesFilter` — a `ProductFilterInput`; assert results respect it (or empty-but-valid).
2. **Product Details** (file: `Alfie/AlfieKit/Tests/BFFIntegrationTests/ProductDetailsIntegrationTests.swift` — new)
   - `getProduct(handle:) async throws -> Product` (NOT `productDetails`; resolves by **slug**).
   - `test_getProduct_happyPath_returnsProduct` — chain: `productList` → take `product.slug` →
     `getProduct(handle: product.slug)` (field is `slug`, [Product.swift:19](../../../Alfie/AlfieKit/Sources/Model/Models/Product/Product.swift); slug-resolution per commit f47b847). `XCTSkipUnless` list non-empty. Assert id/name/brand present.
   - `test_getProduct_variantsSurface` — assert `!variants.isEmpty` and `defaultVariant` present.
     Do NOT require colour+size on every variant (`colours: [Colour]?` is optional, [Product.swift:28](../../../Alfie/AlfieKit/Sources/Model/Models/Product/Product.swift)).
   - `test_getProduct_unknownHandle_throws` — bogus slug → assert only `error is BFFRequestError`
     ([BFFRequestError.swift:3](../../../Alfie/AlfieKit/Sources/Model/Services/BFFService/BFFRequestError.swift)); do NOT pin the sub-type (null vs GraphQL-errors vs HTTP paths diverge). Optional — client null-handling is already unit-tested with mocks; keep only if cheap.
3. **Search** (file: `Alfie/AlfieKit/Tests/BFFIntegrationTests/SearchIntegrationTests.swift` — new)
   - `searchProducts(searchTerm:after:limit:sort:filters:) async throws -> ProductListing`.
   - `test_searchProducts_happyPath_returnsResults` — common term; `XCTSkipUnless` non-empty; well-formed `ProductListing`.
   - `test_searchProducts_pagination` — same cursor-advance assertion as productList (skip if no next page).

### Notes
- SUT + skip guard come from `IntegrationTestCase` (Phase 1); each test gets a **fresh** SUT (fresh
  Apollo cache) — do NOT cache a shared instance.
- Prefer chaining (list → slug → details) over hardcoded handles; centralize any unavoidable constants.
- Keep per-call timeouts under the service's 30s request budget.

### Verification
- `./Alfie/scripts/verify.sh` still PASS (unit run unaffected).
- With BFF up: all `BFFIntegrationTests` pass via `-testPlan AlfieIntegration` (Phase 1 command). With BFF down: all skip.

### Estimated Effort
L
