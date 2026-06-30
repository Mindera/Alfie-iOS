## Phase 1: Spacing

### Goal
`Spacing.space*` constants resolve from generated `Primitives.Spacing.*` tokens instead of hardcoded
numbers, with the public API stable (names/`CGFloat` type/doc-comments) except the deleted `space900`.

### Acceptance criteria
- [ ] Every remaining `space*` constant forwards to `Primitives.Spacing.*` (mapping in `plan.md`) — no numeric literals.
- [ ] `space075` → `Primitives.Spacing.spacing8` (6→8pt) with a `// 6→8: nearest token, no spacing-6 (design sign-off)` comment.
- [ ] `space900` deleted from `Spacing.swift` AND its row removed from `SpacingDemoView`.
- [ ] Doc-comments (`/// 16pt`) preserved/updated on each constant (space075 doc → `/// 8pt`).
- [ ] `SpacingTokenTests` pins every `Spacing.space*` to its expected CGFloat (incl. `space075 == 8`) and asserts each `== Primitives.Spacing.*`.
- [ ] No other call-site changes; file lints clean (SwiftLint build phase).

### Steps
1. **Pin tests first (red→green)** (file: `Tests/SharedUITests/SpacingTokenTests.swift`, size: S) —
   `@testable import SharedUI`; assert the full scale (`space0==0 … space800==64, space1000==80`) with
   `space075 == 8`, and that each equals its generated source (`Spacing.space200 == Primitives.Spacing.spacing16`,
   `Spacing.space075 == Primitives.Spacing.spacing8`). Do NOT reference `space900` (it's being removed).
2. **Forward Spacing.swift** (file: `Theme/Spacing/Spacing.swift:6`, size: S) — set each remaining
   `static let` = its generated symbol (`public static let space200: CGFloat = Primitives.Spacing.spacing16`).
   `space075` → `Primitives.Spacing.spacing8` (update doc to `/// 8pt`, add the 6→8 comment). **Delete**
   the `space900` constant. `Primitives` is same-module (`SharedUI`) — no new import.
3. **Drop the demo row** (file: `DebugMenu/UI/Demo/Spacing/SpacingDemoView.swift`, size: XS) — remove the
   `spacingView(token: "space.900", …, Spacing.space900)` line (compile-breaks otherwise). Leave the
   `space.075` row (now renders 8pt).

### Checkpoint
- [ ] `./Alfie/scripts/verify.sh` passes (✅ FULL VERIFICATION PASSED).
- [ ] Acceptance criteria above all met.
- [ ] Manual: DebugMenu → StyleGuide → Spacing demo renders (075 row = 8pt, no 900 row); spot-check HorizontalProductCard / SortBy.

### Depends on
none
