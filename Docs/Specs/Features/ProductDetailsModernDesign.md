# Feature: Product Details — Modern Design Rollout (ALFMOB-441)

**Status**: Draft
**Created**: 2026-08-07
**Last Updated**: 2026-08-07
**Implementation PR**: _[link when implemented]_

---

## Overview

Restyle the Product Details screen (PDP) to the modern Figma design, on top of the design-token foundations already rolled out to Splash, the app shell, Home and PLP. PDP is the least-migrated surface remaining: it has **zero** `Theme.*` and **zero** `theme.spacing.*` references today, and its layout is built around a bottom sheet that the new design removes entirely.

**This ticket does not, on its own, make PDP match the Figma.** It is the first of several slices. Four parts of the design depend on backend or content work that does not exist yet — recommendations, notify-me, size guide and rich accordion content — and are specified as separate slices. See [Known Limitations](#known-limitations).

Business value: PDP is the highest-intent screen in the funnel. It is currently the only major surface still rendering the legacy visual language, so it reads as inconsistent with the rest of the app after the Home and PLP rollouts.

---

## User Stories

- **As a** shopper, **I want** the product imagery to fill the width of my screen **so that** I can judge the product before reading anything
- **As a** shopper, **I want** to see the brand, product name and price grouped together at the top **so that** I can identify what I am looking at immediately
- **As a** shopper, **I want** the _Add to Bag_ button visible without scrolling past the whole page **so that** I can buy quickly once I have decided
- **As a** shopper, **I want** all available sizes shown at once **so that** I can see whether my size exists without opening anything
- **As a** shopper, **I want** unavailable sizes clearly marked **so that** I do not try to select something I cannot buy
- **As a** shopper, **I want** to know when a size is nearly sold out **so that** I can decide with urgency
- **As a** shopper with a long size run (shoes), **I want** sizes listed vertically with their prices **so that** I can compare them
- **As a** shopper, **I want** to see how many colours a product comes in **so that** I know there is a choice to make
- **As a** shopper, **I want** to pick a colour without leaving the page **so that** I keep my place
- **As a** shopper, **I want** the selected colour and product reference shown near the description **so that** I can quote them to customer service
- **As a** shopper, **I want** the product description as plain readable text **so that** I do not have to find a tab to read it
- **As a** shopper, **I want** delivery, payment and returns information reachable from the product page **so that** I can check them before buying
- **As a** shopper, **I want** to save a product to my wishlist from the product page **so that** I can come back to it
- **As a** shopper using VoiceOver, **I want** decorative indicators not to be announced as controls **so that** I am not misled into activating them
- **As an** iOS engineer, **I want** PDP to consume design tokens and shared components **so that** future design changes propagate without touching this screen
- **As an** iOS engineer, **I want** PDP covered by automated appearance tests **so that** a token or layout regression is caught before review
- **As a** designer, **I want** the shipped screen to match the Figma frame **so that** I do not have to re-review deviations

---

## Acceptance Criteria

### Scenario 1: Product details render as a single scrolling page

**GIVEN** a shopper opens a product from any entry point
**WHEN** the _Product Details screen_ finishes loading
**THEN** the screen renders as one continuous scroll
AND no bottom sheet is presented over the imagery
AND the content order is: gallery, product info, _Add to Bag_, size selector, description, accordion rows

### Scenario 2: Gallery is full-bleed with overlaid pagination

**GIVEN** the shopper is on the _Product Details screen_
**WHEN** the gallery renders
**THEN** the images span the full screen width with no horizontal padding and no corner radius
AND the gallery's height follows the image's own ratio rather than a fixed one
AND the gallery does not extend behind the navigation header
AND pagination indicators are overlaid near the bottom of the image, the selected one rendered as a wider pill

### Scenario 3: Product information block

**GIVEN** the shopper is on the _Product Details screen_
**WHEN** the information block renders
**THEN** the brand name is shown above the product name in a smaller, lighter style
AND the price is shown below the product name in a medium-weight style
AND when the product has more than one colour, a colour summary showing the selected swatch and a remaining count is shown at the trailing edge of that block

### Scenario 4: Add to Bag sits directly below the price

**GIVEN** the shopper is on the _Product Details screen_
**WHEN** the call-to-action row renders
**THEN** the full-width _Add to Bag_ button appears directly beneath the price
AND a square outlined wishlist button appears beside it
AND both scroll with the page

### Scenario 5: Sizes are shown as a grid for short size runs

**GIVEN** a product with a small number of sizes
**WHEN** the size selector renders
**THEN** all sizes are shown at once as boxed square chips in a grid
AND the section is headed by a title on the left and a _Size Guide_ link on the right
AND no size sheet is presented

### Scenario 6: Sizes are shown as a vertical list for long size runs

**GIVEN** a product with a large number of sizes
**WHEN** the size selector renders
**THEN** each size is shown as a full-width row
AND each row may show its price at the trailing edge

### Scenario 7: Selecting a size

**GIVEN** the shopper is viewing the size selector
**WHEN** the shopper taps an available size
**THEN** that size becomes selected
AND selection is indicated by a heavier border, not by filling the chip

### Scenario 8: Unavailable sizes

**GIVEN** a product with an out-of-stock size
**WHEN** the size selector renders
**THEN** that size's label is struck through and dimmed
AND a bell indicator is shown alongside it
AND the size cannot be selected
AND the bell is not exposed to assistive technology as a control

### Scenario 9: Low stock messaging

**GIVEN** a product with a size whose remaining stock is at or below the low-stock threshold
**WHEN** the size row renders
**THEN** a low-stock message is shown at the trailing edge of that row

### Scenario 10: Choosing a colour

**GIVEN** a product with several colours
**WHEN** the shopper taps the colour summary
**THEN** the colour selection surface is presented
AND the currently selected colour is indicated by a border on its swatch

### Scenario 11: Description and product reference

**GIVEN** the shopper is on the _Product Details screen_
**WHEN** the description renders
**THEN** the description is shown as plain body text with no tab control
AND a metadata line beneath it shows the selected colour name and the product reference
AND when either value is unavailable, that part of the line is omitted rather than rendering empty

### Scenario 12: Accordion rows

**GIVEN** the shopper is on the _Product Details screen_
**WHEN** the accordion rows render
**THEN** each row shows its title with an expand indicator
AND rows are separated by hairline dividers
**WHEN** the shopper taps a row
**THEN** the row expands in place to reveal a link to the corresponding information

### Scenario 13: No behavioural regression

**GIVEN** the redesigned _Product Details screen_
**WHEN** a shopper selects colours or sizes, adds to bag, adds to wishlist, opens the full-screen gallery, or navigates to complementary information
**THEN** the outcome is identical to the previous implementation

### Scenario 14: Error state

**GIVEN** the product fails to load
**WHEN** the _Product Details screen_ renders
**THEN** the existing error view is shown, restyled to design tokens

---

## Data Models

No new domain models and **no GraphQL changes**. Every field the redesign needs is already selected by `ProductDetailsFragment` and already reaches the domain model.

Three view-model additions are required to surface data that is fetched but not currently exposed:

```swift
protocol ProductDetailsViewModelProtocol {
    // existing members …

    /// Selected variant's colour name, for the description metadata line.
    /// Empty for single-option products and the no-variant fallback.
    var selectedColourName: String? { get }

    /// Selected variant's SKU, rendered as the product reference.
    var productReference: String? { get }

    /// Brand name for the in-body brand line. Already exists as `productTitle`,
    /// which is currently consumed only by the toolbar.
}
```

A new pure type holds every appearance and layout rule, so thresholds live in one testable place (see [Testing Strategy](#testing-strategy)):

```swift
enum ProductDetailsLayoutRules {
    enum SizeLayout { case chipGrid, verticalList }
    enum ColourLayout { case summaryOnly, inlineGrid, sheet }
    enum StockMessage: Equatable { case none, lastOne, lastUnits }

    static func sizeLayout(forSizeCount: Int) -> SizeLayout
    static func colourLayout(forColourCount: Int) -> ColourLayout
    static func stockMessage(forAvailable: Int?) -> StockMessage
}
```

The shared sizing component gains one arrangement:

```swift
extension SwatchLayoutConfiguration.Arrangement {
    case verticalList(itemSpacing: CGFloat)
}
```

---

## API Contracts

**None.** `ProductDetailsFragment` already selects `brandName`, `descriptionHtml`, and per-variant `sku`, `price`, `inventory { available }` and `optionValues`. No query, fragment or schema change is in scope.

---

## Navigation

Entry points are unchanged. One route is removed and one is retained:

- **Removed**: the details bottom sheet (iOS 16.4+ path). All content moves into the main scroll.
- **Removed**: the size sheet. Long size runs render inline as a vertical list.
- **Retained**: the colour sheet, for products with many colours.
- **Retained**: navigation to complementary-information web features, now reached from inside an expanded accordion row rather than from a chevron row.
- **Retained**: full-screen zoomable gallery on image tap.

---

## Localization

New strings required in `L10n.xcstrings`:

| Key area | Purpose |
|---|---|
| Size selector title | "Select a Size" heading |
| Size guide link | _Size Guide_ label |
| Low stock — single | Message when one unit remains |
| Low stock — few | Message when stock is low |
| Product reference | Prefix for the reference value |

The existing `L10n.Product.Size.title` + `":"` concatenation in the single-size view is **removed** — it is not localisation-safe. Replace with a single parameterised string.

**Regenerate `Alfie/Checksums/swiftgen_checksum.txt` whenever `L10n.xcstrings` changes.**

---

## Analytics

No analytics changes. This is a visual and layout rollout; existing events fire from unchanged view-model paths.

---

## Edge Cases

- **Single-colour and no-colour products** — the colour section is hidden entirely; reuse the existing `hideOnSingleColor` behaviour.
- **One-size products** — render the single size without the grid, replacing today's hand-concatenated label.
- **Empty brand name** — fixtures and the no-variant fallback can produce an empty brand; the line is omitted rather than rendering blank space.
- **Missing colour name or reference** — the metadata line degrades to whichever value exists, or is omitted entirely.
- **Long product descriptions** — the HTML stripper collapses block tags to spaces, so multi-paragraph copy arrives as one run-on paragraph. Accepted for this slice; paragraph handling would be a converter change.
- **Long size runs** — the vertical list is unbounded; verify scrolling with a shoe-size product.
- **CTA reachability on small devices** — the single-scroll layout was validated on a 402pt-wide, 874pt-tall device with short copy. **Re-verify on a 667pt device and with a long-description product before raising the PR.** A sticky-CTA variant was prototyped and rejected on the larger device; it is preserved on branch `prototype/pdp-inline-cta` should the small-device case need it.
- **iPad and pre-iOS-16.4** — both currently share the legacy scroll path. Confirm the branch can collapse before deleting it.

---

## Dependencies

**Hard, must land first:**

- **Design-token refresh.** Provides `Typography.Body.mediumBold` for the price, the brand colour ramp, and a new spacing step. Ships as its own PR because its generated diff is app-wide. `TypographyBody` must also be extended by hand to expose `mediumBold`, mirroring the existing `smallBold` pattern — the generated token alone does not compile at call sites.

**Soft — this slice ships without them, with two knowingly off-design elements:**

- **Two semantic tokens missing upstream** in `Mindera/Alfie-Mobile-Design-Tokens`: a strong border alias resolving to `#CDCDCD`, and a secondary content alias resolving to `#2B2B2B`. The primitives already exist; only the aliases are absent, so each is a one-line addition. They **cannot** be patched locally — the token pull overwrites local edits. Until they land, size-chip borders render lighter than designed and the brand line renders at primary weight, flattening the intended hierarchy. See `.scratch/pdp-modern-design/token-requests.md`.

**Shared components modified by this work** (check callers before editing):

- The sizing selector and swatch views — PDP is the only production consumer.
- The colour-and-sizing header view — PDP is the only consumer.
- `AccordionView` — currently used only by a debug demo screen; must be migrated to design tokens as part of adopting it.

---

## Testing Strategy

**What makes a good test here:** assert externally observable behaviour — which layout a given input produces, which appearance a given state produces, and that the whole screen renders as expected. Do not assert on view internals or private helpers.

### Seams

Two seams only.

1. **Existing — the product details view-model protocol and its mock.** The entire screen is driven through it, so every screen-level test injects the mock. **The mock needs new colour-name and reference properties**, and fixtures need real values: brand and colour names default to empty and SKU defaults to a UUID today, so a naive test would assert blank content exactly where this redesign adds it.

2. **New — `ProductDetailsLayoutRules`.** A single pure type holding the size-layout, colour-layout and low-stock-message rules. One new seam rather than three scattered extractions, and it puts every threshold that design may later revise in one file.

### Unit tests (primary assertions)

Prior art: the PLP style test, which asserts an icon-for-state mapping with no rendering.

- Size layout selection across the count threshold.
- Colour layout selection across the count threshold.
- Low-stock message mapping, including the nil and zero cases.
- Size swatch appearance per state — available, selected, out-of-stock, unavailable — explicitly asserting that **selection is a border and not a fill**, since that is a behavioural change to the existing component.
- The out-of-stock bell and the _Size Guide_ link expose **no** tap target and **no** accessibility action, so the inert treatment cannot silently regress into a dead button.

### Snapshot tests (regression net)

Prior art: the Home and Splash snapshot suites. `ProductDetailsTests` already depends on `TestUtils`, which links the snapshot library — **no package change needed**.

- One default-state full screen, using the full-height container helper; PDP is long.
- One error state, reusing the existing failure-state initialiser flag.

Deliberately few, to keep baseline maintenance cheap.

> **Two harness caveats.** Snapshot references are pinned to an iOS major; when no simulator on that major is installed, the verification script **falls back and silently skips every snapshot class**, so `verify.sh` can pass green having asserted no snapshots at all. CI must run on the pinned major. Second, snapshot classes are auto-discovered by scanning for snapshot assertions — a new PDP suite is picked up with no registration, and so is the skip.

### Regression

All existing product details view-model tests must pass untouched, with one exception: the test pinning the default swatch colour for invalid swatch URLs changes alongside the token migration of that fallback.

### Acceptance criteria amendment

**ALFMOB-441's acceptance criteria currently say snapshot baselines are "regenerated".** There are none to regenerate — PDP has no snapshot tests today. Amend to "snapshot baselines **added** and passing, plus unit tests covering size and colour state mapping".

---

## Design References

- Figma PDP canvas: <https://www.figma.com/design/axx7Bz1fpQurtU6DHwVaJX/Alfie---Designs--Mobile-?node-id=1-10080>
- Rendered exports and the full value-by-value token mapping: `.scratch/pdp-modern-design/`
- Decision record: `.scratch/pdp-modern-design/map.md` — ten resolved decision tickets behind this spec

---

## Performance Considerations

- Removing the bottom sheet also removes runtime content measurement and detent recalculation on every layout pass.
- The accordion panels hold a link, not an embedded web view. Hosting web views inside a disclosure group inside a scroll view was explicitly rejected: nested scrolling, indeterminate height, and one web view per row on a screen that already carries an image carousel.

---

## Accessibility

- Add a screen-level accessibility identifier; PDP has none today, unlike PLP.
- Add identifiers for the new elements: brand line, colour summary, size chips, size guide link, accordion rows.
- **Resolve an existing naming collision** — the in-body title renders the *product name* under an identifier called `productTitle`, while `productTitle` on the view model is the *brand*. Adding a visible brand line makes this actively misleading.
- Selected size and colour must carry the selected trait.
- The out-of-stock bell and the _Size Guide_ link are decorative in this slice: not focusable, no accessibility action.
- Colour template images must be tinted with `foregroundStyle`, never `tint` — the latter is a silent no-op on template images in this codebase.

---

## Known Limitations

After this slice ships, the screen will **not** match the Figma frame. Four things are deferred, each with its own blocker:

| Deferred | Blocked by |
|---|---|
| "You might also like" recommendations grid — roughly the bottom third of the design | Related products are exposed as IDs only, so resolving them needs a second fetch; the "Best Seller" badge has no identified data source |
| Rich in-panel accordion content — twelve category-specific variants with imagery | Needs a metafield namespace and key contract from backend |
| Notify-me — makes the out-of-stock bell functional | No service exists |
| Size guide — makes the link functional | No content and no destination exist |
| Category-driven size layouts — image cards and price-delta cards | Product type is not selected in the query and no category-to-layout mapping is agreed |
| A multi-image gallery — carousel paging and its indicators are unreachable in practice | The query never selects the product-level `images` array; see below |

Additionally, the design's exact product-reference format cannot be reproduced: no reference or style-number field exists on the product or variant types, so the SKU is used instead.

**State this plainly on the Jira ticket** so it is not discovered at design review.

### The gallery can currently show only one image — needs its own ticket

Found while verifying the gallery on the Shopify test store (2026-08-11). Not a defect in this slice;
it predates it and is out of scope here.

The schema exposes **four** image sources across two types, and the app selects only two:

| Type | Field | Selected by the app? | Notes |
|---|---|---|---|
| `ProductVariant` | `media` — `[Image]` | ✅ the gallery source | `ProductDetailsFragment.graphql` |
| `OmniProduct` | `primaryImage` — `Image` | ✅ but only as a fallback | one image, used when a variant carries no media (`ProductDetails+Converter.swift`) |
| `OmniProduct` | `images` — `[Image!]!` | ❌ never requested | where product-level photography appears on the test store |
| `OmniProduct` | `media` — `[Image]` | ❌ never requested | a second product-level collection; which one the BFF populates needs confirming |

So `productImageUrls` resolves to *variant media, else a single `primaryImage`* — the ceiling is one
image whenever a variant carries one or none. On the test store every product is a single implicit
Shopify variant (`Title = Default`) with exactly one media entry, so:

- the carousel never paginates and `shouldShowMediaPaginatedControl` is always `false`, leaving the
  pagination indicators, swipe paging and the multi-ratio height rule **unexercised end to end**;
- images added to a *product* in Shopify do not appear on the PDP unless they are also attached to
  the variant.

The fix is a product decision, not just a technical one. Options, cheapest first:

1. **Attach the images to the variant** in the storefront — no code change; keeps per-colour photo
   sets correct once real colour variants exist.
2. **Union** variant media with the product-level collection, de-duplicated — richest gallery, but a
   shopper viewing one colour may see photographs of another.
3. **Prefer the product-level collection when a variant carries ≤ 1** — treats a lone variant image
   as "no real gallery".

Options 2 and 3 need a fragment change, converter work and Apollo codegen — and first a decision on
which of `OmniProduct.images` and `OmniProduct.media` the BFF actually populates, since picking the
wrong one silently yields an empty gallery.

---

## Implementation Notes

Follow the shape of the PLP rollout — a tight, mostly-mechanical diff — rather than the Home rollout, which added new features alongside the restyle.

**Substitutions**, applied across roughly 41 sites in the main view, 14 in the colour/size sheet, and one in the view model:

- Legacy spacing primitives to the themed spacing scale.
- Legacy colour primitives to semantic theme aliases: primary text, muted text, inverted text, and link colour paired with the underlined link type style.
- Legacy sizing radii to the themed radius scale — **but note the design uses square corners for size chips, the call-to-action and the wishlist button**; only pagination indicators and the sheet handle are rounded.

**Deletions:**

- The bottom sheet, its detent calculation, its detent state, and the carousel and tab-bar measurement that existed only to feed it.
- The description tab control.
- The bespoke complementary-info row, replaced by the shared accordion component.
- The hand-forced 18pt font override in the colour/size sheet — no token defines it.
- Dead constants: the sheet close icon size and the colour chevron size, both already unreferenced.

**Additions:**

- A colour summary view — selected swatch plus remaining count. Nothing in the shared library covers this; it is the one justified new component, and belongs alongside the existing colour components rather than inline in the screen.
- The vertical-list arrangement on the shared sizing selector.

**Reuse rule:** every section must use an existing shared component, or state why nothing fits. The bespoke spots being replaced are the complementary-info row, the title header, the single-size view, and the colour/size sheet's hand-rolled header and rows; the sheet's chrome should move onto the shared modal component.

**Commit order**, so review has a spine: token migration first (mechanical, no intended visual change), then the sheet deletion and single-scroll layout, then section by section — gallery, info block, size, colour, description, accordions.

**Verification:** run `./Alfie/scripts/verify.sh` (or `--skip-integration` for the fast loop) after every change. Only mark complete on a passing full verification.

---

## Questions & Decisions

Four rules below are **inferences drawn from static Figma frames, not design instructions**, and are out with design and the team for confirmation. Each is cheap to change because all four live in one type.

| Open question | Assumption encoded in this spec |
|---|---|
| When does each of the three colour surfaces appear? The design shows a summary, an inline grid and a sheet, but never says which applies when. | Summary whenever a colour is selected, and tappable; inline grid for few colours; sheet for many — mirroring the size rule. **The summary needs a selected swatch to draw, so a long colour run with no selection shows a tappable heading row instead; without it that product has no way to open the sheet.** |
| At what size count does the chip grid become a vertical list? | Reuse the existing threshold in the current implementation. |
| What are the low-stock thresholds and wording? | One remaining shows the single-unit message; at or below a small N shows the low-stock message. **N is unconfirmed.** |
| Should the accordion expand to reveal a link, or keep today's one-tap navigation? | Expand to a link — the affordance matches the design, and the panel is the exact slot the real content later fills. Regresses a one-tap journey to two taps. |
| Should the bell and _Size Guide_ ship as non-functional decoration? | Yes — "if the design has it, it stays". Both non-interactive. |

Questionnaire: `.scratch/pdp-modern-design/to-questionnaire-pdp-control-behaviour.md`

**Decisions already settled** (full rationale in the decision record):

- Design tokens only — no new legacy primitive references are introduced by this work. Where no token exists, the element waits on an upstream token rather than being silently substituted.
- Gallery is 3:4 and full-bleed. The square-image variant in the canvas is exploratory (drawn at 20% opacity) and is not the spec.
- The bottom sheet is deleted rather than restyled.
- The colour sheet survives; the size sheet does not.
- Accordion rows adopt the shared accordion component rather than a bespoke row.

---

## Changelog

| Date | Change |
|---|---|
| 2026-08-07 | Initial draft, synthesised from the resolved decision map at `.scratch/pdp-modern-design/map.md` |
| 2026-08-11 | Recorded the single-image gallery limitation found while verifying slice 2 on the test store |
