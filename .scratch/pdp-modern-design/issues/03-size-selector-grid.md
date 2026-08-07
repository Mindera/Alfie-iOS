# Decide the boxed size-grid selector, minus notify-me and size guide

Type: grilling
Status: resolved
Blocked by: —

## Question

The Figma replaces the current size control with a **wrapping grid of boxed size chips** (XS / S / M / L / XL), a "Select Your Size" label, and a "Size Guide" link on the right. Out-of-stock sizes are drawn greyed with a **bell** glyph — but notify-me and size-guide content are both out of scope for ALFMOB-441.

Decide:

- **Build vs. extend.** Does `SizingSelectorComponentView` (`Sources/SharedUI/Theme/Components/SizingBanner/`) stretch to a wrapping boxed grid, or does PDP get a new subview? PLP's convention was to avoid churning shared components for a restyle — which way does that cut here?
- **Out-of-stock rendering.** With notify-me out of scope, what does an unavailable size look like? Greyed and non-tappable, greyed with the bell drawn but inert, or hidden? The bell must not ship as a dead tap target.
- **The "Size Guide" link.** No size-guide destination exists. Omit it, or render it disabled? Omitting changes the row's layout balance — check that against the Figma.
- **What happens to the existing size sheet** (`ProductDetailsColorAndSizeSheet.swift`). The Figma's `Select a Size` bottom sheet (`#1:16489`) shows size + price rows with a drag indicator and no close button — is that sheet still reachable once sizes are a visible grid, or does the grid replace it entirely?
- **The single-size case.** `singleSizeView` (`:455-465`) currently concatenates `L10n.Product.Size.title + ":"` by hand, which is not localisation-safe. What does one-size look like in the new design?

Consult `/grilling` and `/domain-modeling`. Read ticket 01's token table first for the exact box dimensions, gaps, and border treatment.

## Answer

Checking the design rather than the single PDP frame changed the shape of this ticket. The canvas holds **eleven Size Selector frames** covering **four layouts**, and the long-size-run case is answered by a layout neither the ticket nor today's code has. Renders in `.scratch/figma-sizes/`.

### The four layouts

| Variant | For | Notes |
|---|---|---|
| **Chip grid** (`XS S M L XL`) | short size runs | the main PDP frame; PDP already renders `.grid(columns: 3)` |
| **Vertical list** | long runs (shoe sizes 2.5-6.5) | one full-width row per size, optional trailing price and stock text |
| Card grid + sub-label + price delta | dimensioned goods (`Small / 25x26x18 cm / -8EUR`) | **deferred** |
| Card grid + per-variant image | food | **deferred** |

### Decisions

1. **Build vs extend -> extend.** `SizingSelectorComponentView` already supports `.chips` and `.grid`, `SizingSwatch` already carries `.available` / `.outOfStock` / `.unavailable`, and **PDP is the only production consumer** of `SizingSelectorComponentView`, `SizingSwatchView` and `ColorAndSizingSelectorHeaderView` (the only other caller is `SizingBannerDemoView`). The usual "don't churn shared components in a restyle" caution does not bite here - blast radius is PDP plus one demo screen. Add a `.verticalList` case to `SwatchLayoutConfiguration.Arrangement` rather than writing a bespoke PDP view.

2. **Layout choice by size count, not category.** Ship the chip grid and the vertical list only, selected on the existing size-count threshold (`canShowSizePickers`, `ProductDetailsView.swift:40`) - chips when short, vertical list when long. **No schema change**: `OmniProduct.productType` and `.categories` exist but are unselected in `ProductDetailsFragment`, and no productType-to-layout mapping has been agreed. The two card-grid variants are deferred as category work.

3. **The >6 collapse-to-sheet dies.** Long size runs become the vertical list, inline. Combined with ticket 02 killing `popupView`, check whether `ProductDetailsColorAndSizeSheet`'s size half still has any caller - the colour half is still needed (ticket 04).

4. **Selected state is a black *border*, not a black fill.** Today `SizingSwatchView` fills `neutrals900` and inverts the label to `neutrals0` on selection. Every Figma variant keeps a white background and expresses selection with a heavier black border. This is a real behavioural change to the swatch, not a token swap.

5. **Chips are square.** Drop `Sizing.radiusSoft` - ticket 01 established radius 0 for size chips.

6. **Out of stock = strikethrough on the label + bell**, greyed. Replace `UnavailableCrossedOutShape` (the current diagonal slash across the whole chip) with a strikethrough on the text. The **bell ships as decorative and explicitly non-tappable** - `.allowsHitTesting(false)`, no accessibility action, not exposed as a button - since notify-me is out of scope. Recorded as a knowingly inert affordance; the follow-up notify-me ticket makes it live.

7. **Per-size price and low-stock messaging are in.** `ProductDetailsFragment` already selects `variants.price` and `variants.inventory.available`, so both are buildable with no BFF work. Needs new L10n strings for "Only 1 item left!" and "Last units", and a **threshold rule** - the spec states an assumption for design to confirm rather than inventing one silently.

8. **Header: follow the design.** "Select a Size" on the left, "Size Guide" link on the right. Today's `ColorAndSizingSelectorHeaderView` renders `Size: M v`, a different shape. Extend it with a title-plus-optional-trailing-link mode so the colour and size headers stay one component. The "Size Guide" link has no destination (out of scope), so it renders **disabled/inert** on the same footing as the bell - flag to design that it is drawn but not wired.

9. **The default chip border is `#CDCDCD`** - blocked on the `border-strong` token request. The current component uses `neutrals900` (black) for the available border, so this is a visible change, not a no-op. See [token-requests.md](../token-requests.md).

10. **`singleSizeView` is replaced**, removing the `L10n.Product.Size.title + ":"` hand-concatenation.

### Open, recorded as an assumption

The "Last units" / "Only 1 item left!" threshold. The spec proposes `available == 1` -> "Only 1 item left!", `available <= N` -> "Last units", with N stated for design to confirm.

## Amendment (re-grill, 2026-08-07)

**Both non-functional controls ship.** An earlier recommendation was to omit the `Size Guide` link because it has no destination. Overruled: **if the design has it, it stays.** So the size section ships:

- the **bell** on out-of-stock sizes — decorative, `.allowsHitTesting(false)`, no accessibility action;
- the **`Size Guide` link** — rendered as drawn, also non-interactive, on the same footing.

Their intended behaviour is being put to design and the team via the questionnaire at `.scratch/pdp-modern-design/to-questionnaire-pdp-control-behaviour.md`. If design rules that a visible-but-dead link is unacceptable, this flips back to omission — one line in the spec.
