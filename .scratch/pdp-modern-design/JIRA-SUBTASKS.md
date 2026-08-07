# ALFMOB-441 subtasks — ready to paste into Jira

Create each as a **Subtask** of [ALFMOB-441](https://mindera.atlassian.net/browse/ALFMOB-441), in the order below.

Jira MCP writes are blocked for this site (`Access denied ... must authorize access ... to cloudId`), so these need creating by hand or by an admin unblocking the connector.


---


## Summary

```
[iOS] PDP — Foundation: single-scroll layout and token migration
```

**Issue type:** Subtask · **Parent:** ALFMOB-441 · **Blocked by:** None · **Labels:** `design-system`, `ready-for-agent`

**Description** (paste below):

```markdown
**What to build:** Product Details becomes one continuously scrolling page. The bottom sheet that currently floats the product information over the imagery is removed, and _Add to Bag_ moves to sit directly beneath the price. At the same time the whole screen stops using legacy styling primitives and binds to the design tokens, so no visible styling value on this screen is hardcoded any more.

Nothing else about the screen's appearance changes yet — sections keep their current internal layout. A shopper should notice one thing: the page no longer has a sheet.

This ticket also lays the groundwork the later tickets depend on. It introduces the single place where every layout and appearance rule lives (which size layout for a given size count, which colour surface for a given colour count, which low-stock message for a given stock level, and which appearance a size swatch takes per state), exposes the medium-bold type style the price needs, and gives the mock product view-model real brand, colour-name and reference values so later tickets can assert on content that is currently blank.



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
```


---


## Summary

```
[iOS] PDP — Gallery and product information block
```

**Issue type:** Subtask · **Parent:** ALFMOB-441 · **Blocked by:** Subtask 1 · **Labels:** `design-system`, `ready-for-agent`

**Description** (paste below):

```markdown
**What to build:** The top of the page matches the design. Product imagery spans the full width of the screen with no padding and no rounded corners, in a 3:4 ratio, stopping short of the navigation header. Pagination indicators sit over the bottom of the image rather than below it, with the current image marked by a wider pill.

Beneath the gallery, the information block gains the brand name as its own smaller, lighter line above the product name, and the price renders in the medium-bold style. When a product comes in more than one colour, a compact summary — the selected swatch plus a count of the others — appears at the trailing edge of that block and is tappable.



- [ ] The gallery is full-width, square-cornered, and uses a 3:4 ratio
- [ ] The gallery does not render behind the navigation header
- [ ] Pagination indicators are overlaid near the bottom of the image; the selected indicator is a wider pill
- [ ] The brand name renders above the product name in the smaller label style
- [ ] The price renders in the medium-bold body style
- [ ] The colour summary shows the selected swatch and the remaining count, and is hidden for single-colour and no-colour products
- [ ] Tapping the colour summary opens colour selection
- [ ] Accessibility identifiers exist for the brand line and colour summary, and the existing collision — where the product name carries an identifier named for the brand — is resolved
- [ ] Snapshot baselines updated
- [ ] `./Alfie/scripts/verify.sh` passes

**Note.** The brand line's colour depends on a semantic token that does not yet exist upstream. Until it lands the line renders at primary weight, flattening the intended hierarchy against the product name. Ship anyway and correct when the token arrives.

Detail: `Docs/Specs/Features/ProductDetailsModernDesign.md`
```


---


## Summary

```
[iOS] PDP — Size selector: grid, vertical list and stock states
```

**Issue type:** Subtask · **Parent:** ALFMOB-441 · **Blocked by:** Subtask 1 · **Labels:** `design-system`, `ready-for-agent`

**Description** (paste below):

```markdown
**What to build:** A shopper can see every size a product comes in without opening anything. Products with a short size run show all sizes at once as boxed square chips in a grid; products with a long run (shoe sizes, for instance) show one full-width row per size, each able to carry its own price.

Selecting a size marks it with a heavier border rather than filling it. Sizes that cannot be bought are dimmed with their label struck through and a bell shown alongside — the bell is decoration in this ticket, not a control. Sizes running low carry a short message at the trailing edge.

The section is headed by its title on the left and a _Size Guide_ link on the right. That link has no destination yet, so it renders inert.

The size sheet is retired: long size runs are handled inline by the vertical list.



- [ ] Short size runs render as a grid of boxed square chips
- [ ] Long size runs render as a vertical list, with per-size price where available
- [ ] Which layout appears is decided by the shared rules type, not by logic inline in the view
- [ ] Selection is indicated by a heavier border, not by filling the chip
- [ ] Out-of-stock sizes are dimmed with a struck-through label and a bell indicator, and cannot be selected
- [ ] The bell exposes no tap target and no accessibility action, asserted by test
- [ ] The _Size Guide_ link renders as designed and is likewise inert, asserted by test
- [ ] Low-stock messaging appears at the defined thresholds
- [ ] The one-size case renders without the grid, and without the previous hand-assembled label
- [ ] The size sheet no longer has a caller
- [ ] New strings added to the string catalogue and the SwiftGen checksum regenerated
- [ ] Snapshot baselines updated
- [ ] `./Alfie/scripts/verify.sh` passes

**Notes.** The shared sizing components are consumed only by Product Details and one debug demo, so extending them is low-risk — add a vertical-list arrangement rather than building a bespoke view.

The chip border colour depends on a semantic token that does not yet exist upstream; until it lands, borders render lighter than designed.

Four rules here are inferences from static design frames rather than design instructions — the size-count threshold, the low-stock thresholds and their wording. They live in the shared rules type so they are cheap to correct once design confirms.

Detail: `Docs/Specs/Features/ProductDetailsModernDesign.md`
```


---


## Summary

```
[iOS] PDP — Colour selection
```

**Issue type:** Subtask · **Parent:** ALFMOB-441 · **Blocked by:** Subtask 1 · **Labels:** `design-system`, `ready-for-agent`

**Description** (paste below):

```markdown
**What to build:** A shopper choosing a colour sees the options without losing their place. Products with a small number of colours show them inline as a card grid — swatch above colour name — between the call-to-action and the description. Products with many colours open a sheet listing them.

The selected colour is marked with a border on its swatch. The previous inline swatch row and its accompanying picker are no longer used on this screen.



- [ ] Few-colour products show an inline colour card grid
- [ ] Many-colour products open a colour sheet
- [ ] Which surface appears is decided by the shared rules type
- [ ] The selected colour is indicated by a border on its swatch
- [ ] Single-colour and no-colour products show no colour section at all
- [ ] The colour sheet is restyled to the design and rebuilt on the shared modal component rather than its current hand-rolled header and rows
- [ ] The hardcoded font-size override in the sheet is removed
- [ ] The fallback swatch colour for invalid swatch images comes from a design token, and its pinning test is updated accordingly
- [ ] Snapshot baselines updated
- [ ] `./Alfie/scripts/verify.sh` passes

**Note.** When each of the three colour surfaces appears is an inference, not a design instruction — the design shows all three but never says which applies when. The assumption mirrors the size rule and lives in the shared rules type.

Detail: `Docs/Specs/Features/ProductDetailsModernDesign.md`
```


---


## Summary

```
[iOS] PDP — Description, product reference and accordion rows
```

**Issue type:** Subtask · **Parent:** ALFMOB-441 · **Blocked by:** Subtask 1 · **Labels:** `design-system`, `ready-for-agent`

**Description** (paste below):

```markdown
**What to build:** The product description reads as plain body text rather than sitting behind a tab control. Beneath it, a metadata line shows the selected colour name and the product reference; when either is unavailable that part is omitted rather than rendering blank.

Below that, the complementary information rows — delivery, payment options and returns — become genuine accordions built on the shared accordion component. Each row shows an expand indicator, and tapping it expands the row in place to reveal a link through to the corresponding information, instead of navigating away immediately.



- [ ] The description renders as plain body text and the tab control is gone
- [ ] A metadata line shows the selected colour name and product reference, degrading gracefully when either is missing
- [ ] Complementary information rows use the shared accordion component, replacing the bespoke row
- [ ] Tapping a row expands it in place; the expanded panel offers a link to the existing information
- [ ] The shared accordion component is migrated to design tokens
- [ ] Row titles and their destinations are unchanged from today
- [ ] Dead constants left behind by the removed bespoke row are deleted
- [ ] New strings added to the string catalogue and the SwiftGen checksum regenerated
- [ ] Snapshot baselines updated
- [ ] `./Alfie/scripts/verify.sh` passes

**Notes.** The shared accordion component is currently used only by a debug demo, so migrating it is low-risk — but confirm that before editing.

Embedding the web content directly inside the expanded panel was considered and rejected: a web view inside a disclosure group inside a scroll view brings nested scrolling and indeterminate height, on a screen that already carries an image carousel.

Whether the row should expand to a link at all, rather than keeping today's single-tap navigation, is out with design — it trades a one-tap journey for two. If design prefers navigation, this ticket becomes a restyle of the existing row.

The product reference is the variant SKU; the design's exact reference format has no field behind it.

Detail: `Docs/Specs/Features/ProductDetailsModernDesign.md`
```


---


## Also do on ALFMOB-441 itself

**Amend this acceptance criterion** — it cannot be met as written:

> ~~Snapshot baselines regenerated and passing.~~
> Snapshot baselines **added** and passing, plus unit tests covering size and colour state mapping.

PDP has no snapshot tests today, so there are no baselines to regenerate.

**Add this comment:**

```
Implementation spec: Docs/Specs/Features/ProductDetailsModernDesign.md

Broken into 5 subtasks. Subtask 1 must land first (it removes the bottom sheet,
migrates the screen to design tokens, and adds the shared layout-rules type and
test fixtures the others assert against). Subtasks 2-5 are mutually independent.

Two dependencies outside this ticket:
- The design-token refresh PR must merge first (adds the body/medium-bold type
  style the price needs).
- Two semantic tokens are missing upstream in Alfie-Mobile-Design-Tokens:
  a strong border alias (#CDCDCD) and a secondary content alias (#2B2B2B).
  Until they land, size-chip borders and the brand name line ship off-design.

Scope note: this ticket does NOT make PDP match the Figma frame. Deferred to
separate tickets under ALFMOB-427, each blocked for its own reason:
- Recommendations grid (~bottom third of the design) - related products are
  exposed as IDs only, and the "Best Seller" badge has no data source
- Rich in-panel accordion content - needs a metafield contract from backend
- Notify-me (the out-of-stock bell) - no service exists
- Size guide - no content or destination exists
- Category-driven size layouts - no category-to-layout mapping agreed

Four behaviour rules in the spec are inferences from static Figma frames rather
than design instructions, and are out with design for confirmation. All four
live in one type so corrections are a single-file change.
```
