# Phase 3 (DebugMenu migration) — dev-2 summary

Branch: `ALFMOB-266-dev2-debugmenu` (based on `ALFMOB-266-integrate-typography-tokens`).
Commit: `ALFMOB-266: Migrate DebugMenu typography call sites to Figma token API`
(36 files changed, +180 / -177).

## Scope

Every `*.swift` under `Alfie/AlfieKit/Sources/DebugMenu/` referencing
`theme.font.(header|paragraph|small|tiny)` — 36 files. No SharedUI or feature-module files touched.

## Mapping applied (mechanical)

- `.header.h1/h2/h3(x)` → `.heading.large/medium/small(x)`
- `.paragraph.normal/italic/bold/boldItalic(x)` → `.body.medium(x)`
- `.small.normal/italic/bold/boldItalic(x)` → `.body.small(x)`
- `.tiny.normal/italic/bold/boldItalic(x)` → `.body.small(x)`
- bold/italic distinctions intentionally dropped (collapsed into the new token group).
- underline/strike variants only occurred in `TypographyDemoView` (rewritten by hand); no
  underline/strike call sites existed elsewhere in DebugMenu, so no `underline:`/`strike:`
  param injection was needed in the bulk pass.

The 138 function-call renames were applied by a one-shot Python string-replace anchored on the
trailing `(` (so UIFont-property sites could not be matched accidentally). UIFont sites were
edited by hand first.

## UIFont sites (got `.uiFont`)

- `ModalDemoView.swift:29,55` — `theme.font.header.h3.withSize(18).font`
  → `theme.font.heading.small.uiFont.withSize(18).font`
- `FeatureToggleView.swift:16` — `Font(theme.font.paragraph.bold.withSize(20))`
  → `Font(theme.font.body.medium.uiFont.withSize(20))`
- `ShimmerDemoView.swift:54` — `shimmeringMultiline(..., font: theme.font.small.normal)`
  → `font: theme.font.body.small.uiFont`. **Note:** `shimmeringMultiline(font:)` takes a
  `UIFont`, so `theme.font.small.normal` here resolved to the legacy `var normal: UIFont`
  property (not the `func normal(_:)` overload) — hence `.uiFont`, not a function call.

## TypographyDemoView

Rewrote to showcase the five new token groups (display / heading / body / label / link) instead
of the legacy tiers. Demos underline/strike via the new `underline:`/`strike:` params on
`body.medium`/`body.small`, plus the dedicated `body.mediumStrikethrough` token. Full demo
redesign was out of scope; this is the minimal "list the new groups" edit.

## Type-soundness reasoning (no full host build)

All migrated function-call sites pass a `String` (literals, `String`-typed vars, or
`localizedName(for:) -> String`) to `ThemedTypographyStyle.callAsFunction(_ string: String, ...)`
→ `AttributedString`, consumed by `Text.build(_ attributedString: AttributedString)`. The String
-only `callAsFunction` (no `LocalizedStringResource` overload) is sufficient — no call site in
DebugMenu passed a `LocalizedStringResource`. The three UIFont sites use `.uiFont` (UIFont),
matching `.withSize`/`Font(_:)`/`shimmeringMultiline(font:)` which all expect UIFont.

`swift build` on the macOS host is not viable for this iOS-only package (platform-floor errors
unrelated to this change); the integration owner runs `verify.sh` (Xcode / iOS simulator) once.

## Grep gate

```
grep -rE '\.font\.(header|paragraph|small|tiny)' Alfie/AlfieKit/Sources/DebugMenu --include='*.swift'
→ (no matches, exit 1)
```

## Ambiguous / noteworthy sites

- ShimmerDemoView:54 (described above) — the only legacy property-as-UIFont site in scope; the
  rest of `theme.font.small.*` in Shimmer are function calls migrated to `.body.small(...)`.
- No `h3Underline` or paragraph/small/tiny `*Underline`/`*Strike` call sites existed outside
  TypographyDemoView, so the bulk pass needed no param injection.
