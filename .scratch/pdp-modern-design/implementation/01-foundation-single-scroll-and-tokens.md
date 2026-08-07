# 01 — Foundation: single-scroll layout and design-token migration

**What to build:** Product Details becomes one continuously scrolling page. The bottom sheet that currently floats the product information over the imagery is removed, and _Add to Bag_ moves to sit directly beneath the price. At the same time the whole screen stops using legacy styling primitives and binds to the design tokens, so no visible styling value on this screen is hardcoded any more.

Nothing else about the screen's appearance changes yet — sections keep their current internal layout. A shopper should notice one thing: the page no longer has a sheet.

This ticket also lays the groundwork the later tickets depend on. It introduces the single place where every layout and appearance rule lives (which size layout for a given size count, which colour surface for a given colour count, which low-stock message for a given stock level, and which appearance a size swatch takes per state), exposes the medium-bold type style the price needs, and gives the mock product view-model real brand, colour-name and reference values so later tickets can assert on content that is currently blank.

**Blocked by:** None — can start immediately, once the design-token refresh PR has merged.

**Status:** ready-for-agent

- [ ] Product Details renders as a single scroll with no sheet presented over the gallery
- [ ] _Add to Bag_ and the wishlist button appear directly beneath the price and scroll with the page
- [ ] The detent calculation, detent state and the content measurement that fed them are removed
- [ ] The pre-iOS-16.4 and iPad paths are reconciled — either collapsed into the single scroll or explicitly retained with a stated reason
- [ ] No legacy styling primitive references remain in the Product Details module
- [ ] Corner radii follow the design: square for the call-to-action and wishlist button, rounded only for pagination indicators
- [ ] The medium-bold body type style is available from the typography provider and used by the price
- [ ] A single type holds the size-layout, colour-layout, low-stock-message and swatch-appearance rules, covered by unit tests including nil and zero stock
- [ ] The mock product view-model exposes selected colour name and product reference, and fixtures provide real values rather than empty strings and generated identifiers
- [ ] Snapshot coverage is established for the default and error states — this is the first point at which the screen is capturable
- [ ] All existing product view-model tests pass, except the swatch-fallback colour test which is updated for the token migration
- [ ] `./Alfie/scripts/verify.sh` passes

**Notes.** The call-to-action's reachability was validated on a large device with short copy. Before raising the PR, re-check it on a small device and with a long-description product; a sticky-call-to-action variant was prototyped, rejected on the large device, and preserved on a throwaway branch if the small-device case needs it.

Detail: `Docs/Specs/Features/ProductDetailsModernDesign.md`
