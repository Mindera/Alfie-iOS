## Phase 3: PDP wiring (handle threading + ViewModel)

### Goal
Thread `handle` (slug) + `platform` through PDP entry points and the ViewModel call site; rename
`productId` → `productHandle`; restore a green build.

### Steps

1. **Configuration** (file: `ProductDetails/Models/ProductDetailsConfiguration.swift`)
   - The `.product(Product)` / `.selectedProduct(SelectedProduct)` cases already carry `slug` (use it).
   - The `.id(String)` case has only an id. Decide per Open Q #1:
     - **If handle == slug and deep links expose slug:** rename `.id` → `.handle(String)`.
     - **Interim (handle source unconfirmed):** keep `.id` but route it to a typed `.notFound`/`.generic`
       in the ViewModel rather than firing a guaranteed-to-fail request. Document the TODO.

2. **ViewModel** (file: `ProductDetails/UI/ProductDetailsViewModel.swift`)
   - Rename `public let productId: String` → `productHandle` (line 25). Derive from configuration:
     `.product`/`.selectedProduct` → `product.slug`.
   - `loadProductIfNeeded()` — change **only line 234**:
     `getProduct(id: productId)` → `getProduct(handle: productHandle, platform: BFFPlatform.ios)`.
   - **Do NOT touch the catch block (lines 235–238)** — it already maps any error via
     `ProductDetailsViewErrorType.from(error:)` (added on 334). Update the `log.error` interpolation
     `productId` → `productHandle` only.
   - Default-variant selection on load (line 241): keep
     `initialSelectedProduct?.selectedVariant ?? product.defaultVariant` — `defaultVariant` now comes
     from the converter's rule (Phase 2), so this line is unchanged but now correct.
   - **HTML strip** — prefer stripping in the converter (Phase 2) so the model holds plaintext; if done
     in the getter instead, strip in `productDescription` (line 51). Pick one, not both.

3. **HTML strip util** (file: `Utils/.../HTMLString.swift` — new, only if not converter-side)
   - Minimal `String.strippingHTML()` (NSAttributedString or regex tag-strip). Keep it small — KISS.

4. **List tap entry** (file: `ProductListing/Navigation/ProductListingFlowViewModel.swift:100`)
   - Already passes the full `Product` (`.product(product)`), which now carries `slug` → no change
     needed beyond confirming `slug` is populated by the PLP converter (it is, line 58 of
     `ProductListing+Converter`).

5. **Deep link** (files: `AppFeature/Navigation/AppFeatureViewModel.swift:228`,
   `DeepLink/Parsers/ProductDetailsDeepLinkParser.swift:55`)
   - Per Open Q #1. If slug is available in the URL, parse it and build `.handle(slug)`. If only the
     8-digit id is available, leave the parser as-is and let the request surface a typed error — a bad
     handle returns null `productDetails` → `.product(.noProduct)` → `.notFound`, which the **existing
     334 error UI already renders**. Add a TODO referencing Open Q #1. **Do not** invent a fallback that
     masks the problem.

### Verification
- `./Alfie/scripts/verify.sh` → **must be green** (this phase closes the build break from Phase 2).
- Manual (simulator, if a real BFF env is reachable): open a PDP from PLP tap → product loads, colour
  auto-selected, size requires tap, price/stock reflect selection.

### Estimated Effort
M
