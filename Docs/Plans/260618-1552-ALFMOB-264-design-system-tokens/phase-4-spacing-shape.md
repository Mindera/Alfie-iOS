## Phase 4: Spacing & shape integration (ALFMOB-270)

### Goal
Source `Spacing.*` and `CornerRadius.*` values (and shape border/shadow, if present) from generated
tokens. Keep the `Spacing.space200` / `CornerRadius.s` access patterns unchanged.

### Depends on
Phase 1 (generator emits spacing/radius).

### Steps

1. **Emit spacing + radius** (`SharedUI/GeneratedTokens/Spacing+Generated.swift`,
   `Radius+Generated.swift`)
   - Map token semantic names → the existing constants in `Theme/Spacing/Spacing.swift:6`
     (`space0`…`space1000`, 0–80pt) and `Theme/CornerRadius/CornerRadius.swift:7`
     (`none/xxs/xs/s/m/l/xl/full`).

2. **Forward the enums** — two viable shapes; pick one and apply consistently:
   - (a) keep `enum Spacing` / `enum CornerRadius` but set each `static let` = the generated value
     (`= GeneratedSpacing.space200`), or
   - (b) generate the enum directly and delete the hand-written one.
   - **Prefer (a)**: smallest diff, preserves the doc-comments + `swiftlint:disable` in
     `CornerRadius.swift:3`, zero call-site churn. AC "no hardcoded numeric values remain in theme
     files" is met because the literal now lives in the generated file.

3. **Shape** (`Theme/Shape/DefaultShapeProvider.swift:3`, `ShapeProviderProtocol.swift:4`)
   - Current protocol only exposes `unavailableCrossedOutShape()`. If tokens add border widths /
     shadows, extend the provider to read them; otherwise no change (don't invent surface — YAGNI).

### Verification
- `./Alfie/scripts/verify.sh` → `✅ FULL VERIFICATION PASSED`.
- App snapshots: spacing changes cascade across layouts — watch for diffs; baseline decisions per Open Q3.

### Estimated Effort
S–M
