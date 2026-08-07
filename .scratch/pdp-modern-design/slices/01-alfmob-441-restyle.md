# Slice 1 — ALFMOB-441: PDP restyle and layout

**Ticket:** [ALFMOB-441](https://mindera.atlassian.net/browse/ALFMOB-441) · **Epic:** ALFMOB-427
**Blocked by:** Slice 0 (hard) · Slice 0b (soft — ships without it, two elements off-design)

## Scope

The full visual and layout rollout, using today's data and behaviour.

- **Gallery** — 3:4, horizontally full-bleed, *not* behind the header; pagination dots overlaid 12pt above the bottom (selected 12×6 pill).
- **Info block** — brand line, product name, price (`body.mediumBold`), and the tappable `+N` colour summary top-right.
- **Add to Bag + wishlist inline directly under the price.** **Deletes the bottom sheet**: `popupView`, `setupDetents`, the detent state, and the carousel/tab-bar measurement that fed it. Wishlist button is 40×40 using the existing secondary-button tokens.
- **Size selector** — extend `SizingSelectorComponentView` with a `.verticalList` arrangement; chip grid for short size runs, vertical list for long ones, chosen on the existing size-count threshold. **Removes the >6 collapse-to-sheet.** Selection becomes a black *border* (not today's black fill); chips are square; out-of-stock becomes a label strikethrough plus a **decorative, non-tappable** bell. `Size Guide` link rendered, also non-interactive. Per-size price and low-stock text included.
- **Colour selector** — `+N` summary, inline card grid for few colours, sheet for many. The colour sheet survives and is restyled onto `ThemedModal`.
- **Description** — plain text block replacing the `TabControl`, plus the `Black | Ref. <sku>` meta line.
- **Accordion rows** — replace bespoke `complementaryInfoCell` with `AccordionView`; panel holds a link to the existing web feature. `AccordionView` migrates to `Theme.*` (only caller today is a DebugMenu demo).
- **Token migration** — ~41 sites in `ProductDetailsView.swift`, ~14 in `ProductDetailsColorAndSizeSheet.swift`, one in the view model (`:311`). Delete the `withSize(18)` override and dead `Constants`.

## Out of scope

Slices 2–6. After this ships the screen will **not** match the Figma screenshot: no recommendations grid, no working bell, no size-guide destination, no rich accordion content.

## Blockers

- **Hard:** Slice 0.
- **Soft:** Slice 0b — without it, size-chip borders and the brand line are off-design.

## Open questions (`.scratch/pdp-modern-design/to-questionnaire-pdp-control-behaviour.md`)

Answers change the build; none of them block starting the token migration.

- **Colour UI rule** — when does the `+N` summary vs inline grid vs sheet appear? *Currently our inference, not a design instruction.*
- **Size grid vs list threshold** — is there an intended cut-off?
- **Low-stock wording rule** — what is N for "Last units" vs "Only 1 item left!"?
- **Accordion affordance** — expand-to-a-link, or keep one-tap navigation?
- **`Size Guide` and bell** — confirmed shipping non-interactive; design to confirm that is acceptable.

## Verification — decided

**Both style unit tests and snapshots.** Full detail in `.scratch/pdp-modern-design/issues/07-test-strategy.md`. The AC as written ("snapshot baselines regenerated") cannot be met literally: PDP has no snapshot tests. Deleting the sheet makes the screen snapshot-testable for the first time.

**Also required before the PR:** re-check CTA reachability on a 667pt device (iPhone SE) and on iPad. The single-scroll conclusion was measured only on an iPhone 16 Pro with short stub copy; the discarded sticky-bar variant is preserved on branch `prototype/pdp-inline-cta` @ `27dd689`.

## Ticket shape — decided

**This stays a single ticket**, not split into per-section sub-tickets. All preparation lands here: the `TypographyBody.mediumBold` provider addition, test-fixture work (brand / colour name / SKU are empty or UUID today), the `AccordionView` `Theme.*` migration, and the `SizingSelectorComponentView` `.verticalList` arrangement.

Slice 0 (token refresh) remains a separate PR ahead of this one — it is already done and its generated diff is app-wide, so it earns its own review.

Suggested commit order inside the ticket, so review has a spine: token migration first (mechanical, no intended visual change), then the sheet deletion and single-scroll layout, then section by section — gallery, info block, size, colour, description, accordions.

