# Decide how to close the 11 Figma values that have no token equivalent

Type: grilling
Status: resolved
Blocked by: —

## Question

Ticket 01 found the PDP Figma is almost entirely token-clean — spacing hits exact steps, colours are exact primitives, typography maps 1:1 — but **11 values (G1–G11) have no token to bind to**. Each needs one of three fates: add it to the token JSON and regenerate, express it as a `// Figma: …` constant, or deviate from the design. Decide per gap, and decide the *rule* that governs the choice.

Read `.scratch/pdp-modern-design/research/01-figma-token-mapping.md` first for the full G1–G11 detail.

The load-bearing three:

- **G1 — `#CDCDCD` (neutrals300) used as a border.** The size-chip default border, the unselected pagination dot, and the out-of-stock strikethrough all want it. `Theme` jumps `borderSoft` (neutrals200) → `borderMedium` (neutrals400) with nothing in between. This is the most repeated gap on the screen, and it lands squarely in the size grid — resolve before ticket 03.
- **G2 — `#2B2B2B` (neutrals700) as secondary text**, for the brand name and the `Black | Ref. <sku>` meta line. There is no `content/secondary` semantic alias at that weight. Substituting `contentContentTerciary` silently would be a visible deviation — make it an explicit decision. Blocks ticket 04.
- **G9 — the price uses `body/medium-bold`** (SF Pro Medium, 16/24). `TypographyBody` has no `mediumBold`; the only style matching those metrics is `theme.font.link.medium`, which is semantically wrong for a price. Add the style, or accept a mismatch?

And the rest: **G8** every 16/24 style needs the explicit `lineSpacing` correction PLP had to apply; **G7** the accordion's `gap: -1px` hairline collapse; **G6** the 40×40 wishlist button; **G5** the header's `blur(16px)` Glass Effect (no effect tokens exist in the system at all); **G10** the sheet's 12pt corner; **G3/G4/G11** confined to out-of-scope or sub-perceptual cases.

Frame the decision against two constraints already established: the rollout convention is that a `private enum Constants` survives **only** for genuinely non-tokenisable values, each carrying a `// Figma: …` comment; and PLP's convention was **not** to churn shared components or the token system for a restyle. Changing `SharedUI/DesignTokens/*.json` and regenerating affects every screen, not just PDP — say explicitly whether that is in bounds for ALFMOB-441 or belongs back with the foundations epic (ALFMOB-264).

Consult `/grilling` and `/domain-modeling`.

## Answer

**Governing rule: `Theme.*` only. No `Primitives.*` references may be introduced by this work.** Where a Figma value has no `Theme.*` token, the value is not substituted silently — it is recorded as an upstream token request and the affected element waits.

Checking the design's own token source (rather than trusting the local copy) changed most of the picture: **the repo's token pull is stale.** Local `SharedUI/DesignTokens/` was pulled 2026-07-16; upstream `Mindera/Alfie-Mobile-Design-Tokens@e6c427e` (2026-07-21) has moved on.

Per-gap resolution:

- **G9 (price `body/medium-bold`) — not a gap.** `body-medium-bold` exists upstream in `typography.styles.tokens.json` (SF Pro Medium at body-medium's size and line-height); the local copy has 15 styles, upstream has 16. A token refresh yields `theme.font.body.mediumBold`. Do **not** use `theme.font.link.medium` for the price.
- **G1 (`#CDCDCD` border) and G2 (`#2B2B2B` secondary text) — real gaps, deferred.** Both values exist upstream as primitives in a new `colours-brand-*` ramp (`colours-brand-300` = `#CDCDCD`, `colours-brand-700` = `#2B2B2B`), but the theme layer aliases only `brand-500`. There is no `border-*` or `content-*` token resolving to either. Under the Theme-only rule these cannot be built today. **Recorded as upstream token requests** in `token-requests.md`; the list is delivered with the spec (ticket 08) rather than chased now.
- **G4** struck-through price → `Theme.contentContentPrimaryDisabled` (`neutrals400` `#A1A1A1`, Δ4 from `#A5A5A5`). No gap.
- **G6** 40×40 wishlist button → `sizing`'s `icons-icon-xlarge` (= 40). No gap.
- **G8** is a `lineSpacing` correction, not a token — apply the PLP fix to every 16/24 style.
- **G7** (`gap: -1px`), **G10** (12pt sheet corner — radius scale is 4/16/1000, no 12; moot if the sheet stays native), **G11** (0.01em kerning, sub-perceptual) — geometry, handled in code with `// Figma:` comments.
- **G3**, **G5** — sit inside out-of-scope areas (recommendations grid, header glass).

Also surfaced: upstream repointed `button-primary-background-primary-default` from `{surface-background-inverted-primary}` to `{colours-brand-500}`. Same `#111111` today, so the Add to Bag button does not change colour on refresh — but the CTA is now brand-driven, and a `theme.new-brand-theme` mode exists with a yellow ramp (`#FFD100`). The CTA must not be assumed permanently black.

Consequence: the token refresh becomes its own ticket, landing **before** ALFMOB-441 — see [ticket 10](10-token-refresh.md).
