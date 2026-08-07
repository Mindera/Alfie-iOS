# Prototype the inline Add-to-Bag layout that replaces the bottom sheet

Type: prototype
Status: resolved
Blocked by: —

## Question

Does the Figma's page structure — gallery, then brand/name/price, then **Add to Bag + wishlist inline directly under the price**, then size selector, then description, then accordions — actually work as a single scroll, and what happens to the bottom-sheet machinery it replaces?

This is the riskiest change in the story. Today `ProductDetailsView.swift` branches: on iOS 16.4+ the CTA lives in `popupView` presented as a `.sheet` with detents computed from measured content (`setupDetents`, `:186-196`); otherwise `legacyPDPView` scrolls. The Figma shows no sheet at all.

Build a throwaway prototype against `MockProductDetailsViewModel` (`Sources/Mocks/Core/Features/MockProductDetailsViewModel.swift`) — use `/prototype`, keep it out of the production target — that answers:

- Does the CTA still feel reachable when it scrolls away, or does the design imply a pinned/sticky bottom bar that the static Figma frame doesn't show?
- Can `setupDetents` and the whole `.sheet` path be deleted outright, or does something else depend on the measured heights?
- What replaces the `TabControl` description tab (Figma shows a plain text block plus a meta line)?
- Does removing the sheet make the screen snapshot-testable in a hosting controller? Today the interesting content is inside a `.sheet` and never renders in a snapshot — this is the blocker for the AC's "regenerate snapshot baselines".

Deliverable: a prototype to react to, linked from this ticket, and a recorded decision on whether the sheet path dies in ALFMOB-441.

## Answer

**Variant A wins: the CTA goes inline under the price, and the bottom-sheet machinery dies.**

Prototype: branch `prototype/pdp-inline-cta`, commit `27dd689` — `Sources/DebugMenu/UI/Demo/PDPLayoutPrototype/PDPLayoutPrototypeView.swift`, reachable from three Debug Menu rows (A/B/C). Built and driven on an iPhone 16 Pro simulator against stub data. Not on the working branch.

### The decisive finding

**The PDP is short.** Everything below the gallery — info block, CTA, size grid, description, three accordions — fits in a single screenful. Scrolled to the very bottom of variant B, the inline Add to Bag was **still on screen**, so B's sticky bar never triggered at all. The fear that motivated this ticket (a CTA that scrolls away and becomes unreachable) does not materialise on this content.

So the sticky bar is dead weight: it adds a `GeometryReader` + `PreferenceKey` + animation for a state the layout never reaches. Ship A.

### What dies

- The `.sheet(isPresented: $showDetailsSheet)` wrapper and `popupView` (`ProductDetailsView.swift:151-164`, `:255-274`).
- `setupDetents(with:)` (`:186-196`) and the `bottomSheetDetents` / `bottomSheetCurrentDetent` state.
- The `carouselSize` / `tabBarSize` measurement (`.writingSize(to:)` on the carousel) that existed only to feed the detent arithmetic.
- The iOS 16.4-vs-legacy branch: with no sheet, `legacyPDPView` and the modern path converge on one scroll. **Confirm against iPad before deleting** — the iPad path shares `legacyPDPView`.
- The `TabControl` description tab, replaced by a plain text block plus the meta line. Verified in the prototype; reads fine.

### Consequence for ticket 07

With no `.sheet`, the whole screen renders in a hosting controller, so **PDP becomes snapshot-testable**. That was the blocker on the AC's "regenerate snapshot baselines". Ticket 07 is unblocked.

### Caveats — do not treat as settled

- **Measured on iPhone 16 Pro only (874pt tall).** On a 667pt iPhone SE the CTA very likely *does* scroll off. The sticky-bar logic from variant B should be re-tested there before being discarded outright; keep the branch around for that.
- **Long content changes the answer.** The stub description is four lines. A product with long copy, many sizes, or an expanded accordion pushes the CTA off screen. Worth checking against a real long-description product once the view model is wired.
- Variant C (sheet retained) was built and is reachable but was not visually inspected in this session — it represents today's behaviour, which is already known.
- The two greys in the prototype are placeholders, not the design (see [token-requests.md](../token-requests.md)).

### Prototype-chrome note

An in-view variant switcher (floating bar, then a segmented `Picker`) rendered correctly but received **no touch events** in either form, while the `ScrollView` beneath it did. Not worth diagnosing in throwaway code — selection moved to three separate Debug Menu rows. If a future prototype wants an in-place switcher in this app, expect that hit-testing quirk.
