# Slice 0b — Add the two missing semantic tokens upstream

**Repo:** `Mindera/Alfie-Mobile-Design-Tokens` (**not** Alfie-iOS) · **Blocks:** two elements of Slice 1
**Owner:** unassigned — needs someone with write access to the design-tokens repo

## Why this is its own ticket

PDP binds to `Theme.*` only. Exactly two values on the whole screen have no semantic alias. The **primitives already exist upstream** — only the aliases are missing, so this is a two-line change to `theme.alfie-theme.tokens.json`. It cannot be patched in Alfie-iOS: `pull-design-tokens.sh` overwrites local edits.

## Scope

| Token to add | Should resolve to | Value |
|---|---|---|
| `border/border-strong` | `{colours-brand-300}` | `#CDCDCD` |
| `content/content-secondary` | `{colours-brand-700}` | `#2B2B2B` |

## Why each is genuinely missing

- **`border-strong`** — the border scale runs `border-soft` (`neutrals200`, `#E9E9E9`) → `border-medium` (`neutrals400`, `#A1A1A1`) with nothing between. `#CDCDCD` exists in the theme only as `surface-background-terciary` and the `*-disabled` button tokens: a surface and a state token, neither semantically a border.
- **`content-secondary`** — the content scale runs `content-primary` (`neutrals800`) → `content-terciary` (`neutrals500`); the naming skips the "secondary" rung entirely. `#2B2B2B` appears only as `surface-foreground-inverted-primary`.

## Impact if this does not land before Slice 1

Slice 1 still ships, with two knowingly off-design elements:

- **Size-chip borders** render `border-soft` — three steps lighter than designed, visibly washed out.
- **Brand-name line** renders `content-primary` — identical to the product name, flattening the intended hierarchy.

Both are one-line fixes once the tokens exist. Full rationale: `.scratch/pdp-modern-design/token-requests.md`.

## Blockers

Access to the design-tokens repo, and design sign-off on the two token names.

## Open questions

- Are `border-strong` and `content-secondary` the right names, or does the design system already have an intended naming for these rungs?

## Acceptance

- Both aliases exist upstream on `main`.
- `pull-design-tokens.sh` + `generate-design-tokens.sh` in Alfie-iOS yields `Theme.borderStrong` and `Theme.contentContentSecondary`.
