# Spike Findings: ALFMOB-272 — DTCG contract (resolved against the real export)

_2026-06-19. Source: local clone `Mindera/Alfie-Mobile-Design-Tokens` @ working copy. This is the
"pull + inspect before writing emitters" spike the plan demanded — it resolves the contract unknowns
the red-team flagged (and corrects two epic assumptions). The repo ships its own contract spec
(`DESIGN_TOKENS_FORMAT.md`) + `PLAN.md` — read those; this summarizes the iOS-relevant facts._

## File set (the "14 files")
`design-tokens/` = `manifest.json` + 13 `*.tokens.json`. **Read `manifest.json` first** (don't scan
the dir). Collections & modes:

| Collection | Modes | iOS uses |
|---|---|---|
| `.primitives` | `alfie-theme` | ✅ all (72 tokens: 40 dimension, 27 color, 4 fontFamily, 1 fontWeight) |
| `theme` | `alfie-theme` | ✅ 31 semantic color tokens (surface/content/border/button/link), all references |
| `sizing` | `alfie-theme` | ✅ radii / icon sizes / interactive padding (all reference `spacing-*`) |
| `typography` | `alfie-theme` | ✅ needed to resolve composite sub-refs (NOT emitted as its own surface) |
| `typography.styles` | (styles) | ✅ **the canonical consumption path** — 15 real composite styles (+ `~~doc-*` to skip) |
| `system` | `ios` / `android` / `web` | ✅ **`ios` only** — font families + screen routing |
| `screen-size` | `small(s)` / `m` / `l` / `xl` | ✅ **`small-(s)` only** (PLAN Q3: mobile codegen uses Small at codegen-time) |
| `.documentation` | `mode-1` | ❌ **skip** entirely |

**Mode selection is the key to avoiding name collisions** (red-team J1): references resolve by **name,
not path**, into one flat `name→token` map — but you load only the **active mode** per multi-mode
collection (`system.ios`, `screen-size.small`), plus the single-mode files. That de-collides the
duplicate names across the other platform/breakpoint files. Also skip `.documentation` + any
`~~doc-`-prefixed token.

## Value shapes (confirmed) — corrects red-team J4 / J5

- **color**: `{ "colorSpace": "srgb", "components": [r,g,b] | [r,g,b,a] }`, floats `0.0–1.0`.
  **NOT hex.** Current export: all 27 are 3-component (no alpha present today). → emit
  `Color(.sRGB, red:, green:, blue:, opacity:)`, default opacity `1` when only 3 components; still
  read an optional 4th defensively. **No hex parser needed** (J4 was wrong about the format).
