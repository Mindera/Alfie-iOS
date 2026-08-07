# Research: description block — brand line, `Black | Ref. 0273/393` meta line, description

All paths relative to repo root (`Alfie/AlfieKit/…` unless stated).

## Verdicts at a glance

| Figma field | Verdict | Source of truth today |
|---|---|---|
| Brand name (small line above product name) | **available** | `OmniProduct.brandName` → `Product.brand.name` → `viewModel.productTitle` |
| Colour name (`Black`) | **available** | variant `optionValues` (name == color/colour) → `Product.Variant.colour?.name` |
| Reference (`Ref. 0273/393`) | **available as the variant SKU** (`ProductVariant.sku`); a distinct "style number / reference" field is **absent** from the schema |
| Description text | **available, already plain text** (HTML stripped in the converter) |

No new BFF work and no query change is required for any of the four. Everything the meta line needs is
already selected by `ProductDetailsFragment` and already reaches the domain model; the only gap is that
the **view model exposes no property for colour name or SKU** — those are on
`ProductDetailsViewStateModel.selectedVariant`, so surfacing them is a ~2-line VM addition, not backend work.

---

## 1. Brand name — **available**

- Schema: `Sources/BFFGraph/CodeGen/Schema/schema.graphqls:129` — `brandName: String` on `type OmniProduct`.
- Selected in the query: `Sources/BFFGraph/CodeGen/Queries/Products/Details/Fragments/ProductDetailsFragment.graphql:5`.
- Generated accessor: `Sources/BFFGraph/API/Fragments/ProductDetailsFragment.graphql.swift:33`
  (`public var brandName: String?`; selection declared at `:21`).
- Converter: `Sources/Core/Services/BFFService/Converters/ProductDetails+Converter.swift:40` —
  `brand: Brand(name: brandName ?? "", slug: "")`. Nullable on the wire, coalesced to `""`.
- App model: `Sources/Model/Models/Product/Product.swift:11` (`public let brand: Brand`).
- Already exposed by the view model: `Sources/ProductDetails/UI/ProductDetailsViewModel.swift:47`
  — `public var productTitle: String { product?.brand.name ?? "" }`
  (protocol: `Sources/Model/Models/ProductDetails/Protocols/ProductDetailsViewModelProtocol.swift:7`).

**Note on the current UI:** `productTitle` (= the brand) is *not* rendered in the body today — it is
passed only to the toolbar at `Sources/ProductDetails/UI/ProductDetailsView.swift:74`
(`.toolbarView(productTitle:…)`). The in-body `titleHeader`
(`ProductDetailsView.swift:348-358`) renders `viewModel.productName` and, confusingly, tags it with
`AccessibilityID.ProductDetails.productTitle` (`:355`). So the Figma's brand line is a **new Text in the
body bound to an existing VM property**, and the spec should call out the accessibility-ID naming
collision (`productTitle` already means "product name" in the UI tests).

## 2. Meta line `Black | Ref. 0273/393`

### 2a. Colour name (`Black`) — **available**

- Schema: `schema.graphqls:201` — `optionValues: [VariantOption!]!` on `ProductVariant`;
  `VariantOption { name, value }` at `schema.graphqls:227-229`.
- Selected: `ProductDetailsFragment.graphql:33-36`.
- Generated: `ProductDetailsFragment.graphql.swift:149` (`optionValues`), `:230-231` (`name`, `value`).
- Converter: `ProductDetails+Converter.swift:122-128` — the option whose name matches `color`/`colour`
  (case-insensitive, `:177-179`) becomes `Product.Colour(id: value, name: value, …)`.
- App model: `Product.swift:104` (`Product.Colour.name`), reached via
  `Product.Variant.colour` (`Product.swift:68`).
- Reachable from the PDP state as `state.selectedVariant.colour?.name`
  (`Sources/Model/Models/ProductDetails/ProductDetailsViewStateModel.swift:5`).
- **Not exposed on the view model.** The nearest thing is the colour selector header, which builds
  `selectedTitle: L10n.Product.Color.title + ":"` plus the selected swatch
  (`ProductDetailsViewModel.swift:288-292`). A new `selectedColourName` computed property would be needed.
- Caveat: for single-option ("Title") products with no colour dimension the converter still creates a
  **nameless** colour to carry media (`ProductDetails+Converter.swift:129-131`, `name: ""`), and the
  no-variants fallback also uses `name: ""` (`:76`). The meta line must tolerate an empty colour name
  (drop the segment and the separator).

### 2b. Reference (`Ref. 0273/393`) — **available only as `sku`; a dedicated reference field is absent**

- `ProductVariant.sku: String!` — schema `schema.graphqls:206`; selected at
  `ProductDetailsFragment.graphql:23`; generated at `ProductDetailsFragment.graphql.swift:145`;
  converted at `ProductDetails+Converter.swift:155` into `Product.Variant.sku` (`Product.swift:64`).
  Non-null on the wire (empty only in the synthetic no-variants fallback,
  `ProductDetails+Converter.swift:83`).
- `Product.styleNumber` (`Product.swift:7`) — the field whose doc-comment matches the idea of a
  product reference — is **hardcoded to `""`** by the PDP converter
  (`ProductDetails+Converter.swift:38`) and by the PLP converter
  (`Sources/Core/Services/BFFService/Converters/ProductListing+Converter.swift:69`) and the persistence
  DTO (`Sources/Core/Services/Persistence/PersistedProductDTO.swift:110`). It is never rendered on the PDP.
