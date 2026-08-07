# Decide the collapsed colour representation (swatch + "+3")

Type: grilling
Status: resolved
Blocked by: —

## Question

The Figma collapses colour selection to a small **swatch plus a `+3` count**, sitting top-right of the price block. Today PDP renders a full horizontal `ColorSelectorComponentView` swatch row plus a `PickerMenu` showing the selected colour name.

Decide:

- **What the collapsed control is.** Selected swatch + remaining count, or selected swatch + name + count? The Figma render is small — verify against ticket 01's extraction.
- **What tapping it does.** The existing colour sheet (`ProductDetailsColorAndSizeSheet.swift`, searchable colour list) already exists and is the obvious destination — confirm that's the intent rather than an inline expansion.
- **Whether `ColorSelectorComponentView` and `PickerMenu` still have a caller on this screen**, and if not, whether they are left alone (other screens may use them) or the PDP usage is simply dropped.
- **Single-colour and no-colour products.** What renders when there is nothing to expand?
- **The invalid-swatch fallback.** `ProductDetailsViewModel.swift:311` hardcodes `Primitives.Colours.neutrals900` as the fallback swatch colour, and a test pins it (`test_color_selection_swatch_is_black_by_default_for_invalid_swatch_urls`). Does this become a `Theme.*` token, and does the test change with it?
- **Where the colour name goes.** The Figma's description block carries a `Black | Ref. 0273/393` meta line — is that where the selected colour name now lives? Cross-check with ticket 06.

Consult `/grilling` and `/domain-modeling`.

## Answer

**The ticket's premise was wrong.** It assumed the design collapses colour to a "+3" chip that replaces the swatch row. Checking the canvas (`PDP - Colors` `#316:96814`, `Color Selector` `#316:96563`, renders in `.scratch/figma-colors/`) shows **three** colour representations, and the resolution is to mirror the size pattern from [ticket 03](03-size-selector-grid.md).

### The three representations

| Where | What it is |
|---|---|
| Info block, top-right | `Product Colors Selector` (`725:11683`) — a 24x24 `.color-swatch` + a `+N` text (`Number of Colours` property), visibility bound to a `Show Colour` toggle |
| Between the CTA and the description | **`Select a Colour` card grid** — swatch above colour name, 3 across, selection = black border |
| Bottom sheet | `Select a Colour` list — colour name left, swatch right, one row per colour |

### Decisions

1. **Mirror the size pattern.** The `+N` summary stays in the info block and is **tappable**; the inline card grid renders when there are few colours; the bottom-sheet list takes over when there are many — the same count-driven rule ticket 03 set for sizes. Keeps the two selectors symmetric and reuses `ColorSelectorComponentView` the way `SizingSelectorComponentView` is being extended.

2. **Selection is a black border**, consistent with the size chips — and consistent with today's `ColorSwatchView`, which already strokes `neutrals900` when selected (`ColorSwatchView.swift:30`). Migrate that to `Theme.*`; no behavioural change needed here, unlike the size swatch.

3. **The `+N` summary is a new small view** — a `ColorSwatchView` at 24pt plus a `body/medium` count. Nothing in SharedUI covers it; this is a justified bespoke addition, and it belongs next to the colour components rather than inline in `ProductDetailsView`.

4. **`PickerMenu` loses its PDP caller.** Today the colour row is `ColorAndSizingSelectorHeaderView` + `PickerMenu` showing the colour name. Under the new design the name appears in the card grid and in the description meta line instead. `PickerMenu` is left in place untouched — check for other callers before assuming it is dead.

5. **The colour sheet survives**, unlike the size sheet. Ticket 03 kills the size half of `ProductDetailsColorAndSizeSheet` (long size runs become an inline vertical list); the colour half is still the many-colours case. The shared sheet file therefore needs restyling rather than deleting, and its bespoke header and rows should move onto `ThemedModal` per the SharedUI reuse rule.

6. **The invalid-swatch fallback** at `ProductDetailsViewModel.swift:311` (`Primitives.Colours.neutrals900`) becomes `Theme.*`. The pinning test `test_color_selection_swatch_is_black_by_default_for_invalid_swatch_urls` changes with it — it asserts a colour identity, so swapping the constant is safe as long as the token resolves to the same value.

7. **Single-colour and no-colour products**: the `Show Colour` component property confirms the whole colour section is independently hideable. Reuse the existing `hideOnSingleColor` flag on `SwatchLayoutConfiguration`.

### Values confirmed first-hand

- **Brand name `#2B2B2B` at `label/small` (12/16)** — independent confirmation of gap G2 in [token-requests.md](../token-requests.md).
- Product name `body/medium` `#111111`; price **`body/medium-bold`** `#111111` (the style ticket 10 pulled in).
- **Wishlist button 40x40, transparent fill, `#06080A` stroke** — exactly `Theme.buttonSecondaryStrokeSecondaryDefault` (`neutrals900`). No gap; use the existing secondary-button tokens rather than a bespoke frame.
- Add to Bag: `#111111` fill and stroke, `#FFFFFF` `body/medium` label, 8x16 padding.

### Scope

**Price: restyle only what PDP renders today.** Apply tokens and `body.mediumBold` to the existing `PriceComponentView` usage. The design's `Sales Price`, second-price and `Quantity/Volume/Others` ("2 pc") variants are **not** wired on PDP today and are recorded as fog for a separate ticket.
