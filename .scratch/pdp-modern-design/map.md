# Map: PDP Modern Design Rollout (ALFMOB-441)

## Destination

An **implementation spec** for restyling the Product Details screen to the modern Figma design — ready to hand to `/ios-resolve` or a dev, with every open design and scope question already decided. No production code is written while wayfinding (throwaway prototypes excepted).

Scope is **restyle + layout only**: everything achievable with today's data and behaviour. The four non-visual items the Figma implies (inline accordion content, notify-me, size guide, recommendations grid) are out of scope and become new ALFMOB tickets under epic 427.

> **Read this before planning 441.** The intent is that PDP **completely matches the Figma**. ALFMOB-441 alone does **not** achieve that — it is the first vertical slice. See [Blocked by, and by what](#blocked-by-and-by-what) for exactly what is missing and why, and [Vertical slices](#vertical-slices) for how the rest is carved up. Say this plainly on the Jira ticket so it is not discovered at review.

## Blocked by, and by what

### Missing design tokens — complete list

PDP uses `Theme.*` only. Exactly **two** values on the whole screen have no `Theme.*` token. In both cases the *primitive already exists* upstream, so each is a one-line addition to `theme.alfie-theme.tokens.json` in `Mindera/Alfie-Mobile-Design-Tokens` — **not** an Alfie-iOS change, and it does not survive a `pull-design-tokens.sh` if patched locally.

| Token needed | Resolves to | Value | Needed for |
|---|---|---|---|
| `border/border-strong` | `{colours-brand-300}` | `#CDCDCD` | size-chip default border, unselected pagination dot, out-of-stock strikethrough rule, sheet grab handle |
| `content/content-secondary` | `{colours-brand-700}` | `#2B2B2B` | brand-name line, `Black \| Ref. <sku>` meta line |

Until these land, those elements render off-design (`border-soft` is three steps lighter; `content-primary` flattens the brand line into the product name). Detail and rationale: [token-requests.md](token-requests.md). **Nobody has raised this upstream yet.**

### Unachievable today — blocked on backend or content

| Item | Blocked by |
|---|---|
| Inline accordion content (12 category variants with imagery) | needs a metafield namespace/key contract from backend; `OmniProduct.extensions: [Metafield]` is the only hatch and is unselected |
| `Ref. 0273/393` exact format | no reference/style-number field exists on `OmniProduct` or `ProductVariant`; only `sku`. `Product.styleNumber` is hardcoded `""` |
| Notify-me (a working bell) | no service exists |
| Size Guide content | no content and no destination exists |

### Achievable, but not a restyle

| Item | What it takes |
|---|---|
| Recommendations grid (~bottom third of the page) | `OmniProduct.relatedProducts: [String]` exists but returns **IDs** — needs the field selected, a second fetch to resolve them, a card grid, and a "Best Seller" badge whose data source is unidentified |
| Category-driven size layouts (food image cards, price-delta cards) | needs `productType` selected and an agreed category→layout mapping |
| Header glass blur (`backdropFilter: blur(16px)`) | no effect tokens exist in the design system at all; SwiftUI `Material` would work but breaks the token-only rule |

## Vertical slices

441 is slice 1. Each later slice is independently shippable and names its own blocker, so work that is ready is never held behind work that is not. **Each slice is written up as a ticket in [`slices/`](slices/), carrying its own scope, blockers and the open questions it waits on.**

| Slice | Contents | Blocked by |
|---|---|---|
| **0 — token refresh** | `pull-design-tokens.sh` + regenerate; adds `body.mediumBold`, brand ramp. **Done, uncommitted on this branch.** Ships as its own PR before 441 | — |
| **0b — upstream token PR** | `border-strong` + `content-secondary` aliases | needs someone with access to the design-tokens repo |
| **1 — ALFMOB-441** | full-bleed 3:4 gallery, info block, inline CTA (sheet deleted), size chip grid + vertical list, description + meta line, accordion shell, token migration across ~55 sites | slice 0; two elements render off-design until 0b |
| **2 — recommendations grid** | select `relatedProducts`, resolve fetch, card grid, badge | badge data source unknown |
| **3 — accordion content** | metafield contract, category→accordion mapping, in-panel imagery, category labels | backend contract |
| **4 — notify-me** | makes the bell functional | backend service |
| **5 — size guide** | makes the link functional | content |
| **6 — category size layouts** | `productType` selection + mapping | design mapping |

## Notes

- **Domain**: iOS / SwiftUI / MVVM, `AlfieKit` SwiftPM modules. Ticket: [ALFMOB-441](https://mindera.atlassian.net/browse/ALFMOB-441). Epic: [ALFMOB-427](https://mindera.atlassian.net/browse/ALFMOB-427).
- **Figma**: [PDP canvas](https://www.figma.com/design/axx7Bz1fpQurtU6DHwVaJX/Alfie---Designs--Mobile-?node-id=1-10080). Rendered exports in `.scratch/figma/` (`pdp-main.png`, `pdp-ios-s-a.png`, `pdp-ios-s-b.png`, `pdp-size-bottom-sheet.png`, `pdp-size-variants-square.png`).
- **Skills every session should consult**: `/grilling`, `/domain-modeling`, `ios-skills:ios-swiftui-expert`. Prototype tickets use `/prototype`; research tickets use `/research`.
- **Prior art — follow the PLP shape** (`9ae85bc`, 10 files, +139/−69), not Home's (`f934ba0`, 26 files). Token substitutions the rollout uses:
  - `Primitives.Spacing.spacing0/8/16/24/32` → `theme.spacing.space0/space100/space200/space300/space400`
  - `Primitives.Colours.neutrals800` (text) → `Theme.contentContentPrimary`; `neutrals500` (muted) → `Theme.contentContentTerciary`; `neutrals0` (on-image) → `Theme.contentContentInvertedPrimary`
  - links → `Theme.linkLinkPrimaryDefault` + `theme.font.link.medium(_, underline: true)`
  - `Sizing.radius*` → `theme.radius.soft/.strong/.rounded`
  - `private enum Constants` deleted unless the value genuinely has no token, and then carries a `// Figma: …` comment
- **Hard rule — reuse SharedUI first.** Before writing any new view, check whether `Sources/SharedUI` already has the component and use it. Build something bespoke only when nothing fits, and say why. PDP already consumes `SnapCarousel`, `ZoomableCarousel`, `PaginatedControl`, `PriceComponentView`, `TabControl`, `ThemedButton`, `ThemedDivider`, `ErrorView`, `ColorSelectorComponentView`, `ColorSwatchView`, `SizingSelectorComponentView`, `ColorAndSizingSelectorHeaderView`, `PickerMenu`, `RemoteImage`, `ThemedIcon`, the toolbar set and the shimmer/tap-highlight modifiers. Sitting unused and directly relevant: **`AccordionView`** (`Theme/Accordion/`), **`ThemedModal`** (`Theme/Modal/`), `Chip` (`Components/Chips/`), `Tag` (`Components/Tags/`), the `Badge*` modifiers, `ThemedSegmentedView`. The known bespoke spots to replace rather than restyle are `complementaryInfoCell`, `titleHeader`, `singleSizeView`, and the colour/size sheet's hand-rolled header and rows.
- **Hard rule (ticket 09)**: `Theme.*` only. Do **not** introduce `Primitives.*` references, and do **not** silently substitute a near-neighbour token for a Figma value that has none — add it to [token-requests.md](token-requests.md) and leave the element pending. The token JSON is pulled from `Mindera/Alfie-Mobile-Design-Tokens`, so editing `SharedUI/DesignTokens/*.json` locally is pointless: the next pull overwrites it.
- **Convention observed on PLP**: do not fake data or churn shared components for a restyle — a mocked-chips experiment was reverted before merge.
- **Starting state**: `ProductDetailsView.swift` (634 LoC) has **zero** `Theme.*` and **zero** `theme.spacing.*` — ~41 legacy call sites, plus ~14 in `ProductDetailsColorAndSizeSheet.swift` and one in the view model (`:311`). Least-migrated remaining surface.
- **Known traps**: `ThemedIcon`/template images use `.foregroundStyle`, never `.tint`; SwiftGen checksum (`Alfie/Checksums/swiftgen_checksum.txt`) must be regenerated if `L10n.xcstrings` changes; verify with `./Alfie/scripts/verify.sh --skip-integration`.

## Decisions so far

> **The map is complete.** All ten decision tickets are resolved and the destination is delivered: [`Docs/Specs/Features/ProductDetailsModernDesign.md`](../../Docs/Specs/Features/ProductDetailsModernDesign.md). What remains is outward-facing work a human must do — see [What still needs a human](#what-still-needs-a-human).

## What still needs a human

- **Raise the Jira tickets.** Slices 2–6 are written up in [`slices/`](slices/) but not created under ALFMOB-427; no comment posted on ALFMOB-441.
- **Amend ALFMOB-441's AC** — "snapshot baselines regenerated" is unmeetable; there are none to regenerate.
- **Own slice 0b** — two one-line token aliases in `Mindera/Alfie-Mobile-Design-Tokens`. Without them, size-chip borders and the brand line ship off-design.
- **Send the questionnaire** — [to-questionnaire-pdp-control-behaviour.md](to-questionnaire-pdp-control-behaviour.md). Four rules in the spec are inferences awaiting design.
- **Commit the token refresh** — 8 files on `claude/wayfinder-skills-alfmob-441-88422c`, verified passing, meant to ship as its own PR.

<!-- one line per resolved ticket -->

- [Decide how ALFMOB-441 is verified, given the snapshot AC](issues/07-test-strategy.md) — **both**: style unit tests (PLP pattern, no rendering) carry the real assertions for size/colour state mapping, the border-not-fill selection change, low-stock strings, and that the bell and `Size Guide` are non-interactive; plus **two** snapshots (default state, error state) as a layout net. Verified this session that the snapshot suite genuinely runs and passes — earlier notes saying otherwise were stale. Two caveats: snapshots are **pinned to iOS 26 and silently skipped** when no such simulator exists, and PDP fixtures default to empty brand/colour/UUID-SKU so fixture work is a prerequisite. **441's AC must be amended** — "regenerated" → "added", since no baselines exist.
- [Resolve the accordion conflict: "+" affordance vs. web navigation](issues/05-accordion-rows.md) — **adopt `AccordionView`** in place of the bespoke `complementaryInfoCell`, so the `+`/`−` genuinely expands and the real panels drop in later without a rewrite. Row set unchanged (`.delivery`/`.paymentOptions`/`.returns` keep their L10n labels) — the design's category labels arrive with the content ticket. **`AccordionView` must be migrated to `Theme.*`** as part of this (it is still on legacy `Primitives.*`) — wider blast radius than the sizing components, so check callers first. **Embedding the web feature inside the panel was rejected** as unbuildable (a web view inside a `DisclosureGroup` inside a `ScrollView`); the panel holds a link row that opens the existing web route instead. Design detail in `.scratch/figma-accordion/`: 12 category-specific content variants, confirming inline content is a content platform, not a restyle.
- [Decide the collapsed colour representation (swatch + "+3")](issues/04-colour-summary-chip.md) — the ticket's premise was wrong: the design has **three** colour representations, not a collapsed chip (renders in `.scratch/figma-colors/`). **Mirror the size pattern** — a tappable `+N` swatch summary in the info block, an inline `Select a Colour` card grid for few colours, the sheet list for many. Selection is a black border, which `ColorSwatchView` already does. **The colour sheet survives** (unlike the size sheet ticket 03 kills), so `ProductDetailsColorAndSizeSheet` is restyled onto `ThemedModal`, not deleted; `PickerMenu` loses its PDP caller. Confirmed first-hand: brand name **is** `#2B2B2B` `label/small`, and the 40×40 wishlist button's `#06080A` stroke maps exactly to `Theme.buttonSecondaryStrokeSecondaryDefault` — no gap. Price: restyle today's `PriceComponentView` usage only.
- [Decide the boxed size-grid selector, minus notify-me and size guide](issues/03-size-selector-grid.md) — the design has **four** size layouts, not one (renders in `.scratch/figma-sizes/`). **Extend `SizingSelectorComponentView` with a `.verticalList` arrangement**; ship chip grid (short runs) + vertical list (long runs), chosen on the existing size-count threshold — **the >6 collapse-to-sheet dies**. PDP is the only production consumer of the sizing components, so extending them is safe. Selection is a black **border**, not today's black fill; chips are square; out-of-stock becomes a label strikethrough plus a **decorative, non-tappable** bell; `Size Guide` renders inert. Per-size price and low-stock text (`Only 1 item left!` / `Last units`) are **in** — `variants.price` and `variants.inventory.available` are already fetched — with the threshold recorded as an assumption for design. Card-grid variants (image / price-delta) deferred as category work; no schema change.
- [Prototype the inline Add-to-Bag layout that replaces the bottom sheet](issues/02-inline-cta-layout.md) — **Variant A wins: CTA inline under the price, bottom sheet deleted.** The decisive finding is that the PDP is *short* — everything below the gallery fits one screenful, so at full scroll the inline CTA was still on screen and variant B's sticky bar never triggered. Kills `popupView`, `setupDetents`, the detent state and the carousel/tab-bar measurement that fed it, and collapses the iOS-16.4-vs-legacy branch (**verify iPad first** — it shares `legacyPDPView`). Makes PDP snapshot-testable, unblocking ticket 07. Caveat: measured on iPhone 16 Pro only — re-test the sticky logic on a 667pt device and with long product copy. Prototype: branch `prototype/pdp-inline-cta` @ `27dd689`.
- [Refresh the design-token pull and regenerate, in its own PR](issues/10-token-refresh.md) — done, `verify.sh --skip-integration` passed. **`Typography.Body.mediumBold` now exists** (price binds to `theme.font.body.mediumBold`); `Primitives.Colours.brand0…900` + the `brandNewBrand*` yellow ramp added; `buttonPrimary` background/stroke repointed `neutrals800` → `brand500` with **no visual change** (both `#111111`); `spacing44` added. **No new `Theme.*` aliases** — G1/G2 stay blocked on the upstream requests.
- [Decide how to close the 11 Figma values that have no token equivalent](issues/09-token-gaps.md) — **rule: `Theme.*` only, no new `Primitives.*` references; where no token exists the element waits on an upstream request rather than being substituted.** Checking the upstream token repo found the local pull is **stale**, which dissolves most of the gaps: `body-medium-bold` already exists upstream (so the price does **not** use `link.medium`), G4 → `contentContentPrimaryDisabled`, G6 → `icons-icon-xlarge`, G8 is a `lineSpacing` fix, G7/G10/G11 are geometry. Only **G1** (`#CDCDCD` border) and **G2** (`#2B2B2B` secondary text) are real gaps — the primitives exist upstream as `colours-brand-300/700` but no `border-*`/`content-*` alias does; both are recorded in [token-requests.md](token-requests.md) for delivery with the spec. Refresh becomes [ticket 10](issues/10-token-refresh.md).
- [Extract the PDP Figma spec and map it onto the design tokens](issues/01-figma-token-mapping.md) — spacing is **fully token-clean** (every value an exact `space0/050/100/150/200/300` hit); colours are exact primitives; typography maps 1:1 (`label.small`, `body.medium`, `heading.xSmall`, `link.medium(underline:)`); only `radius.rounded` is used — **size chips, CTA and wishlist button are square, do not apply `radius.soft`**; gallery is **3:4, horizontally full-bleed but not behind the header** (the square variant `#673:89370` is exploratory at 20% opacity); pagination dots sit 12pt above the gallery bottom, selected 12×6 pill. **11 values have no token equivalent (G1–G11)** — see [ticket 09](issues/09-token-gaps.md). Findings: [research/01](research/01-figma-token-mapping.md).
- [Is the description block's brand line and "Black | Ref. 0273/393" meta line available today?](issues/06-description-meta-data.md) — brand name **available** (already fetched, currently only feeds the toolbar); colour name **available** via variant `optionValues`; the reference must be `ProductVariant.sku` because no reference/style-number field exists (`Product.styleNumber` is hardcoded `""` by the converter) — so the meta line ships as `Ref. <sku>`, not the Figma's `0273/393` format; description **available and already plain text** (HTML stripped in the converter), so dropping `TabControl` is pure view surgery. Findings: [research/06](research/06-description-meta-data.md).

## Not yet specified

- **The rest of the `Product Price` component.** The design's price component carries `Sales Price`, a second price, and a `Quantity/Volume/Others` label ("2 pc"). None is wired on PDP today; `variants.compareAtPrice` is already fetched so sale price is cheap, but the volume string has no identified source. Becomes specifiable once someone confirms which of these Alfie actually sells.
- **Category-driven size layouts.** The design has two further size variants — a card grid with per-variant imagery (food) and one with a sub-label plus price delta (dimensioned goods). `OmniProduct.productType` and `.categories` exist in the schema but are unselected, and no productType-to-layout mapping has been agreed. Deferred from ticket 03; becomes specifiable once someone owns that mapping.
- **Two inert affordances ship — decided: if the design has it, it stays.** The out-of-stock bell and the `Size Guide` link are both drawn by the design with nothing behind them. Both ship non-interactive (`.allowsHitTesting(false)`, no accessibility action); slices 4 and 5 make them live. Their intended behaviour is out with design and the team — see [to-questionnaire-pdp-control-behaviour.md](to-questionnaire-pdp-control-behaviour.md).
- **New L10n strings and AccessibilityIDs.** The design introduces at least "Select Your Size", "Size Guide", and a `Black | Ref. 0273/393` meta line; `AccessibilityID.ProductDetails` has 8 IDs today and no `.screen`. Which strings and IDs are needed can only be pinned once the size-selector and description-block decisions land.
- **iPad, and small-device CTA reachability.** Ticket 02 settled the iPhone case on a 16 Pro, but two questions it opened need answering before the branch is deleted: does `legacyPDPView` still have an iPad job to do, and does the CTA scroll off on a 667pt device (iPhone SE) such that variant B's sticky bar is needed after all? Both are cheap to check against the existing prototype branch.
- **Header treatment.** Figma's header carries a `Glass Effect` (`backdropFilter: blur(16px)`); the app uses `DefaultToolbarModifier` + `ThemedToolbarTitle(.text)`. Ticket 01 settled that the gallery does *not* run behind the header, so the blur has nothing to blur over on a static screen — whether it still ships (and whether a shared-toolbar change is in bounds) rides on how ticket 09 disposes of gap G5, since the token system has no effect tokens at all.
- **Description paragraph structure.** The converter strips HTML by collapsing block tags to spaces (`String+Extension.swift:29-48`), so multi-paragraph copy arrives as one run-on paragraph. The Figma draws a clean short paragraph. Whether this matters depends on the real product copy — revisit once ticket 01 fixes the description block's type style and line height.
- **Preview and fixture data for the new lines.** Domain fixtures default to an empty brand and colour name and a UUID SKU, `MockProductDetailsViewModel` has no colour/SKU property, and the PDP previews never set `productTitle` — so brand and the meta line render blank in previews. How much fixture work this needs is a ticket-07 question once the test strategy is chosen.
- **`AccessibilityID.ProductDetails.productTitle` naming collision.** `titleHeader` (`ProductDetailsView.swift:355`) renders `productName` under an ID called `productTitle`, while `productTitle` is the *brand* on the view model. Adding a visible brand line makes this actively misleading. Resolvable once the info-block structure is settled (tickets 01/04).
- **The Add to Bag button is now brand-driven, not permanently black.** Upstream repoints `button-primary-background` to `{colours-brand-500}`, and a `new-brand-theme` mode exists with a yellow ramp (`#FFD100`). Whether PDP's CTA must survive a brand switch — and what the wishlist button does alongside it — only becomes answerable once ticket 10 lands and ticket 02 fixes the CTA's position.
- **Splitting the deferred features into Jira.** The four out-of-scope items need new ALFMOB tickets under epic 427; their shape depends on what the spec says PDP will look like without them.

## Out of scope

- **"You might also like" recommendations grid** — **corrected**: an earlier note here claimed the BFF exposes no recommendations field. It does — `OmniProduct.relatedProducts: [String]` (`schema.graphqls:145`). It returns *IDs*, not products, so the grid needs the field selected plus a second fetch to resolve them, plus a card grid. Still out of scope for a restyle, but on effort grounds, **not** because it is backend-blocked.
- **Notify-me on out-of-stock sizes** (the bell glyph in the size grid) — new feature, no service behind it.
- **Size Guide content** — the link is drawn in the Figma but there is no size-guide data or destination in the app.
- **Inline accordion content** — the design has an `accordion-content` component set of **12 variants** (Cloth / Cosmetics / Home / Food × three accordions) with imagery and structured key/value copy, plus category-specific labels. No data path exists: `ProductDetailsFragment` selects no metafields and `OmniProduct.extensions: [Metafield]` needs a backend namespace/key contract. ALFMOB-441 ships the **shell** (`AccordionView`, honest expansion, today's three rows) per [ticket 05](issues/05-accordion-rows.md); the content ticket owns the metafield contract, the category-to-accordion mapping, in-panel image rendering, and the labels.
- **The Figma's literal `Ref. 0273/393` reference format** — no reference/style-number field exists on `OmniProduct` or `ProductVariant`; it would have to come from untyped metafields via the unused `productDetails(productMetafields:variantMetafields:)` args, which needs a backend key contract. PDP renders `Ref. <sku>` instead. Established by [ticket 06](issues/06-description-meta-data.md).
- **Dark mode** — explicitly deferred by ALFMOB-441.
