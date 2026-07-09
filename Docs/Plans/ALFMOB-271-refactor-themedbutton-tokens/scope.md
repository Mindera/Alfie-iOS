# Scout Report: ThemedButton → design tokens (ALFMOB-271)

**Branch**: ALFMOB-271-refactor-themedbutton-tokens (off feat/ALFMOB-264-adopt-design-tokens)  **Agents**: 3

## ⚠️ Ticket premise is partly stale
The ticket says styling is hardcoded like `Colors.primary.mono900` / `.white`. **Not true on this
branch.** `Colors.primary.*` / `Colors.secondary.*` facades do not exist anywhere in the repo. Colors,
spacing and corner radius are **already tokenized**. So this is a *narrower* refactor than the ticket implies.

## Relevant Files (implementation)
- `Alfie/AlfieKit/Sources/SharedUI/Theme/Buttons/ButtonTheme.swift:6-19` — `ButtonThemeSpec` struct: color-only fields, each in normal/disabled/pressed triplets (background / text / border). No width, radius, padding, or font in the spec.
- `ButtonTheme.swift:29-83` — per-variant spec values, all via `Primitives.Colours.neutrals*` (Primary bg `neutrals800`, text `neutrals0`, etc.). Primary/Secondary/Tertiary/Underline.
- `ThemedButton.swift:16-36` — public `init(text:type:style:leadingAsset:trailingAsset:isDisabled:isLoading:isFullWidth:action:)`. **API must stay unchanged.**
- `ThemedButton.swift:114-131,135-143` — `ButtonType` (.small/.medium/.big) + `Constants`: heights `36/44/52` (raw), `iconSize = 16` (raw), `horizontalPadding = 0`, `verticalPadding = -Primitives.Spacing.spacing8`, `cornerRadius = Sizing.radiusSoft`.
- `ThemedButton.swift:166,177,184` — applied spacing `Primitives.Spacing.spacing16`/`spacing8`; border `lineWidth: 1` (raw).
- `ThemedButton.swift:71-109` — font per size/variant via `theme.font.body.*` / `theme.font.heading.small` facade (wraps generated `Typography.*`).
- `ThemedButton.swift:283-316` — `CustomShimmerable` (public cornerRadius + shimmer colors via `Primitives.Colours.neutrals600/800`).
- `ThemedButton+Extension.swift:4-24` — convenience init (no `isFullWidth`).

## Available tokens (SharedUI/GeneratedTokens — generated, do not edit)
- **Semantic button colors — `Theme.*`** (`Theme+Generated.swift:9-32`): `buttonPrimary{Background,Content,Stroke}Primary{Default,Disabled}`, `buttonSecondary…`, `buttonTerciary…` (sic), `buttonDestructive…`. **Only Default + Disabled — no Pressed variant.**
- **Primitive colors — `Primitives.Colours.*`**: `neutrals0..900`, `semanticError100..800`, `semanticSuccess100..800`, `transparentTransparent`. No pure black; darkest is `neutrals800/900`. No blue/orange/yellow/brand.
- **Sizing — `Sizing.*`**: `radiusSoft`(4)/`radiusStrong`(16)/`radiusRounded`(1000); `iconsIconSmall/Medium/Large/Xlarge`; `interactiveSmallPaddingLeftRight`/`…TopBottom`(8). No token for button heights 36/44/52.
- **Spacing — `Primitives.Spacing.spacingN`**; **Typography — `Typography.{Body,Display,Heading,Label,Link}.*`** via `theme.font.*`.

## Migrated-component conventions to mirror
- `Components/Chips/Chip.swift`, `Components/Snackbar/SnackbarView.swift` — `Sizing.radius*`, `Primitives.Spacing.*`, `Primitives.Colours.*`, `Text.build(theme.font.body.small(...))`.

## Tests
- **No existing tests** for ThemedButton/ButtonTheme (unit or snapshot).
- Snapshot harness: swift-snapshot-testing `1.18.3`, tests live in **AlfieTests/Snapshots/** (main app target). Helper `Snapshotting.defaultImage()`, `view.embededInContainer()`. One `func test_…` per permutation (no loops).
- ⚠️ **All snapshot test files are currently OUT of target membership** (`// TODO: Re-add Target Membership once Snapshot tests are checked for working properly`) and **no reference images are committed**. Snapshot testing is effectively disabled project-wide right now.

## Open decisions (for PLAN/GRILL)
1. **Colors: keep raw `Primitives.Colours.neutrals*` or move to semantic `Theme.button*`?** Semantic is the "correct" token layer and the likely intent of the epic.
2. **Pressed state** — semantic `Theme.button*` has no Pressed token. Keep pressed on primitives, or derive?
3. **Raw literals** (`iconSize 16`, heights `36/44/52`, border `lineWidth 1`, `horizontalPadding 0`) — tokenize where a token exists (`iconSize → Sizing.iconsIcon*`?), accept the rest as gaps?
4. **Snapshot tests** — infra is disabled (no target membership, no committed refs). Add tests + re-enable membership + commit refs, or defer per repo's current state?
