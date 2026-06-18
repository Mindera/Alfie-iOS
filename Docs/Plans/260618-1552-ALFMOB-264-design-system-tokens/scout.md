# Scout Report: ALFMOB-264 — Design System Token Integration & Component Refactoring

_Scouting pass that preceded the plan. Branch: `claude/exciting-leavitt-64caf7`. All paths relative to repo root._

## Epic → story map (9 sub-tickets)

| Plan phase | Story | Title | Primary target |
|---|---|---|---|
| P1 | ALFMOB-272 | Set up token JSON parser & codegen | new `SharedUI/DesignTokens/` + `GeneratedTokens/` |
| P2 | ALFMOB-274 | Integrate color tokens | `Theme/Color/` |
| P3a | ALFMOB-266 | Integrate typography tokens | `Theme/Typography/` |
| P4 | ALFMOB-270 | Integrate spacing & shape tokens | `Theme/Spacing/`, `CornerRadius/`, `Shape/` |
| P5 | ALFMOB-267 | Refactor Typography/Label | `Theme/Typography/` |
| P5 | ALFMOB-271 | Refactor ThemedButton | `Theme/Buttons/` |
| P5 | ALFMOB-268 | Refactor ThemedInput | `Theme/Inputs/` |
| P5 | ALFMOB-273 | Refactor Chip | `Components/Chips/` |
| P5 | ALFMOB-269 | Refactor Badge | `Components/Indicators/` |

## Relevant files

### Token foundations
- `Alfie/AlfieKit/Sources/SharedUI/Theme/Color/Color.swift:3` — `enum Colors` accessor (`primary`, `secondary`)
- `Theme/Color/PrimaryColors.swift:4,20` — `PrimaryColorsProtocol` (mono900–050, black, white); struct loads from `Colors.xcassets` via `Bundle.module`
- `Theme/Color/SecondaryColors.swift:3,52` — `SecondaryColorsProtocol` (green/red/blue 050–900, yellow/orange 050–500)
- `Theme/Color/Colors.xcassets/` — 54 colorsets (53 universal; the one dark variant, Blue050, is a no-op)
- `Theme/Typography/TypographyProvider.swift:5,14` — `TypographyProviderProtocol` (header/paragraph/small/tiny)
- `Theme/Typography/Specifications/TypographyHeaderProtocol.swift` (h1 36 / h2 24 / h3 20pt), `…ParagraphProtocol` (16), `…SmallProtocol` (14), `…TinyProtocol` (12) — each with normal/bold/italic/underline/strike builder variants (~15 UIFont getters, ~70 AttributedString builders total)
- `Theme/Typography/Helpers/FontNames.swift:8` — `FontNames.sfProMedium` + `FontManager.registerAll()`
- `Theme/Typography/Helpers/Font+Extensions.swift:7` — `AttributedString.build(font:lineHeight:letterSpacing:…)`, HTML + `Text.build`
- `Theme/Spacing/Spacing.swift:6` — `enum Spacing` space0→space1000 (0–80pt)
- `Theme/CornerRadius/CornerRadius.swift:7` — `enum CornerRadius` none/xxs/xs/s/m/l/xl/full (+ `swiftlint:disable` header)
- `Theme/Shape/ShapeProviderProtocol.swift:4` + `DefaultShapeProvider.swift:3`
- `Theme/ThemeProvider.swift:14` — `ThemeProvider.shared`; exposes `font` + `shape`, `setupAppearance()` (uses `Colors.primary.*.ui`)

### Components (P5)
- Button — `Theme/Buttons/ThemedButton.swift:5`, `ButtonTheme.swift:23` (`ButtonThemeSpec`; refs `Colors.primary.mono*`, `Spacing.space100/200`, `CornerRadius.s`)
- Input — `Theme/Inputs/ThemedInput.swift:5` (`InputStatus`; refs mono*, secondary green800/red800, `CornerRadius.xs`)
- Typography/Label — `Theme/Typography/**` + `Helpers/Font+Extensions.swift:162` (`Text.build`)
- Chip — `Components/Chips/Chip.swift:44` (`ChipConfiguration`; `CornerRadius.full`; hardcoded heights 36/44)
- Badge — `Components/Indicators/BadgeViewModifier.swift:9`, `BadgeTabViewModifier.swift:9`, `BadgeHelper.swift` (`Colors.secondary.red700`, hardcoded sizes)

### Build & tests
- `Alfie/AlfieKit/Package.swift` — SharedUI target `277–295` (resources `286–294`); product `71–74`; SwiftGenPlugin `:100`; swift-snapshot-testing `:94`; TestUtils target `297–303` (vends SnapshotTesting)
- `Alfie/AlfieKit/Sources/SharedUI/swiftgen.yml` + `Resources/Templates/codegen-strings-structured.stencil` — codegen precedent to mirror
- `Alfie/scripts/run-apollo-codegen.sh`, `verify.sh` — script conventions
- `Alfie/.swiftlint.yml` — `opt_in_rules: [all]`, runs as Xcode build phase; `excluded` lists `L10n+Generated.swift`/`BFFGraph`
- Tests: `Alfie/AlfieKit/Tests/SharedUITests/BadgeHelperTests.swift`, `StyleGuideTests.swift` (empty stub). App snapshots in `Alfie/AlfieTests/Snapshots/` + `Helpers/` (pointfree 1.18.3, `@testable import Alfie`)

## Patterns observed
- Components access theme via `var theme: ThemeProviderProtocol { ThemeProvider.shared }` then `theme.font.*`. Colors/Spacing/CornerRadius are accessed **statically** (`Colors.primary.mono900`), not via the provider.
- Codegen precedent: SwiftGen (SPM plugin + build phase) + Apollo (shell script). Generated output committed. **No DTCG / Style Dictionary / Node tooling exists** — Phase 1 is greenfield.
- Colors are asset-backed (`Colors.xcassets`); typography currently renders **everything** in SF Pro Display Medium despite doc-comments naming freightBook/circular*.

## Key unknowns (carried into the plan as open questions)
- External token repo `Mindera/Alfie-Mobile-Design-Tokens` (DTCG JSON) not yet in this repo.
- Licensed fonts (freightBook/circular*) not bundled — only SF Pro.
- Legacy→Figma typography mapping needs design sign-off.

See `plan.md` for the full implementation plan; `red-team.md` + `validation.md` for review/decisions.
