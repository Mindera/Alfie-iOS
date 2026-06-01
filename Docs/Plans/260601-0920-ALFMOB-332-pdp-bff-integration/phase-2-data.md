## Phase 2: Converter + service signature

### Goal
Map `OmniProduct` → domain `Product`, rebuilding typed colour/size from generic `optionValues[]`, with
a defined default-variant rule. Change `getProduct` from `id` → `handle`/`platform` across the stack.

### Steps

1. **Platform constant** (file: `Core/.../BFFPlatform.swift` — or a const on `BFFClientService`)
   - `enum BFFPlatform { static let ios = "ios" }`. ⚠️ confirm value at refinement.

2. **Converter** (file: `Core/Services/BFFService/Converters/ProductDetails+Converter.swift` — new)
   - Mirror `ProductListing+Converter.swift` style.
   - `extension BFFGraphAPI.ProductDetailsFragment { func convertToProduct() -> Product }`.
   - **Option name matching** (case-insensitive, private helpers):
     - colour option name ∈ {`color`, `colour`}; size option name ∈ {`size`}.
   - **Per-variant mapping** — for each `variant` in `fragment.variants`:
     - `colourValue = optionValues.first { name matches colour }?.value`
     - `sizeValue   = optionValues.first { name matches size }?.value`
     - `Product.Colour(id: colourValue, swatch: firstMedia→MediaImage, name: colourValue, media: variant.media→[Media])`
       (nil if no colour option).
     - `Product.ProductSize(id: sizeValue, value: sizeValue, scale: nil, description: nil, sizeGuide: nil)`
       (nil if no size option).
     - `stock = variant.inventory?.available ?? 0`.
     - `price = Price(amount: variant.price.toDomainMoney(), was: variant.compareAtPrice?.toDomainMoney())`.
     - `attributes` — map `variant.attributes` ([Metafield]) → `AttributeCollection` if the type supports
       key/value pairs; else nil. (Check `AttributeCollection` shape before wiring; nil is acceptable.)
   - **Default variant rule** (private func):
     ```
     variants.first { $0.id == defaultVariantId }
       ?? variants.first { $0.stock > 0 }
       ?? variants.first
     ```
     - If `variants` is empty, synthesise a single placeholder variant from product-level
       `priceRange.min` + `inventoryTotal` (mirror PLP converter's placeholder) so `Product.defaultVariant`
       (non-optional) is always satisfiable.
   - **Ordering** — selector content & order come from the `variants[]` array order exactly as the BFF
     returns it. We do **not** read `OmniProduct.options` or re-sort (no fixed S→M→L). The ViewModel's
     `buildVariantColors`/`buildVariantSizes` already walk `product.variants` in order and dedupe — so
     just populate `Product.variants` in fragment order and the selectors follow.
   - **Colours aggregation** — distinct colours preserving variant order (the ViewModel's
     `buildVariantColors` already dedupes, but populate `Product.colours` for parity with PLP).
   - **Dropped fields** — `styleNumber: ""`, `shortDescription: ""`, `longDescription: descriptionHtml`
     (HTML strip happens in Phase 3 at display, OR strip here — decide once; prefer stripping at the
     converter so the domain model holds plaintext). `brand: Brand(name: brandName ?? "", slug: "")`.

3. **Implement client** (file: `Core/Services/BFFService/BFFClientService.swift:58`)
   - Replace the stub with:
     ```swift
     public func getProduct(handle: String, platform: String) async throws -> Product {
         let product = try await executeFetch(
             BFFGraphAPI.ProductDetailsQuery(handle: handle, platform: platform)
         ).productDetails
         guard let product else { throw BFFRequestError(type: .product(.noProduct)) }
         return product.fragments.productDetailsFragment.convertToProduct()
     }
     ```
   - Reuse existing `executeFetch` (cancellation-safe) + error helpers — DRY. Mirror the 334
     `productListing` do/catch (`log.info` on the way in/out, `log.error` + rethrow on failure).
   - **Telemetry & retry are automatic**: `executeFetch` already calls `reportError(_:operationName:)`
     on `BFFRequestError` (BFFClientService line 159–160), and the interceptor chain retries transient
     failures. Do NOT add manual error reporting or retry here.

4. **Service** (file: `Core/Services/API/Product/ProductService.swift:13`)
   - `getProduct(handle:platform:)` delegating to client; keep the `isNotFound` → `.noProduct`,
     else `.generic` error mapping unchanged.

5. **Protocols + mocks** (signature change `id:` → `handle:platform:`):
   - `Model/Services/Product/ProductServiceProtocol.swift:4`
   - `Model/Services/BFFService/BFFClientServiceProtocol.swift:5`
   - `Mocks/Core/Services/MockProductService.swift:8` (update `onGetProductCalled` closure signature)
   - `Mocks/Core/Services/MockBFFClientService.swift:12`

### Verification
- `./Alfie/scripts/verify.sh` — build breaks at the ViewModel call site (fixed in Phase 3); run after
  Phase 3 for green. Converter unit tests added in Phase 4.
- Spot-check: no remaining references to old field names (`grep -rn "longDescription\|defaultVariant\b" Core` for the *data* path).

### Estimated Effort
L