- **dimension**: `{ "value": <number>, "unit": "px" }`. **Only `px`** in the whole export; contract
  says iOS points = px @1×. → emit `CGFloat(value)`; **error on any non-`px` unit** defensively
  (J5's rem concern does not occur today, keep the guard).
- **fontFamily**: `string` (e.g. `"Libre Baskerville"`, `"SF Pro"`). iOS resolves brand→primary via
  `system.ios`.
- **fontWeight**: primitive scale is CSS `100–900` (number); in composites it is **inlined as a
  string** `"Regular"`/`"Medium"` → map to `400`/`500` (per `.broken-ref-allowlist.json` fix_strategy).
- **typography** (composite — confirms red-team J2): `{ fontFamily, fontWeight, fontSize, lineHeight,
  letterSpacing }`; every subfield except the inlined `fontWeight` is a `{reference}`. Example:
  ```json
  "display-large": { "$type":"typography", "$value": {
    "fontFamily":"{display-large-font-family}", "fontWeight":"Regular",
    "fontSize":"{display-large-font-size}", "lineHeight":"{display-large-line-height}",
    "letterSpacing":"{display-large-kerning}" } }
  ```

## References, cycles, broken refs — supersedes the plan's "error on missing/cycle"

- Refs are `"{token-name}"`, by name, chain depth **≤5**. Resolution algo is specified in
  `DESIGN_TOKENS_FORMAT.md` §Resolution.
- **`.cycle-allowlist.json` (7 edges)** — known plugin-artifact cycles around
  `typography-font-family-brand`/`-system-brand`. Resolver MUST: detect cycles → match the offending
  `(file, token)` edge against the allowlist → if listed, resolve to the primitive concrete value
  (`Libre Baskerville`) + warn; if not listed, **fail**. Allowlist is **exhaustive**: stale entries
  (allow-listed but no longer real) must fail the build.
- **`.broken-ref-allowlist.json` (2 targets)** — `typography-font-weight-regular`/`-medium` are
  FONT_STYLE-scoped and filtered out by the exporter. They only dangle in `typography.alfie-theme`
  (which iOS doesn't emit); composites inline the weight, so **iOS is unaffected** — but the resolver
  must load this allowlist and not hard-fail on those targets.
- ⇒ The plan's blunt "detect cycles & error on missing refs" must become **"honor both allowlists
  (exhaustively)"**. This is new work the plan didn't budget.

## Naming → Swift (confirms red-team J3; target shape given by PLAN.md)
Names are hyphenated, verbatim from Figma: `colours-neutrals-800`, `spacing-spacing-0`,
`display-large`, `surface-background-primary`. PLAN.md fixes the emitted Swift shape:
- primitives: `Primitives.Color.neutrals800`, semantic: `static let buttonPrimaryBackground =
  Primitives.Color.neutrals800` (**reference graph preserved — confirms M4 / ticket AC**, PLAN §252).
- typography: `Typography.display.large` (PLAN §275) — Figma names verbatim, **no `Header.h1` mapping**
  (PLAN Q1 decision: no platform-native renaming).
- ⇒ still need a deterministic `toSwiftIdentifier()` + collision check: strip the redundant
  `spacing-spacing-`/`colours-` group prefixes into nested enums, handle leading-digit leaves
  (`-800`, `-0`, `-12`), map `-` segments to nested types / camelCase. J3 stands.

## Two epic assumptions OVERTURNED
1. **Fonts are NOT licensed/blocked.** brand = **Libre Baskerville** (free, OFL — Google Fonts),
   primary-ios = **SF Pro** (system font). The epic's "P3b externally blocked on licensed
   freightBook/circular `.otf`" is **wrong** — the doc-comment family names in the current Swift were
   never the real design intent. Only work for the font swap: bundle Libre Baskerville `.otf`
   (freely available); SF Pro needs no bundling. **P3b is effectively unblocked.**
2. **Spike is unblocked and essentially complete** — the contract is fully documented in-repo; no
   private-repo credential dance needed (the user has a local clone). Epic M3's "blocked on creds"
   no longer applies.

## iOS load list (concrete) for the generator
Load into one name→token map: `.primitives.alfie-theme`, `theme.alfie-theme`, `sizing.alfie-theme`,
`typography.alfie-theme`, `typography.styles`, `system.ios`, `screen-size.small-(s)`. Skip
`system.{android,web}`, `screen-size.{m,l,xl}`, `.documentation`, and `~~doc-*` tokens. Honor both
allowlists. Emit: `Primitives.{Color,Spacing,FontSize,LineHeight,…}`, semantic `Theme.*` as references
to primitives, `Typography.<group>.<style>` composites, `Sizing.*` (radii/icons/padding).

## Net effect on the red-team findings
- **J1 (cross-file merge)** — confirmed + refined: manifest-driven, mode-selected load. **RESOLVED in design.**
- **J2 (composite tokens)** — confirmed real; shape now known. **RESOLVED in design.**
- **J4 (color formats/alpha)** — corrected: sRGB float components, no hex, no alpha today. **Simplified.**
- **J5 (px/rem units)** — corrected: px-only; keep a defensive unknown-unit error. **Downgraded.**
- **NEW — allowlist handling** — cycles + broken refs are allow-listed, not hard errors. Plan's
  resolver contract must change. **Add to P1.**
- **J3 (identifier safety)** — confirmed; target naming given by PLAN.md. **Stands.**
- **C1/C2/C3** (gating / stale-output / determinism) — unchanged, still required.
