# Slice 0 — Refresh the design-token pull and regenerate

**Parent epic:** ALFMOB-427 · **Blocks:** Slice 1 (ALFMOB-441)
**Status:** work is **done but uncommitted** on `claude/wayfinder-skills-alfmob-441-88422c` (8 files, `verify.sh --skip-integration` passed)

## Why this is its own ticket

The repo's token copy was pulled 2026-07-16; upstream `Mindera/Alfie-Mobile-Design-Tokens` had moved on. Regenerating produces an **app-wide** generated diff that deserves review on its own merits rather than buried inside a single-screen restyle.

## Scope

- Run `./Alfie/scripts/pull-design-tokens.sh` then `./Alfie/scripts/generate-design-tokens.sh`.
- Commit the 5 token JSON files and 3 generated Swift files.

## What it delivers

- **`Typography.Body.mediumBold`** — required by the PDP price (`body/medium-bold` in the design).
- `Primitives.Colours.brand0…900` plus the `brandNewBrand*` yellow ramp (`brandNewBrand500` = `#FFD100`).
- `buttonPrimaryBackgroundPrimaryDefault` / `…StrokePrimaryDefault` repointed `neutrals800` → `brand500`. **Both are `#111111` — no visual change** — but the CTA is now brand-driven and must not be assumed permanently black.
- `Primitives.Spacing.spacing44`.

## Also required (hand-written, not generated)

`TypographyBody` does not expose the new style, so `theme.font.body.mediumBold` will not compile. Add it to `Sources/SharedUI/Theme/Typography/Specifications/TypographyGroups.swift:48-65`, mirroring the existing `TypographyLabel.smallBold` pattern.

## Blockers

None.

## Open questions

None.

## Acceptance

- `./Alfie/scripts/verify.sh --skip-integration` passes.
- `theme.font.body.mediumBold` resolves at a call site.
- No visual regression on already-migrated surfaces (Splash, app shell, Home, PLP).