- Nothing named `reference`, `styleNumber`, `productCode` or similar exists on `OmniProduct`
  (`schema.graphqls:128-152`) or `ProductVariant` (`:191-210`). The only escape hatch is the untyped
  key/value metafields — `OmniProduct.extensions: [Metafield]` (`:134`),
  `ProductVariant.attributes: [Metafield]` (`:192`), `Metafield { key, value }` (`:97-100`), fetched via
  the unused `productDetails(productMetafields:variantMetafields:)` arguments (`:216`; the app's query
  passes only `handle`, `ProductDetailsQuery.graphql:1-7`). Using those would require knowing the
  namespace/key contract — i.e. backend/content coordination, not a restyle.

**Recommendation:** render the reference from `selectedVariant.sku`. The Figma's `0273/393` looks like a
slash-formatted style/colour code, and the real BFF SKU format is whatever Shopify returns — the spec
should treat `Ref. <sku>` as the shape and accept that the value won't literally look like the mock. If
the design demands the exact `0273/393` format, that is a backend field → out of scope.

## 3. Description — **available, and already a plain string**

- Schema: `schema.graphqls:133` — `descriptionHtml: String` on `OmniProduct`.
- Selected: `ProductDetailsFragment.graphql:6`; generated at `ProductDetailsFragment.graphql.swift:34`
  (selection at `:22`).
- Converter strips the HTML before it reaches the domain:
  `ProductDetails+Converter.swift:42` — `longDescription: descriptionHtml?.strippingHTML()`.
  `strippingHTML()` lives at `Sources/Utils/Extensions/String+Extension.swift:29-48`: it converts block
  boundaries to spaces, removes tags, decodes `&nbsp; &lt; &gt; &quot; &#39; &amp;`, collapses whitespace.
  Result is a **single-paragraph plain string with no newlines** — exactly what the Figma renders.
- App model: `Product.longDescription` (`Product.swift:17`, optional).
  (`Product.shortDescription`, `Product.swift:15`, is hardcoded `""` by the converter, `:41` — unusable.)
- View model: `ProductDetailsViewModel.swift:54` — `public var productDescription: String`.
- Rendered today inside a single-tab `TabControl`, `ProductDetailsView.swift:477-492`. The Figma drops
  the `TabControl` and keeps the `Text` — so this is pure view surgery, no data change.
- Side effect worth noting in the spec: because block tags become spaces, multi-paragraph BFF copy
  arrives as one run-on paragraph (tested at
  `Tests/BFFGraphTests/ProductDetailsConverterTests.swift:167`). If the design wants paragraph breaks,
  that's a converter change, separate from the restyle.

---

## Mocks / previews — will these fields have values?

- **Apollo GraphQL mocks** (`Sources/BFFGraph/Mocks/`) expose all three fields, so converter tests can set
  them: `OmniProduct+Mock.graphql.swift:13` (`brandName`), `:15` (`descriptionHtml`),
  `ProductVariant+Mock.graphql.swift:19` (`sku`). Existing tests already populate them —
  `Tests/BFFGraphTests/ProductDetailsConverterTests.swift:146-147, 264-265`.
- **Domain fixtures default to empty**, which is the trap for previews and any future snapshot test:
  - `Sources/Mocks/Fixtures/Product/Brand+Fixture.swift:24` — `name: String = ""` (a populated
    `Brand.fixtures` array exists at `:5-21`, but `Product.fixture()` does not use it).
  - `Sources/Mocks/Fixtures/Product/Product+Fixture.swift:8` — `brand: Brand = .fixture()` (empty name);
    `:51` — `Product.Colour.fixture(name: String = "")`;
    `:33` — `Product.Variant.fixture(sku: String = UUID().uuidString)` (a random UUID, not a plausible ref);
    `:35` — `colour: Product.Colour? = nil`, so `selectedVariant.colour` is **nil** by default.
- **`MockProductDetailsViewModel`** (`Sources/Mocks/Core/Features/MockProductDetailsViewModel.swift`)
  has `productTitle` (`:9`, default `""`), `productName` (`:14`), `productDescription` (`:19`) — but
  **no** colour-name or SKU property, so any new VM property for the meta line must be added there too
  (`:9-23` for the stored props, `:25-47` for the init).
- **The existing PDP previews** (`ProductDetailsView.swift:594-614`) set `productName` and
  `productDescription` but **not** `productTitle`, and use `.fixture()` / `.fixture()` for the state — so
  as things stand the brand line would render empty and the meta line would show a UUID SKU with no
  colour. Previews (and any snapshot test) will need explicit values:
  `productTitle: "Brand Name"` plus a state built with
  `Product.Variant.fixture(sku: "0273/393", colour: .fixture(name: "Black"))`.

## Cost summary for the spec

| Work item | Cost |
|---|---|
| Brand line in body | bind existing `viewModel.productTitle`; new `AccessibilityID` (name carefully — `productTitle` is taken by the product *name*) |
| Colour name + SKU meta line | ~2 computed properties on `ProductDetailsViewModel` + 2 stored props on `MockProductDetailsViewModel`; new L10n string for the `Ref.` prefix and the `|` separator; no GraphQL change |
| Description | delete `TabControl`, keep the `Text`; no data change |
| Exact `0273/393` reference format | **out of scope** — no such field in the schema; SKU is the only stand-in |
