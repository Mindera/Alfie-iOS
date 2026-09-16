# Feature: Product Details — Information Rows from BFF Metafields (iOS port of ALFMOB-519)

**Status**: Draft
**Created**: 2026-09-16
**Last Updated**: 2026-09-16
**Implementation PR**: _[link when implemented]_

> Not ready to build: one divergence from the design file is still unconfirmed with the designer.
> See _Open Questions_.

---

## Overview

The PDP currently shows the product description and then two hardcoded rows — _Payment Options_ and
_Returns Information_ — that open WebViews. There is no product-specific long-form content beyond the
description, because the BFF had no field to carry it.

[AF-107](https://mindera.atlassian.net/browse/AF-107) closed that gap: `productDetails` now accepts
`productMetafields` identifiers and returns the matching values in `extensions`. The web storefront
consumed this in [ALFMOB-519](https://mindera.atlassian.net/browse/ALFMOB-519). This spec brings the
same content to iOS.

Two things make the iOS build deliberately different from web's, and both are decisions, not oversights:

1. **Description stays where it is.** Web folded the description into the section as its first row.
   `Alfie - Designs (Mobile)` keeps `Description` as its own frame above the row stack, and iOS
   already ships it that way.
2. **Rows navigate rather than expand.** Web expands content in place behind a `+`/`−` toggle. On iOS
   a row pushes a screen showing that row's content. This diverges from the Figma and is the one item
   still needing a designer's sign-off.

---

## User Stories

- **As a** shopper, **I want to** read a garment's size and fit guidance on its product page **so that**
  I can judge whether it will fit before buying
- **As a** shopper, **I want to** see what a garment is made from and how to care for it **so that** I
  can judge quality and upkeep before buying
- **As a** shopper, **I want** product pages to show only the information that exists for that product
  **so that** I am not presented with empty sections

---

## Scope

**In scope** — two rows, both sourced from product metafields in the `custom` namespace:

| Row | Metafield identifier |
|---|---|
| _Size & Fit_ | `custom` / `size_and_fit` |
| _Materials & Care Guide_ | `custom` / `materials_and_care` |

**Deliberately not in scope**: `custom/how_to_use` and `custom/ingredients` (web's beauty rows). They
have no designed row on iOS and no ratified label. Because `extensions` returns **only what is
explicitly requested**, omitting them from the request is sufficient — a beauty product simply shows
no rows in this section. Widening to four rows later is one array entry and two strings.

---

## Acceptance Criteria

### Scenario 1: A product with both metafields shows both rows

**GIVEN** the user opens a PDP for a product with `custom/size_and_fit` and `custom/materials_and_care` set
**WHEN** the _Product Details_ screen finishes loading
**THEN** a _Size & Fit_ row and a _Materials & Care Guide_ row are shown below the _Description_
AND they appear in that fixed order
AND each row shows its label with a trailing chevron

### Scenario 2: Rows follow the data, never the product type

**GIVEN** a product has `custom/size_and_fit` set but not `custom/materials_and_care`
**WHEN** the _Product Details_ screen finishes loading
**THEN** only the _Size & Fit_ row is shown
AND no empty row, placeholder or gap is rendered in place of the missing one

### Scenario 3: A product with no metafields shows no metafield rows

**GIVEN** a product whose `extensions` comes back empty
**WHEN** the _Product Details_ screen finishes loading
**THEN** no metafield rows are shown
AND the _Description_ and the retained complementary-information rows are unaffected

### Scenario 4: Tapping a row opens its content on a screen

**GIVEN** the user is on a PDP showing a _Size & Fit_ row
**WHEN** the user taps the row
**THEN** the _Product Information screen_ is pushed
AND its navigation-bar title is the row's label
AND its body is that metafield's rendered value

### Scenario 5: Returning from the content screen

**GIVEN** the previous scenario THEN state
**WHEN** the user taps back
**THEN** the user returns to the PDP at the scroll position they left

### Scenario 6: Plain-text values keep their line breaks

**GIVEN** a metafield value is plain text containing newlines
**WHEN** the _Product Information screen_ renders it
**THEN** the line breaks are preserved
AND consecutive whitespace is not collapsed

### Scenario 7: HTML values render as formatted text

**GIVEN** a metafield value contains HTML tags
**WHEN** the _Product Information screen_ renders it
**THEN** bold, italic, paragraphs, line breaks, lists and links render as formatted text in the app's
own typography
AND no raw tags or entities appear on screen

### Scenario 8: A rich-text value never surfaces as raw JSON

**GIVEN** a metafield value is a Shopify `rich_text_field` JSON document
**WHEN** the _Product Information screen_ renders it
**THEN** its text content is shown as plain text
AND no JSON braces, keys or punctuation appear on screen

### Scenario 9: Retained rows are visually consistent with the new ones

**GIVEN** the user is on a PDP
**WHEN** the metafield rows and the _Payment Options_ / _Returns Information_ rows are shown together
**THEN** all rows share the same height, divider treatment and trailing chevron size

---

## Data Models

```swift
// Model/Models/Product/ProductMetafield.swift — new
public struct ProductMetafield: Hashable {
    public let namespace: String?
    public let key: String
    public let value: String
}

// Model — Product gains the metafields carried by `extensions`
public struct Product {
    // ... existing properties
    public let metafields: [ProductMetafield]
}

// Model/Models/ProductDetails/ProductDetailsInfoRow.swift — new
/// A row in the PDP information stack. Metafield rows carry their own content;
/// complementary-information rows carry a destination.
public enum ProductDetailsInfoRow: Hashable {
    case metafield(ProductDetailsMetafieldRow)
    case complementaryInfo(ProductDetailsComplementaryInfoType)
}

public struct ProductDetailsMetafieldRow: Hashable {
    public enum Kind: String, CaseIterable {
        case sizeAndFit = "size_and_fit"
        case materialsAndCare = "materials_and_care"

        public static let namespace = "custom"
    }

    public let kind: Kind
    public let content: String
}

// ProductDetails/Models/ProductInformationConfiguration.swift — new
/// Everything the content screen needs, resolved at push time. The screen cannot fail:
/// it performs no fetch and therefore has no loading or error state.
public struct ProductInformationConfiguration: Hashable {
    public let title: String
    public let content: String
}
```

`ProductDetailsSection` gains a `productInformation` case alongside the existing
`complementaryInfo`.

### Naming

The BFF calls product-level metafields `extensions` and variant-level ones `attributes`, and our
domain `Product` already has an unrelated `attributes` property. To keep these apart:

- **metafield** — the domain concept, used everywhere in Swift
- **`extensions`** — used only when quoting GraphQL
- **metafield row** / **link row** — the two kinds of row in the PDP information stack

---

## API Contracts

### GraphQL

`ProductDetailsQuery.graphql` gains the variable and passes it through:

```graphql
query ProductDetailsQuery(
    $handle: String!
    $productMetafields: [MetafieldIdentifierInput!]
) {
    productDetails(handle: $handle, productMetafields: $productMetafields) {
        ...ProductDetailsFragment
    }
}
```

`ProductDetailsFragment.graphql` gains:

```graphql
extensions {
    namespace
    key
    value
}
```

Variables sent on every product detail request:

```json
{
  "handle": "…",
  "productMetafields": [
    { "namespace": "custom", "key": "size_and_fit" },
    { "namespace": "custom", "key": "materials_and_care" }
  ]
}
```

**No schema change is needed.** The vendored schema already carries AF-107's shape —
`Query.productDetails(handle:, productMetafields:, variantMetafields:)`,
`input MetafieldIdentifierInput`, `type Metafield` and `OmniProduct.extensions: [Metafield]` are all
present in `Alfie/AlfieKit/Sources/BFFGraph/CodeGen/Schema/schema.graphqls`. Running
`Alfie/scripts/run-apollo-codegen.sh` after the operation change generates the
`MetafieldIdentifierInput` and `Metafield` types, which Apollo has not emitted so far because no
operation reached them.

### BFF behaviour that shapes the client

- `extensions` returns **only what is explicitly requested**; requesting nothing yields `[]`.
- An unset metafield is **absent** from the list — not a null entry and not an error. Lengths 2, 1
  and 0 are all valid.
- **Order is undefined** and differs between Shopify and BigCommerce. Entries must be looked up by
  key, never by position.
- `value` is passed through untransformed — the BFF does no rich-text conversion, so format
  detection belongs to the client.
- **`Metafield.namespace` is nullable on output** while `MetafieldIdentifierInput.namespace` is
  required. Lookup must therefore match on `key` and treat a `nil` namespace as a match, rather than
  requiring `namespace == "custom"`.

---

## Navigation

### Entry Points

- PDP → tap a metafield row → _Product Information screen_

### Exit Points

- Tap back → PDP
- Tap a link row (_Payment Options_ / _Returns Information_) → existing WebView (unchanged)

### Routes

```swift
// ProductDetails/Navigation/ProductDetailsRoute.swift
public enum ProductDetailsRoute: Hashable {
    case productDetails(ProductDetailsConfiguration)
    case webFeature(WebFeature)
    case productInformation(ProductInformationConfiguration)   // new
}
```

The ViewModel navigates through its injected closure, as every other PDP route does:

```swift
public func didSelectMetafieldRow(_ row: ProductDetailsMetafieldRow) {
    navigate(.productInformation(.init(title: title(for: row.kind), content: row.content)))
}
```

---

## Localization

### Required Strings

| Key | English | Notes |
|-----|---------|-------|
| `pdp.product_information.size_and_fit.title` | "Size & Fit" | Row label and screen title |
| `pdp.product_information.materials_and_care.title` | "Materials & Care Guide" | Row label and screen title |

Wording is taken verbatim from `Alfie - Designs (Mobile)`. Note that web ships **`Materials & Care`**
for the same metafield — a divergence ALFMOB-519 made knowingly and put out of scope. The copy is
**unratified on both platforms**; see _Open Questions_.

`Alfie/Checksums/swiftgen_checksum.txt` must be regenerated after editing `L10n.xcstrings`.

---

## Analytics

No new events. Opening a product-information screen is not tracked in this iteration; if it becomes
interesting, the natural event is `pdp_information_row_tapped` with the row key and product id.

---

## Edge Cases

| Scenario | Expected Behavior |
|----------|-------------------|
| `extensions` is `[]` | No metafield rows; the rest of the PDP is unchanged |
| One of the two metafields is absent | Only the present row renders; no gap, no placeholder |
| A metafield value is an empty or whitespace-only string | Treated as absent — the row is not rendered |
| `namespace` comes back `nil` | Still matched, by `key` alone |
| `extensions` arrives in a different order than requested | Irrelevant — rows are ordered by the client's fixed order, not the response |
| A value contains HTML | Rendered as formatted text (Scenario 7) |
| A value is rich-text JSON | Text nodes flattened to plain text; never raw JSON (Scenario 8) |
| Both metafields absent **and** link rows present | Section shows only the link rows |

---

## Dependencies

### Services Required

- `BFFClientService` (`Core/Services/BFFService`) — already executes `ProductDetailsQuery`; gains the
  new variable

### Internal Dependencies

- `ProductDetails+Converter.swift` — maps `extensions` onto `Product.metafields`
- `SharedUI` — the row view and the rewritten HTML renderer
- `AccessibilityIdentifiers` — new `AccessibilityID` entries for the rows and the content screen

---

## Testing Strategy

### Unit Tests (`ProductDetailsTests`)

- [ ] Both metafields present → two rows, in fixed order
- [ ] One present → one row
- [ ] None present → no metafield rows
- [ ] Empty / whitespace-only value → row omitted
- [ ] `nil` namespace → still matched
- [ ] Response order reversed → rendered order unchanged
- [ ] Tapping a row navigates with the right title and content

### Service Tests (`CoreTests`)

- [ ] `ProductDetails+Converter` maps `extensions` to `Product.metafields`
- [ ] Converter tolerates a `nil` `extensions` list

### SharedUI Tests

- [ ] Plain text: newlines preserved, whitespace not collapsed
- [ ] HTML: bold / italic / paragraph / `<br>` / list / link all render; tags never visible
- [ ] Rich-text JSON: text flattened, no JSON punctuation on screen
- [ ] Unknown or malformed input degrades to plain text without throwing

### Localization Tests (`SharedUITests`)

- [ ] Both new keys exist in all supported languages

### Snapshot Tests

- [ ] PDP with two metafield rows
- [ ] PDP with one
- [ ] PDP with none
- [ ] _Product Information screen_ with plain text and with HTML content
- [ ] The 10 existing `ProductDetailsViewSnapshotTests` snapshots need re-recording

---

## Design References

- iOS PDP — [`202-18026`](https://www.figma.com/design/axx7Bz1fpQurtU6DHwVaJX/Alfie---Designs--Mobile-?node-id=202-18026&m=dev)
- iOS PDP, 360pt — [`673-89130`](https://www.figma.com/design/axx7Bz1fpQurtU6DHwVaJX/Alfie---Designs--Mobile-?node-id=673-89130&m=dev)

### Row metrics, taken from the `Accordion` component (`2992:27673`)

| Element | Value |
|---|---|
| Row | 8pt padding top and bottom around a 24pt content container |
| Label | left-aligned, `heading/x-small` — SF Pro Medium, 16/20, tracking −0.0313em, `#111111` |
| Trailing icon | 24×24, right-aligned |
| Row stacking | `gap: -1px` — adjacent rows share a single 1pt rule |
| Section placement | Below _Description_, above _Recommendations_; 24pt section gap, 16pt panel padding |

**Divergence from the design file**: the Figma row carries a `+` that toggles an `Expanded` variant.
This build substitutes a **chevron**, because the row navigates instead of expanding. Everything else
about the row follows the component.

---

## Performance Considerations

- The metafields ride on the existing `ProductDetailsQuery`. There is no second request, and the PDP
  gains no additional latency.
- Content is already in memory when a row is tapped, so the information screen presents immediately.
- Value rendering must not block the main thread. This is the reason the current `ThemedHtmlText`
  implementation is being replaced rather than adopted — see _Implementation Notes_.

---

## Accessibility

- Each row is a single button element exposing its label, with a trait indicating it opens a new screen
- `AccessibilityID` entries for each row and for the content screen's body
- The content screen supports Dynamic Type; rendered HTML must inherit the app's type scale rather
  than the HTML document's own defaults
- The content screen's title is announced on push

---

## Known Limitations

- **Beauty rows** (`how_to_use`, `ingredients`) are not requested or rendered. A beauty product shows
  no rows in this section.
- **Variant-level metafields** (`variantMetafields` → `ProductVariant.attributes`) are out of scope.
  No design calls for content that changes with the selected size.
- **No in-place expansion.** The `AccordionView` in `SharedUI` remains unused by the PDP; this feature
  does not migrate it to design tokens.
- **The retained link rows stay broken.** _Payment Options_ and _Returns Information_ point at
  `localhost:4000/payment-options` and `/return-options` (`ThemedURL`), which is the GraphQL BFF, not
  a content host. This feature restyles them but does not fix their destinations.

---

## Implementation Notes

### Rendering a metafield value

Detection runs in this order, and every branch ends in a rendered result — nothing throws:

| # | Detect | Render |
|---|---|---|
| 1 | Parses as JSON with `type: "root"` | Flatten the AST's `text` nodes to plain text |
| 2 | Contains HTML tags | Parse to `AttributedString` with app typography |
| 3 | Anything else | Plain text, newlines preserved |

JSON is tested first because it is unambiguous — a rich-text value always starts with `{`, so prose
cannot be mistaken for it. No live data currently exercises branch 1 (every seeded value is Shopify
_Multi-line text_), but it exists so a later change of metafield type cannot put raw JSON on screen.

**`ThemedHtmlText` must be rewritten for branch 2.** It exists today at
`SharedUI/Theme/HtmlText/ThemedHtmlText.swift` and is used nowhere. Its current implementation builds
an `NSAttributedString` with `.documentType: .html` inside a SwiftUI `body`, which is WebKit-backed,
main-thread-bound, slow enough to hitch a scroll, and applies the HTML document's own default styling
— Times New Roman at 12pt — in place of our design tokens. Replace it with a small hand-rolled parser
producing an `AttributedString` styled from the theme, supporting `<b>`, `<strong>`, `<i>`, `<em>`,
`<br>`, `<p>`, `<ul>`, `<li>` and `<a>`. Unknown tags are stripped, not rendered; entities are decoded.

**Do not route metafield values through `String.strippingHTML()`.** That helper collapses whitespace
runs, which would destroy the line breaks Scenario 6 requires. It remains correct for
`descriptionHtml`, where it is already used.

### Row composition

The two row kinds share one row view and therefore one set of metrics (Scenario 9). This means
restyling the existing complementary-information cell — `ProductDetailsView.swift` around
`:596-629`, plus `Constants.chevronSize` (16) and `Constants.complementaryInfoCellMinHeight` (72) —
to the metrics in _Design References_. Their WebView destinations are unchanged.

Metafield rows render **above** the link rows.

---

## Questions & Decisions

### Open Questions

- [ ] **Does design accept rows that navigate instead of expanding?** The Figma specifies an
  in-place accordion with a `+`/`−` toggle. This build pushes a screen instead, on the reasoning that
  a separate screen is a conventional iOS treatment for long-form content. **Not yet raised with the
  designer.** If it is rejected, the fallback is the accordion the Figma already specifies — the
  GraphQL, converter, content renderer, localization and row-selection logic all survive that reversal
  unchanged; only the row control and the new route would be discarded.
- [ ] **Is the row copy correct?** iOS takes `Materials & Care Guide` from the Figma; web ships
  `Materials & Care` for the same metafield. Neither has been ratified by a content owner. The
  metafield key is `custom/materials_and_care` either way, so this is presentation copy only and does
  not affect the contract. Also unresolved: the Figma's third row reads `Shippings and Returns`, which
  appears to be a typo and is not used by this feature.
- [ ] **Should the beauty rows be added?** Out of scope here pending a designed row and ratified
  labels for `how_to_use` and `ingredients`.

### Decisions

| Question | Decision |
|---|---|
| Build on ALFMOB-441's accordion first? | **No.** Nothing exists on iOS — neither the UI nor the data — so there is no intermediate step to preserve. 441's "panels reveal a link" design was a workaround for the missing metafield contract, which AF-107 has now delivered. |
| Is _Description_ a row? | **No.** It stays a standalone block above the row stack, per the Figma and per what iOS already ships. Its `Colour \| Ref.` metadata line stays attached to it. |
| Which rows? | **_Size & Fit_ and _Materials & Care Guide_ only.** The beauty pair is not requested. |
| Product-type branching? | **None.** Rows follow the metafields present on the product. |
| Expand in place or navigate? | **Navigate** to a content screen — pending design sign-off. |
| One screen or many? | **One screen per row**, titled with the row label, carrying resolved content. |
| Non-plain-text values? | Detect and render; **raw JSON must never reach the screen**. Full rich-text AST styling is not built, as no live data exercises it. |
| Newlines in plain text? | **Preserved.** Not routed through `strippingHTML()`. |
| Retained _Payment Options_ / _Returns Information_ rows? | **Kept**, though both are broken today. Restyled to the new row metrics so the stack is visually uniform; destinations untouched. |
| Variant metafields? | **Out of scope.** |
| Schema sync needed? | **No.** The vendored schema already carries AF-107. Operation change plus codegen is enough. |

---

## Changelog

| Date | Change | Author |
|------|--------|--------|
| 2026-09-16 | Initial spec created, from ALFMOB-519 and AF-107 | Khoi Nguyen |
