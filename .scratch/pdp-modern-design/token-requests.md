# Upstream token requests — Mindera/Alfie-Mobile-Design-Tokens

Running list of semantic tokens the PDP redesign needs but which do not exist in the theme layer. Established by [ticket 09](issues/09-token-gaps.md); delivered with the spec in [ticket 08](issues/08-write-the-spec.md).

**Rule this list exists to serve:** PDP uses `Theme.*` only. No `Primitives.*` references are introduced. Where no `Theme.*` token exists, the element waits on an entry below rather than being substituted silently.

Checked against upstream `main` @ `a3b2b88` (2026-08-10, PR #3). In every case the *primitive already exists* — only the semantic alias is missing.

**These are not hand edits to `theme.alfie-theme.tokens.json`.** That file is generated output: `design-tokens/` is exported from Figma by the in-house plugin. A fix requires the Figma variable to change **and** a fresh plugin export to be run and merged. Changing the variable alone never reaches us — PR #3 is the worked example (see G2).

| Ref | Requested token | Should resolve to | Value | Needed for | Blocks | Status |
|---|---|---|---|---|---|---|
| **G1** | `border/border-strong` | `{colours-brand-300}` | `#CDCDCD` | Size-chip default/unselected border, unselected pagination dot, out-of-stock strikethrough rule | [Ticket 03](issues/03-size-selector-grid.md) — size grid | **superseded** — see the swap proposal below |
| **G2** | `content/content-secondary` | `{colours-brand-700}` | `#2B2B2B` | Brand name line, `Black \| Ref. <sku>` meta line | [Ticket 04](issues/04-colour-summary-chip.md) — info block | **mis-bound upstream** — landed as `{colours-neutrals-800}` |
| **G3** | a `content/*` alias for `{colours-brand-600}` | `{colours-brand-600}` | `#4A4A4A` | Muted body text app-wide — **17 call sites**, incl. PDP's error-view message | [Ticket 01](implementation/01-foundation-single-scroll-and-tokens.md) — AC #5 | **new** — no alias has ever existed |

## G1 — superseded by a scale swap

The designer's counter-proposal (2026-08-10) is that mapping `#CDCDCD` to `border-strong` inverts the scale, because the existing `border-medium` is `#A1A1A1` — darker. Instead:

- `border-medium` → `#CDCDCD` (lighter)
- `border-strong` → `#A1A1A1` (darker)

**Agreed from the iOS side. Impact is zero, not small:** `Theme.borderMedium` has **no consumers anywhere in the app**. No snapshot baseline moves.

Under the swap, PDP's `#CDCDCD` need is served by `Theme.borderMedium` and G1 dissolves rather than being fulfilled.

One discrepancy this surfaced: the designer says Figma's Quick Filter chips use `border-medium`, but our `Chip` uses `Theme.borderSoft` (`#E9E9E9`). Our chips are already lighter than the design, independent of the swap. Worth a follow-up ticket.

## G2 — the alias exists but points at the wrong primitive

PR #3 ("add content-content-secondary token from Figma export", merged `a3b2b88`) added:

```json
"content-content-secondary": { "$value": "{colours-neutrals-800}" }
```

`neutrals-800` is `#111111` — **identical to `content-content-primary`**. The alias therefore does nothing: the brand line would still render the same as the product name, which is the exact hierarchy-flattening the request exists to prevent.

The designer states the Figma variable is now bound to `brand-700`. That change post-dates the export in PR #3, so a fresh export is needed. Verified current as of `a3b2b88` — three pull+generate cycles all produce `neutrals-800`.

Adopting `Theme.contentContentSecondary` at call sites is still correct: it re-points automatically on the next regeneration. Two caveats — it renders wrong (`#111111`) until then, and the eventual propagation is silent, so snapshot baselines will fail on the regen and need re-recording. That failure is expected, not a regression.

## G3 — `#4A4A4A` has no semantic name at all

The content scale runs `content-primary` (`neutrals800`, `#111111`) → `content-terciary` (`neutrals500`, `#767676`). Nothing names `#4A4A4A`, which sits between them and is the app's de-facto muted-text colour.

17 call sites across 12 files, spanning three distinct roles:

- **Muted supporting text** — product-card subtitles (`VerticalProductCard`, `HorizontalProductCard`), sale strikethrough price (`PriceComponentView`), chip label (`Chip`, which already carries a `// No Theme alias` comment), the global text attribute default in `DesignSystem`, and error-view message colour in **both** `Web/UI/WebView.swift` and `ProductDetails/UI/ProductDetailsView.swift`
- **Disabled states** — `AccordionView`, `ThemedButton` shimmer
- **Filled controls** — selected pagination dot (`ThemedPageControl`), toggle knob, progress-bar fill

This is the largest gap of the three and was not previously catalogued. PDP is not a special case: `WebView` uses it for the identical error-message role.

**Consequence for ticket 01 AC #5:** with no alias to migrate to, PDP's error-view message stays a raw primitive with a `// No Theme alias` comment, matching `Chip.swift:134` and the other 15 consumers. AC #5 should read "no *undocumented* legacy primitive references remain".

## Not requested (resolved without upstream change)

- `body-medium-bold` (price) — **resolved.** Landed via the token refresh; `Typography.Body.mediumBold` now generates, and `TypographyBody` exposes it.
- Struck-through price `#A5A5A5` → `Theme.contentContentPrimaryDisabled` (Δ4, accepted).
- 40×40 wishlist button → `sizing`'s `icons-icon-xlarge`.
- 16/24 line heights → a `lineSpacing` correction in code, not a token.
- Accordion `-1px` collapse, 12pt sheet corner, 0.01em kerning → geometry, handled in code with `// Figma:` comments.
