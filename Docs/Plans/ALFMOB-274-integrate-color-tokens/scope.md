# Scout Report — ALFMOB-274 Integrate color tokens

**Branch:** ALFMOB-274-integrate-color-tokens (off ALFMOB-272 tip `2bb3eb1`)   **Agents:** 3

## Existing color system (the API to preserve)
- `Theme/Color/PrimaryColors.swift:4` — `PrimaryColorsProtocol`: `mono900…mono050` (10), `black`, `white`. Struct loads each from `Color("Mono900", bundle: .module)` (xcassets).
- `Theme/Color/SecondaryColors.swift:3` — `SecondaryColorsProtocol`: green/red/blue (10 shades each, 900→050), **yellow/orange (6 shades each: 500→050)**. Same xcassets construction.
- `Theme/Color/Color.swift:3` — `public enum Colors { static let primary/secondary }` — single composition point; ~78 files call `Colors.primary.*` / `Colors.secondary.*`.
- `Theme/Color/Colors.xcassets/` — 54 colorsets backing the above.
- `Theme/ThemeProvider.swift` — does NOT route colors; consumes `Colors.primary.*.ui` for UIKit appearance. `Color.ui` (`Utils/Extensions/Color+Extension.swift:4`) is a pure value conversion (no asset lookup) → survives xcassets removal.
- No `GeneratedColors.swift` exists yet.

## Generated tokens (what ALFMOB-272 actually emits)
- `GeneratedTokens/Primitives+Generated.swift:10` — `enum Primitives.Colours`: **`neutrals0…900` (10), `semanticError100…800` (8), `semanticSuccess100…800` (8), `transparentTransparent` (1)**. Concrete `Color(.sRGB, red:…)` literals.
- `GeneratedTokens/Theme+Generated.swift:6` — `enum Theme`: semantic colors as references to `Primitives.Colours.*`.
- Source JSON `SharedUI/DesignTokens/.primitives.alfie-theme.tokens.json` (pulled from upstream `Mindera/Alfie-Mobile-Design-Tokens`). Color keys confirmed: ONLY `colours-neutrals-{0..900}`, `colours-semantic-error-{100..800}`, `colours-semantic-success-{100..800}`, `colours-transparent-transparent`.
- Generator: `Tools/DesignTokenGen` (standalone, outside AlfieKit graph). Run via `./Alfie/scripts/generate-design-tokens.sh`; tokens pulled via `pull-design-tokens.sh`.

## ⚠️ BLOCKER: palette gap
| App API member | Token coverage |
|---|---|
| `mono050…mono900` (10) | `neutrals0…neutrals900` (10) — **rename + endpoint mapping question** (mono050↔neutrals0 or neutrals100?) |
| `white` | `neutrals0` = (1,1,1) ✓ exact |
| `black` | none exact (`neutrals900` ≈ 0.02,0.03,0.04 near-black; no pure #000) |
| `green050…900` (10) | `semanticSuccess100…800` (8) — count mismatch, "success" ≠ brand green scale |
| `red050…900` (10) | `semanticError100…800` (8) — count mismatch, "error" ≠ brand red scale |
| `blue050…900` (10) | **NONE** |
| `yellow050…500` (6) | **NONE** |
| `orange050…500` (6) | **NONE** |

The ALFMOB-264 epic `phase-2-color.md` assumed Phase 1 emits mono/green/red/blue/yellow/orange tokens to map 1:1. It does not. Its own step 1 hedged: *"If tokens differ, reconcile the protocol — don't silently drop."* The canonical hex for the missing families currently lives ONLY in `Colors.xcassets`; `DesignTokens.md` says tokens must be edited upstream, not authored locally.

→ ACs *"all primary/secondary colors sourced from tokens"* + *"no hardcoded hex remains"* are **not achievable as written** until the upstream token export publishes the full brand palette. Decision required (see _status.md / chat).

## ✅ DECISION (user, 2026-06-23)
**Replace the existing palette entirely with the generated tokens.** Remove `Colors.xcassets` and the
hardcoded `PrimaryColors`/`SecondaryColors` backing; re-point everything onto generated tokens
(`Primitives.Colours.*` / semantic `Theme.*`). Existing members with no generated equivalent are
migrated to the nearest generated/semantic token (mappings to be hardened in grill), not preserved.

## Usage data (367 call sites; member → count)
- **mono scale** (~208): mono900 (74), mono500 (27), mono300 (22), mono200 (22), mono400 (17), mono050 (14), mono100 (13), mono700 (8), mono600 (6), mono800 (5). → `neutrals*` (rename + endpoint mapping).
- **black (57) / white (38)** (~95): → `neutrals0` (white exact); black → token TBD (no pure-black token; `neutrals900` near-black or `Theme` content color).
- **green/red — production = SEMANTIC** (success/error): badges (`BadgeViewModifier`, `BadgeTabViewModifier`), `SnackbarView`, `PriceComponentView`, `ThemedInput` (validation). → `semanticSuccess*` / `semanticError*` or `Theme.*` semantic. Counts: red800 (8), green800 (5), red700 (4), green300 (3), then long tail of 1-2.
- **blue — production = only `ThemedDivider`** (blue500 ×13 incl. demos; blue300 ×4). No blue token → mapping TBD (likely a neutral/semantic border color).
- **yellow/orange — ONLY in DebugMenu demo views** (`ColorsDemoView`, `ButtonDemoView`, etc.). No production UI. Demo palette screens showcase colors that no longer exist → rework/trim needed.
- DebugMenu demo views (`ColorsDemoView` etc.) are the heaviest secondary consumers; they render the OLD palette and will need to render the new generated palette instead.

### Open mapping decisions for grill
1. mono050↔neutrals0 or neutrals100? (10 mono vs neutrals 0,100…900 — endpoint alignment).
2. `black` target token (no pure #000 in tokens).
3. green/red → `semanticSuccess/Error` (8 shades) vs the 10-shade brand scale call sites expect — shade remapping table.
4. blue (`ThemedDivider`) target.
5. Reshape of the `Colors.primary/secondary` API: keep the protocol facade (re-point bodies) vs migrate call sites to `Theme.*`/`Primitives.*` directly. Facade keeps 367 call sites unchanged — strongly preferred for blast radius.
6. DebugMenu `ColorsDemoView` (+ yellow/orange demos): re-point to generated palette or trim.

## Tests affected
- No unit tests assert color values. Snapshot suites in `Alfie/AlfieTests/Snapshots/` (esp. `ProductDetailsColorSheetSnapshotTests` rendering `Colors.primary.mono*`) shift if any hex changes; `isRecording=false` per-file, references not committed.
- `Tools/DesignTokenGen/Tests` assert on emitted `Color(.sRGB…)` + component arrays (would change if generator/tokens change).
