## Phase 1: Codegen + second theme (foundation)

### Goal
The design-token generator can emit more than one colour theme, and a second theme "selfFridge"
exists. The app still builds green and looks identical (defaults to alfie) — no runtime switching yet.

### Acceptance criteria
- [ ] `TokenLoader` parses hex colour `$value` strings (`"#RRGGBB"`, `"#RRGGBBAA"`) into components.
- [ ] `.primitives.selffridge-theme.tokens.json` exists with the 27 slate colours under the exact
      Alfie primitive names; `manifest.json` lists it as a `selffridge-theme` mode of `.primitives`.
- [ ] Generated output contains `ColourPalette`, `AppTheme` (`.alfie`, `.selfFridge`), and a
      `ThemeColours.current` holder; `Primitives.Colours.*` are computed vars reading the holder.
- [ ] Semantic `Theme`/`Sizing`/`Typography` generated files are unchanged in shape (still symbol refs).
- [ ] Generator unit tests cover hex parsing and multi-theme emission and pass (`swift test`).
- [ ] `./Alfie/scripts/verify.sh` passes; zero edits to existing `Primitives.Colours.*` call sites.

### Steps
1. **Hex colour parsing** (file: `Tools/DesignTokenGen/Sources/DesignTokenGenCore/TokenLoader.swift`, size: S)
   — in `parseValue` `case "color"`, accept a `String` hex value (3/4-channel) → `[Double]` components
   (0…1), keeping the existing `{components}` path. Reference strings (`{…}`) still short-circuit first.
   Add a small `hexToComponents` helper. Test to add: hex→components (opaque + alpha).
2. **selfFridge token file** (file: `.../SharedUI/DesignTokens/.primitives.selffridge-theme.tokens.json`, size: S)
   — 27 colours from `~/Downloads/theme.slate-theme.tokens.json` under identical Alfie primitive
   names. Colours only (non-colour primitives come from the alfie base). No semantic file needed
   (semantic layer is theme-independent); if a semantic file is added later, normalize the 2
   destructive refs to `{surface-background-destructive}` to match Alfie.
3. **Manifest** (file: `.../SharedUI/DesignTokens/manifest.json`, size: XS) — add `selffridge-theme`
   mode under the `.primitives` collection pointing at the new file.
4. **Loader: per-theme palettes** (file: `TokenLoader.swift`, size: M) — load each `.primitives.*`
   mode into a separate colour map keyed by theme id; keep `alfie` as the base driving `map` /
   `primitiveValues` for Theme/Sizing/Typography resolution. Expose the per-theme colour sets to the
   emitter (extend `LoadedTokens`). Avoids the current last-writer-wins clobber.
5. **Emitter: palettes + holder + computed colours** (file: `Emitter.swift`, size: L) —
   - New emitted file `ThemeColours+Generated.swift`: `struct ColourPalette` (27 `let Color` members
     + memberwise init); `enum AppTheme: String, CaseIterable { case alfie, selfFridge; var palette:
     ColourPalette; var displayName: String }`; `enum ThemeColours { static let <theme> =
     ColourPalette(<literals>) …; static var current: ColourPalette = alfie;
     static func apply(id: String); static func apply(_ theme: AppTheme) }`.
   - `emitPrimitives`: for the `Colours` group only, emit `public static var <id>: Color {
     ThemeColours.current.<id> }` instead of `static let <literal>`. Other groups unchanged.
   - `displayName` may derive from a simple prettified id in the emitter, or be left to the app layer
     — keep user-facing text out of generated code if trivial (decide in impl; default: app layer).
6. **Generator tests** (file: `Tools/DesignTokenGen/Tests/DesignTokenGenCoreTests/*`, size: M) —
   extend `GeneratorTests`/`CoverageTests` for hex input and for a two-theme fixture asserting
   `AppTheme.allCases == [.alfie, .selfFridge]` and distinct palette values.
7. **Regenerate** (size: S) — run `./Alfie/scripts/generate-design-tokens.sh`; review `git diff` of
   `SharedUI/GeneratedTokens/`; confirm only colour accessors changed shape + new file added.

### Checkpoint
- [ ] `swift test --package-path Tools/DesignTokenGen` passes (run by the generate script).
- [ ] `./Alfie/scripts/verify.sh` passes.
- [ ] Acceptance criteria above all met.
- [ ] Manual: app launches, colours identical to before (alfie default).

### Depends on
none
