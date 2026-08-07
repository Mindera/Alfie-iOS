# Write the ALFMOB-441 implementation spec

Type: task
Status: resolved
Blocked by: 02, 03, 04, 05, 07, 10

## Question

Nothing left to decide — assemble the decisions into the spec this map exists to produce.

Write it to `Docs/Specs/Features/ProductDetailsModernDesign.md` following `Docs/Specs/TEMPLATE.md`, covering:

- The final screen structure, section by section, with the token values from ticket 01 inline.
- A file-by-file change list across `Sources/ProductDetails/` — following the PLP diff shape (`9ae85bc`), not Home's.
- Every `Primitives.*` → `Theme.*` / `theme.spacing.*` / `theme.radius.*` substitution, so the mechanical pass is unambiguous (~41 sites in `ProductDetailsView.swift`, ~14 in `ProductDetailsColorAndSizeSheet.swift`, one in the view model at `:311`). Include the deletions: the `withSize(18)` font override in the sheet (`:47`), the dead `Constants` (`sheetCloseIconSize`, `colorChevronSize`), and whatever ticket 02 kills.
- New L10n strings and `AccessibilityID.ProductDetails` entries (graduated from the map's "Not yet specified").
- The test plan from ticket 07, and whether ALFMOB-441's AC needs amending.
- Explicit non-goals, mirroring the map's Out of scope section.

Then raise the deferred work as new ALFMOB tickets under epic [ALFMOB-427](https://mindera.atlassian.net/browse/ALFMOB-427): recommendations grid (needs BFF), notify-me, size guide, inline accordion content. Each should link back to this spec for the boundary.

Deliverable: the spec file, the new Jira tickets, and a comment on [ALFMOB-441](https://mindera.atlassian.net/browse/ALFMOB-441) pointing at the spec and naming the descoped items.

## Known required changes discovered while working other tickets

- **`TypographyBody` must expose `mediumBold`.** Ticket 10's refresh generated `Typography.Body.mediumBold`, but the hand-written provider struct `Sources/SharedUI/Theme/Typography/Specifications/TypographyGroups.swift:48-65` does not surface it, so `theme.font.body.mediumBold` does not compile. Add it mirroring the existing `TypographyLabel.smallBold` pattern (a stored `let` plus an `init` parameter defaulting to `.init(style: Typography.Body.mediumBold)`). Needed by the PDP price.
- **Every section of the spec must name the SharedUI component it uses**, or state explicitly why nothing in `Sources/SharedUI` fits and a bespoke view is justified. Reuse is the default; bespoke is the exception that needs a reason. See the component inventory in the map's Notes.

## Answer

Spec written to `Docs/Specs/Features/ProductDetailsModernDesign.md`, following `Docs/Specs/TEMPLATE.md`.

**Seams confirmed with the user before writing — two only:**
1. *Existing* — the product details view-model protocol and its mock, which the whole screen is already driven through.
2. *New* — `ProductDetailsLayoutRules`, one pure type holding the size-layout, colour-layout and low-stock rules, so every threshold design may revise lives in one testable file rather than three scattered extractions.

**Verification: both**, per the user — unit tests carry the primary assertions (layout selection, swatch state mapping, and that the bell and Size Guide expose no tap target), with two snapshots (default, error) as a regression net.

**Ticket shape: slice 1 stays a single ticket** per the user ("all the preparation in 1 ticket"), including the typography-provider addition, fixture work, the `AccordionView` token migration and the `.verticalList` arrangement. A commit order is suggested inside the ticket so review has a spine. The token refresh remains a separate PR ahead of it.

**Four assumptions are written as open questions**, not silently baked in — the colour-surface rule, the size threshold, the low-stock N, and the accordion affordance. All four resolve inside `ProductDetailsLayoutRules`, so correcting them after design answers is a one-file change.

### Still outstanding — needs a human

- **The Jira tickets have not been created.** Slices 2-6 are written up in `slices/` but not raised under ALFMOB-427, and no comment has been posted on ALFMOB-441. Outward-facing, so left for the user.
- **The upstream token PR (slice 0b) has no owner.** Two one-line aliases in `Mindera/Alfie-Mobile-Design-Tokens`; without them two elements ship off-design.
- **The token refresh is uncommitted** on `claude/wayfinder-skills-alfmob-441-88422c` (8 files, verified passing).
- **ALFMOB-441's acceptance criteria need amending** — "snapshot baselines regenerated" is unmeetable; there are none.
