## Phase 2: CornerRadius

### Goal
`CornerRadius.*` cases resolve from generated radius/spacing tokens instead of hardcoded numbers,
with the public API (names, `CGFloat` type, swiftlint pragma, doc-comments) unchanged.

### Acceptance criteria
- [ ] All 8 cases forward to a generated symbol: `xs→Sizing.radiusSoft`, `l→Sizing.radiusStrong`, `full→Sizing.radiusRounded`; `none/xxs/s/m/xl→Primitives.Spacing.*` (mapping in `plan.md`).
- [ ] `swiftlint:disable discouraged_none_name identifier_name` pragma + `/// Npt` doc-comments preserved.
- [ ] `CornerRadiusTokenTests` pins every case to its expected CGFloat and asserts each `==` its generated source.
- [ ] No call site changes (no `.value` accessor introduced — bare CGFloat usage preserved).

### Steps
1. **Pin tests first** (file: `Tests/SharedUITests/CornerRadiusTokenTests.swift`, size: S) — assert
   `CornerRadius.none == 0 … full == 1000` (full set) AND each `==` its generated source
   (`CornerRadius.xs == Sizing.radiusSoft`, `CornerRadius.l == Sizing.radiusStrong`,
   `CornerRadius.full == Sizing.radiusRounded`, `CornerRadius.s == Primitives.Spacing.spacing8`, …).
2. **Forward CornerRadius.swift** (file: `Theme/CornerRadius/CornerRadius.swift:7`, size: S) — set each
   case = its generated symbol per the mapping. Keep the swiftlint pragma block and `/// Npt`
   doc-comments. No import change (`Foundation` already imported; `Primitives`/`Sizing` are same-module).

### Checkpoint
- [ ] `./Alfie/scripts/verify.sh` passes (✅ FULL VERIFICATION PASSED).
- [ ] Acceptance criteria above all met.
- [ ] Manual (optional): DebugMenu → StyleGuide → CornerRadius demo renders identically.

### Depends on
none (independent of Phase 1; ordered second for review clarity)
