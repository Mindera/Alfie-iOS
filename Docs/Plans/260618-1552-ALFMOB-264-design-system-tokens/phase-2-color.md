## Phase 2: Color integration (ALFMOB-274)

### Goal
Back `PrimaryColorsProtocol` / `SecondaryColorsProtocol` with generated token values instead of
`Colors.xcassets`. Keep `Colors.primary.*` / `Colors.secondary.*` call sites unchanged.

### Depends on
Phase 1 (generator emits `GeneratedColors`).

### Steps

1. **Emit colors** (P1 emitter → `SharedUI/GeneratedTokens/Colors+Generated.swift`)
   - **Reference graph (red-team M4):** only *primitives* hold hex (`Primitives.Color.neutralsXXX =
     Color(red:green:blue:opacity:)`). *Semantic* tokens are emitted as references to primitive
     symbols (`static let buttonPrimaryBackground = Primitives.Color.neutrals800`) — never a re-flattened
     literal. The protocol members below read the semantic/primitive symbols.
   - Map token names → the exact protocol members in `PrimaryColors.swift:20` (mono900…mono050,
     black, white) and `SecondaryColors.swift:52` (green/red/blue 050–900, yellow/orange 050–500).
   - **Verify cardinality**: protocol expects 10 mono; green/red/blue 050–900 (10 each); yellow/orange
     050–500 (6 each). If tokens differ, reconcile the protocol — don't silently drop.

2. **Re-point the structs** (`Theme/Color/PrimaryColors.swift:20`, `SecondaryColors.swift:52`)
   - Replace each `Color("Mono900", bundle:)` with the generated primitive
     (`GeneratedColors.mono900` / `Primitives.Color.…`). Protocol unchanged → zero call-site churn.

3. **Retire the asset catalog** (Option B)
   - **Dark mode = non-issue (red-team m1, CONFIRMED):** 53/54 colorsets are `idiom:universal`; the
     one dark variant (`Blue050`) is RGB-identical to light (no-op); no `overrideUserInterfaceStyle`/
     `preferredColorScheme` anywhere. So code-based `Color` loses nothing real. Proceed with Option B.
   - Grep repo-wide for direct asset access that bypasses the protocol:
     `Grep 'Color("'`, `'UIColor(named:'`, `'Colors.xcassets'` across `source_roots`.
     Any hit outside the two color files must be re-pointed first.
   - Delete `Theme/Color/Colors.xcassets`; remove `.process("Theme/Color/Colors.xcassets")` from
     `Package.swift:289`.
   - keep `Color.ui` extension + `Colors` accessor (`Color.swift`) as-is — `Color.ui = UIColor(self)`
     is a pure value conversion (`Utils/Extensions/Color+Extension.swift:4`), no asset lookup, so
     `ThemeProvider.setupAppearance()`'s `.ui` calls survive the deletion.

4. **`.ui` / UIColor path** — `ThemeProvider.setupAppearance()` (`ThemeProvider.swift:28,34,38,45,73`)
   uses `Colors.primary.*.ui`; confirm `Color.ui` still resolves once colors are code-based (no asset).

### Verification
- `./Alfie/scripts/verify.sh` → `✅ FULL VERIFICATION PASSED`.
- App snapshot suites in `Alfie/AlfieTests/Snapshots/` show **no diff** if token hex == current asset
  hex; any diff is a flagged baseline decision (Open Q3), not an automatic pass.
- Manual: visual spot-check of key screens (dark-mode parity already confirmed a non-issue, m1).

### Estimated Effort
M
