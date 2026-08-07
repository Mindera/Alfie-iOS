# Is the description block's brand line and "Black | Ref. 0273/393" meta line available today?

Type: research
Status: resolved
Blocked by: —

## Question

The Figma's info block shows fields the current PDP may not render. Establish, against the code, whether each is available from the BFF today:

1. **Brand name** as a separate small line above the product name (`Brand Name` in the design).
2. The meta line under the description: **`Black | Ref. 0273/393`** — i.e. selected colour name, a separator, and some product reference/SKU.
3. Whether the description is a plain string or rich/HTML content (the Figma renders it as one plain paragraph, replacing today's `TabControl` Description tab).

For each: name the exact field on `ProductDetailsFragment` (`Sources/BFFGraph/API/Fragments/ProductDetailsFragment.graphql.swift`) and the corresponding property on the app model (`Sources/Model/Models/ProductDetails/ProductDetailsViewStateModel.swift`), or state clearly that it does not exist. If a field exists on the GraphQL **schema** (`Sources/BFFGraph/CodeGen/Schema/schema.graphqls`) but is not selected in the query (`Sources/BFFGraph/CodeGen/Queries/Products/Queries.graphql`), say so — adding a field to an existing query is cheap; adding it to the schema is backend work and would push the meta line out of scope.

Also check `MockProductDetailsViewModel` and the BFF mocks, so the spec can say whether previews and any future snapshot tests will actually have values for these fields.

Deliverable: a short findings file under `.scratch/pdp-modern-design/research/` with a field-by-field verdict: **available / in schema but unselected / absent**.

## Answer

Findings: `.scratch/pdp-modern-design/research/06-description-meta-data.md`

**Nothing here needs BFF work, and no field needs adding to the query.** All three fields are already
selected by `ProductDetailsFragment` and already reach the domain model. The only gap is view-model
plumbing for the meta line.

1. **Brand name — available.** `OmniProduct.brandName` (`schema.graphqls:129`) is selected
   (`ProductDetailsFragment.graphql:5`, generated `:33`), converted to `Product.brand.name`
   (`ProductDetails+Converter.swift:40`) and already exposed as
   `ProductDetailsViewModel.productTitle` (`:47`). Today it is only fed to the toolbar
   (`ProductDetailsView.swift:74`); the in-body `titleHeader` (`:348-358`) renders `productName` while
   carrying `AccessibilityID.ProductDetails.productTitle` (`:355`) — flag that naming collision when
   adding the brand line's own ID.

2. **Meta line — colour available, reference available only as the SKU.**
   - Colour `Black`: from variant `optionValues` (`schema.graphqls:201`, selected
     `ProductDetailsFragment.graphql:33-36`) → `Product.Variant.colour?.name`
     (`ProductDetails+Converter.swift:122-128`, `Product.swift:104`). Reachable as
     `state.selectedVariant.colour?.name`; **no VM property exists yet**. Must tolerate an empty name —
     the converter creates nameless colours for single-option products (`:129-131`) and the no-variant
     fallback (`:76`).
   - `Ref. 0273/393`: use `ProductVariant.sku` (`schema.graphqls:206`, selected
     `ProductDetailsFragment.graphql:23`, → `Product.Variant.sku`). `Product.styleNumber` is
     **hardcoded `""`** by the converter (`ProductDetails+Converter.swift:38`) and never rendered.
     **A dedicated reference/style-number field is absent from the schema** — `OmniProduct`
     (`:128-152`) and `ProductVariant` (`:191-210`) have none; the only escape hatch is untyped
     metafields (`extensions`/`attributes`, `Metafield{key,value}` `:97-100`) via the unused
     `productDetails(productMetafields:variantMetafields:)` args (`:216`), which needs a
     namespace/key contract from the backend. **Verdict: render `Ref. <sku>`; the literal
     `0273/393` format is out of scope.**

3. **Description — available, and already plain text.** `descriptionHtml` (`schema.graphqls:133`,
   selected `ProductDetailsFragment.graphql:6`) is stripped in the converter
   (`ProductDetails+Converter.swift:42` → `String+Extension.swift:29-48`) into
   `Product.longDescription`, exposed as `productDescription` (`ProductDetailsViewModel.swift:54`).
   Dropping the `TabControl` (`ProductDetailsView.swift:477-492`) is pure view surgery. Note: block
   tags collapse to spaces, so multi-paragraph copy arrives as one run-on paragraph
   (`ProductDetailsConverterTests.swift:167`) — paragraph breaks would be a converter change.

**Mocks/previews caveat.** Apollo mocks carry all three fields (`OmniProduct+Mock.graphql.swift:13,15`,
`ProductVariant+Mock.graphql.swift:19`), but the domain fixtures default to empty:
`Brand.fixture(name: "")` (`Brand+Fixture.swift:24`), `Colour.fixture(name: "")` and
`Variant.fixture(sku: UUID(), colour: nil)` (`Product+Fixture.swift:33-35, 51`).
`MockProductDetailsViewModel` has no colour/SKU property (`:9-23`, init `:25-47`), and the PDP previews
(`ProductDetailsView.swift:594-614`) never set `productTitle`. So previews and any snapshot test must
pass explicit values (`productTitle: "Brand Name"`, `Variant.fixture(sku: "0273/393",
colour: .fixture(name: "Black"))`) or the new lines render blank/UUID.
