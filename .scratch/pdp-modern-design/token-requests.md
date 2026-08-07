# Upstream token requests — Mindera/Alfie-Mobile-Design-Tokens

Running list of semantic tokens the PDP redesign needs but which do not exist in the theme layer. Established by [ticket 09](issues/09-token-gaps.md); delivered with the spec in [ticket 08](issues/08-write-the-spec.md).

**Rule this list exists to serve:** PDP uses `Theme.*` only. No `Primitives.*` references are introduced. Where no `Theme.*` token exists, the element waits on an entry below rather than being substituted silently.

Checked against upstream `main` @ `e6c427e` (2026-07-21). In every case the *primitive already exists* — only the semantic alias is missing, so these are one-line additions to `theme.alfie-theme.tokens.json`.

| Ref | Requested token | Should resolve to | Value | Needed for | Blocks |
|---|---|---|---|---|---|
| **G1** | `border/border-strong` | `{colours-brand-300}` | `#CDCDCD` | Size-chip default/unselected border, unselected pagination dot, out-of-stock strikethrough rule, bottom-sheet grab handle | [Ticket 03](issues/03-size-selector-grid.md) — size grid |
| **G2** | `content/content-secondary` | `{colours-brand-700}` | `#2B2B2B` | Brand name line, `Black \| Ref. <sku>` meta line | [Ticket 04](issues/04-colour-summary-chip.md) — info block |

## Why each is genuinely missing

**G1.** The theme's border scale is `border-soft` (`neutrals200`, `#E9E9E9`) → `border-medium` (`neutrals400`, `#A1A1A1`), with nothing between. `#CDCDCD` exists in the theme only as `surface-background-terciary` and the `*-disabled` button tokens — a surface and a state token, neither semantically a border. Substituting `border-soft` is three steps lighter and visibly washes the size-chip borders out.

**G2.** The content scale runs `content-primary` (`neutrals800`, `#111111`) → `content-terciary` (`neutrals500`, `#767676`). The naming skips the "secondary" rung entirely. `#2B2B2B` appears in the theme only as `surface-foreground-inverted-primary`. Substituting `content-primary` makes the brand line render identically to the product name and flattens the intended hierarchy; `content-terciary` is noticeably lighter than the design.

## Not requested (resolved without upstream change)

- `body-medium-bold` (price) — **already exists upstream**; the repo's pull is just stale. Fixed by [ticket 10](issues/10-token-refresh.md), not by a request.
- Struck-through price `#A5A5A5` → `Theme.contentContentPrimaryDisabled` (Δ4, accepted).
- 40×40 wishlist button → `sizing`'s `icons-icon-xlarge`.
- 16/24 line heights → a `lineSpacing` correction in code, not a token.
- Accordion `-1px` collapse, 12pt sheet corner, 0.01em kerning → geometry, handled in code with `// Figma:` comments.
