# Resolve the accordion conflict: "+" affordance vs. web navigation

Type: grilling
Status: resolved
Blocked by: —

## Question

The Figma draws "Size & Fit", "Materials & Care Guide" and "Shippings and Returns" as **accordions with a `+` / `−` affordance that expand in place**, revealing rich content including imagery (see `.scratch/figma/pdp-ios-s-a.png`, where "Care Guide" is open).

Today those are `complementaryInfoCell` (`ProductDetailsView.swift:545-580`) — a bespoke row with a **chevron-right** that **navigates to a web view** (`ProductDetailsComplementaryInfoType` = `.delivery` / `.paymentOptions` / `.returns`).

Inline accordion content is out of scope (it's a content-source change, not a restyle). So this ticket decides the compromise:

- **Which affordance ships.** A `+` that navigates away is a lie to the user; a chevron that doesn't match the Figma is a knowing deviation. Pick one and record why.
- **Whether `AccordionView` gets used at all.** `Sources/SharedUI/Theme/Accordion/AccordionView.swift` exists, is unused by PDP, and is itself still on legacy `Primitives.*` — adopting it means restyling a shared component too. Does that belong in this story, or does PDP keep a bespoke row that merely looks right?
- **The row set.** The Figma names three sections that do not line up with the three `ProductDetailsComplementaryInfoType` cases. Do the labels change, does the set change, or is the mismatch just mock data in the design?
- **What the deferred inline-content ticket needs to say**, so it can be raised against epic 427 with a clear boundary against this one.

Consult `/grilling`. Note the row is also the screen's clearest consolidation target — see the bespoke-vs-shared inventory in the map notes.

## Answer

**Adopt `AccordionView` as the row shell so the `+`/`-` affordance is honest, with the existing complementary info reachable from inside the expanded panel.** Keep today's three row types and their labels.

### What the design actually specifies

Renders in `.scratch/figma-accordion/`. The accordions expand **in place** with genuinely rich content — full-bleed imagery and structured key/value copy (`Outer Shell / 100% Cotton`, `Secondary Fabric / 95% Cotton, 5% Elastane`). There is an `accordion-content` **component set with 12 variants**: Cloth / Cosmetics / Home / Food x three accordions, with category-specific labels (`Materials`, `Care Guide`, `Ingredients`, `Shipping & Payments`, `Size & Fit`).

That is a content platform, not a restyle. No data path exists: `ProductDetailsFragment` selects no metafields, and the only schema hatch (`OmniProduct.extensions: [Metafield]`) needs a backend namespace/key contract. Confirmed out of scope; the follow-up ticket owns it.

### Decisions

1. **Use `AccordionView`** (`Sources/SharedUI/Theme/Accordion/AccordionView.swift`) instead of the bespoke `complementaryInfoCell` (`ProductDetailsView.swift:545-580`). It is `DisclosureGroup`-based and takes arbitrary `content`, so it already draws the `+`/`-` and the enclosing hairlines, and the real panels drop in later without another rewrite. This satisfies the SharedUI reuse rule and removes a bespoke view.

2. **`AccordionView` must be migrated to `Theme.*` as part of this work.** It is currently on legacy `Primitives.Colours.neutrals800/600/500/200` and `Primitives.Spacing.spacing12/16`. This is a shared component, so it is a wider blast radius than the sizing components — **check for other callers before editing**; the map notes it as unused by PDP today, which suggests few or none.

3. **Row set unchanged.** `ProductDetailsComplementaryInfoType` keeps `.delivery` / `.paymentOptions` / `.returns` and their existing `L10n.Pdp.ComplementaryInfo.*` labels. The design's labels are category content arriving with the content ticket; renaming rows now would misdescribe what they actually open.

### The problem with embedding the web content, and what to build instead

The chosen option was "web content inside the panel". Taken literally that means hosting the web feature — `viewModel.openWebFeature(feature)` pushes a full `ProductDetailsRoute.webFeature` route backed by a web view — **inside a `DisclosureGroup` inside a `ScrollView`**. That is a bad build: nested scrolling, indeterminate intrinsic height, and a web view instantiated per row on a screen that already has a carousel. **Rejected.**

**Build instead:** the expanded panel contains a single link row — `theme.font.link.medium(_, underline: true)` on `Theme.linkLinkPrimaryDefault` — that opens the existing web feature via the current navigation path. The row genuinely expands (affordance honest, matches the design's interaction), the content stays where it already works, and the panel is the exact slot the real content fills later.

If that reads as too thin a payoff for a tap, the fallback is the chevron-navigation option — say so and this flips.

### Incidental cleanups this triggers

- The cell's `showDetailsSheet = false` and `bottomSheetDetentBeforeNavigation = bottomSheetCurrentDetent` lines die with the sheet ([ticket 02](02-inline-cta-layout.md)).
- `Constants.chevronSize` and `Constants.complementaryInfoCellMinHeight` go with the bespoke cell; `Constants.colorChevronSize` was already dead.
- The `Icon.chevronRight` template image currently uses `.foregroundStyle` correctly — no `.tint` bug here.

### Note for the deferred content ticket

The boundary is clean: this ticket ships the **shell** (`AccordionView`, honest expansion, three known rows). The content ticket owns the metafield contract, the category-to-accordion mapping (12 variants), image rendering inside a panel, and the category-specific labels.
