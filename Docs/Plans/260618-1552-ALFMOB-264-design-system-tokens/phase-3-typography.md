## Phase 3: Typography (ALFMOB-266) — split 3a / 3b (red-team C3/C4)

The original single phase assumed a "thin" shim and bundled fonts. Reality: ~15 `UIFont` getters
and ~70 `AttributedString` builders across h1/h2/h3/paragraph/small/tiny (normal/bold/italic/
underline/strike), and only `SF-Pro-Display-Medium.otf` is bundled — today the code renders **every**
level/variant in SF Pro despite doc-comments naming `freightBook`/`circularBold`/`circularMedium`.
So: do the nameable, shippable work in **3a**; isolate the externally-blocked font swap in **3b**.

---

## Phase 3a: Figma-name typography + compat shim (shippable, keeps SF Pro)

### Goal
Generate Figma-verbatim typography tokens (`Typography.display.large`, `heading.medium`, `body.small`,
…) and re-implement the legacy `header/paragraph/small/tiny` protocols to forward to them. Sizes/
weights/line-heights/letter-spacing come from tokens; **font family stays SF Pro** until 3b. Every
call site (`ThemeProvider.shared.font.header.h1(...)`) keeps compiling.

### Depends on
Phase 1 (generator) + the agreed legacy→Figma mapping table (Open Q2 — design sign-off, BLOCKS 3a).

### Steps
1. **Mapping table** (design sign-off) — map all ~15 getters: `h1/h2/h3 → display/heading.*`,
   `paragraph(normal/bold/italic) → body.*`, `small → body.small/label.*`, `tiny → label.small`, etc.
   Underline/strike stay render-time flags (`.build(isUnderlined:strike:)`), NOT separate tokens.
   Record in `Docs/DesignTokens.md`. *Do not guess — pull the real ramp first.*
2. **Emit typography** (`GeneratedTokens/Typography+Generated.swift`) — per token: family (SF Pro for
   now), size, weight, line-height, letter-spacing; shaped to feed
   `AttributedString.build(font:lineHeight:letterSpacing:…)` (`Helpers/Font+Extensions.swift:7`).
3. **Shim the concrete classes** (`Specifications/TypographyHeaderProtocol.swift:30`,
   `TypographyParagraphProtocol.swift:44`, `TypographySmallProtocol.swift:40`, `TypographyTinyProtocol.swift:31`)
   — replace hardcoded `FontNames.sfProMedium.withSize(36)` with token-derived metrics; preserve all
   ~70 builder method bodies + `UIFont` getter signatures verbatim.
   - Conscious decision on the pre-existing bug `TypographyHeader.h3(_ res:)` → calls `h2(...)`
     (`:63–65`): fix or preserve? If preserved, the eventual P6 baseline locks it in — file as separate ticket (m3).
4. **TypographyProvider** (`TypographyProvider.swift:14`) — surface unchanged; now token-backed.

### Verification
- `./Alfie/scripts/verify.sh` → `✅ FULL VERIFICATION PASSED`.
- Manual review: text geometry may shift if token sizes ≠ current (36/24/20/16/14/12) — accepted per
  validation (tokens = source of truth). RTL still correct. Final baselines captured in P6.

### Estimated Effort
M–L (the ~15→~70 mapping is the bulk; gated on the mapping table).

---

## Phase 3b: Real font-family swap (EXTERNALLY BLOCKED — do not bundle into 3a)

### Goal
Replace SF Pro with the actual token-referenced families (`freightBook`/`circular*`).

### Blocker
The `.otf` files are **not in the repo** and are licensed assets the team must source. Until they
arrive, 3b cannot start; "Figma-verbatim typography" is cosmetic (names only). This is Open Q1.

### Steps (when unblocked)
1. Obtain + license `.otf`s; add under `Theme/Typography/Resources/`; add to `Package.swift` resources
   (`.copy`) + `Fonts.xcassets`.
2. Extend `FontNames` cases + `FontManager.registerAll()` (note: currently runs in preview mode only —
   ensure runtime registration for app-wide use).
3. Re-point the generated typography family fields from SF Pro → the new families; regenerate.

### Verification
- `./Alfie/scripts/verify.sh` → `✅ FULL VERIFICATION PASSED`; fonts render on device (not just preview).
- P6 baselines re-recorded intentionally (this is a deliberate visual change).

### Estimated Effort
M once fonts exist; **indefinitely blocked** until they do.
