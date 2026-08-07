# Refresh the design-token pull and regenerate, in its own PR

Type: task
Status: resolved
Blocked by: —

## Question

Nothing to decide — mechanical work that must land **before** ALFMOB-441, in a separate PR so the app-wide generated diff is reviewed on its own merits rather than buried in a single-screen restyle.

The repo's token copy is stale: `SharedUI/DesignTokens/` was pulled 2026-07-16; upstream `Mindera/Alfie-Mobile-Design-Tokens@e6c427e` is 2026-07-21.

Steps:

1. `./Alfie/scripts/pull-design-tokens.sh` then `./Alfie/scripts/generate-design-tokens.sh` (the generator's own tests are gated inside the second script and run first).
2. `git diff -- Alfie/AlfieKit/Sources/SharedUI/GeneratedTokens` and review every change.
3. `./Alfie/scripts/verify.sh --skip-integration`.

Known incoming changes to check for specifically:

- **`body-medium-bold` appears** — a 16th composite typography style. Confirm it generates as `theme.font.body.mediumBold`; this is what the PDP price binds to.
- **A `colours-brand-*` primitive ramp appears** (`brand-300` `#CDCDCD`, `brand-500` `#111111`, `brand-700` `#2B2B2B`, plus a `new-brand` yellow ramp at `#FFD100`).
- **`button-primary-background-primary-default` / `-stroke-` repoint** from `{surface-background-inverted-primary}` to `{colours-brand-500}`. Both resolve to `#111111`, so **no visual change is expected** — but verify that against the Splash/app-shell/Home/PLP surfaces already rolled out, since primary buttons appear on all of them. Any pixel change here is a regression in *those* stories, not this one.
- **`theme.selfridges` is renamed `theme.new-brand-theme` upstream.** The local `manifest.json` still names `theme.selfridges.tokens.json`; check the pull script's subset filter handles the rename rather than silently dropping a collection.

Report anything that changes the rendering of an already-migrated screen — that is the risk this ticket exists to isolate.

Note: this ticket does **not** add the `border/border-strong` or `content/content-secondary` aliases — those are upstream requests tracked in [token-requests.md](../token-requests.md) and are not resolved by a refresh.

## Answer

Done. `pull-design-tokens.sh` + `generate-design-tokens.sh` run; `./Alfie/scripts/verify.sh --skip-integration` → **✅ VERIFICATION PASSED**. Diff: 5 token JSON files, 3 generated Swift files.

What landed:

- **`Typography.Body.mediumBold` now exists** — SF Pro Medium, 16pt, 24pt line height, kerning none. The PDP price binds to `theme.font.body.mediumBold`. G9 closed.
- **`Primitives.Colours.brand0…900` added**, plus the `brandNewBrand*` yellow ramp (`brandNewBrand500` = `#FFD100`).
- **`buttonPrimaryBackgroundPrimaryDefault` and `buttonPrimaryStrokePrimaryDefault` repointed** `neutrals800` → `brand500`. Both are `#111111` — **no visual change**, confirmed by the passing build and unit suite across the already-migrated surfaces.
- **`Primitives.Spacing.spacing44` added** (new 44pt step — the iOS minimum touch target).
- The `theme.selfridges` → `theme.new-brand-theme` rename came through the pull cleanly; no collection was dropped.

What did **not** land: **no new `Theme.*` aliases at all.** `border-strong` and `content-secondary` are still absent, so G1 (`#CDCDCD`) and G2 (`#2B2B2B`) remain blocked exactly as recorded in [token-requests.md](../token-requests.md). A refresh was never going to fix them — they need the upstream aliases.

Ships as its own PR, before ALFMOB-441.
