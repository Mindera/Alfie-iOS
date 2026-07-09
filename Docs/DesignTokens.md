# Design Tokens (ALFMOB-272)

Alfie's design values (colour, spacing, radius, typography) are generated from the shared
[W3C DTCG](https://tr.designtokens.org/format/) token contract in
[`Mindera/Alfie-Mobile-Design-Tokens`](https://github.com/Mindera/Alfie-Mobile-Design-Tokens) and
committed as type-safe Swift. **Never hand-edit the generated Swift.**

## Layout

| Path | What | Committed? | Compiled? |
|---|---|---|---|
| `AlfieKit/Sources/SharedUI/DesignTokens/` | DTCG JSON (iOS subset) pulled from the token repo | ✅ | ❌ (`exclude:` in `Package.swift`) |
| `AlfieKit/Sources/SharedUI/GeneratedTokens/` | Generated Swift (`Primitives/Theme/Sizing/Typography/ThemeColours/ThemeFonts +Generated.swift`) | ✅ | ✅ (normal SharedUI sources) |
| `AlfieKit/Sources/SharedUI/GeneratedTokens/ResolvedTokens/` | Generated per-theme JSON (`<theme>.resolved.tokens.json`) — every token resolved to a concrete value under that theme's palette; a language-neutral mirror of the Swift for non-Swift consumers | ✅ | ❌ (`exclude:` in `Package.swift`) |
| `Tools/DesignTokenGen/` | The standalone Swift generator (SwiftPM, Foundation-only) | ✅ | ❌ (outside the AlfieKit graph) |
| `Alfie/scripts/pull-design-tokens.sh` | Copies the iOS-subset JSON into `DesignTokens/` | ✅ | — |
| `Alfie/scripts/generate-design-tokens.sh` | Tests the generator, then regenerates `GeneratedTokens/` | ✅ | — |

## Updating tokens when the design changes

```bash
# 1. Pull the latest DTCG JSON (SSH clone by default; or point at a local checkout)
./Alfie/scripts/pull-design-tokens.sh
#    local checkout:  DESIGN_TOKENS_SRC=/path/to/Alfie-Mobile-Design-Tokens ./Alfie/scripts/pull-design-tokens.sh

# 2. Regenerate the committed Swift (runs the generator's unit tests first, fail-fast)
./Alfie/scripts/generate-design-tokens.sh

# 3. Review and commit BOTH the JSON and the generated Swift
git diff -- Alfie/AlfieKit/Sources/SharedUI/DesignTokens Alfie/AlfieKit/Sources/SharedUI/GeneratedTokens
```

Commit the generated Swift **only when tokens actually changed**. Output is deterministic
(sorted, no timestamps), so a clean regeneration produces a byte-identical diff.

## How the generator works

`Tools/DesignTokenGen` reads `manifest.json`, loads the **iOS mode** of each multi-mode collection
(System = `ios`, Screen Size = `small-(s)` per the contract), and resolves `{reference}` chains into a
single name→token graph. It then emits Swift that **preserves the reference graph**: primitives hold
concrete literals; semantic (`Theme`), `Sizing` and `Typography` tokens emit as references to
`Primitives.*` symbols (no hardcoded hex). Generated API mirrors the Figma names verbatim, e.g.
`Theme.buttonPrimaryBackgroundPrimaryDefault`, `Typography.display.large`, `Sizing.radiusSoft`.

### Allow-lists

The token export ships two allow-lists (`.cycle-allowlist.json`, `.broken-ref-allowlist.json`) for
known Figma-plugin artefacts (7 font-family cycles, 2 filtered font-weight primitives). The generator
honours them **exhaustively** — an unlisted cycle / missing ref fails generation, and a stale entry
(scoped to the loaded iOS files) also fails — so the exceptions can't silently rot.

## Important

- **`verify.sh` does NOT build or test `Tools/DesignTokenGen`** (it's outside the AlfieKit graph by
  design). The generator's unit tests run inside `generate-design-tokens.sh` — run that whenever you
  touch the generator or the tokens.
- The generated `*+Generated.swift` files carry an `AUTO-GENERATED` + `// swiftlint:disable all`
  header and are excluded from SwiftLint; edit the tokens upstream, not the output.
- Nothing consumes the generated tokens yet — wiring the existing theme types (`Colors`, `Spacing`,
  typography) onto them is the follow-on work (ALFMOB-272 P2/P3a).
