## Phase 6: Snapshot harness & baselines (FINAL — moved from first, per stakeholder)

### Goal
Establish the SharedUI snapshot harness and capture the **final, token-driven** appearance of the 5
components as the going-forward regression baseline. Also audit theme-consumer coverage.

### Why this is LAST, not first
The original plan put this first to prove "no visual change." Validation decided **tokens are the
source of truth** — the look is *expected* to change across P2–P5 — so a pre-refactor baseline has no
assertion value and would just be re-recorded. Capture baselines once the components are stable.

**Accepted trade-off:** during P2–P5 there is **no component-level snapshot guard**. Refactor
regressions are caught instead by `verify.sh` (build + unit tests) + manual visual review + the
existing app-level snapshots (`Alfie/AlfieTests/Snapshots/`). This phase closes that gap permanently
for future design-system work. (This consciously overrides red-team C1's "baseline first" stance,
which assumed a no-visual-change refactor.)

### Depends on
P5 complete — all 5 components on final token values (and P3a typography settled). Do not record
baselines mid-refactor.

### Steps

1. **New snapshot target** (`Package.swift`) — add `SharedUISnapshotTests`, deps `["SharedUI", "TestUtils"]`
   (TestUtils already vends `SnapshotTesting` 1.18.3, `Package.swift:301`). Write a SharedUI-local
   snapshot helper using only public SharedUI API — do **not** reuse the app's
   `View+Snapshots.swift` (`@testable import Alfie`, not portable).

2. **Record final baselines** — ThemedButton (4 styles × 3 sizes × {normal,disabled,pressed,loading}),
   ThemedInput (empty/info/success/error + disabled + icon + char-limit), Chip (selected/unselected,
   small/large), Badge (1/9/99/999+, both modifiers), Label (h1–tiny incl. underline/strike/italic).
   These become the regression baseline for all future token changes.

3. **Coverage audit** — enumerate which app-wide theme consumers (`Colors.` 78 files / `Spacing.` 108 /
   typography 79) and which app screens in `Alfie/AlfieTests/Snapshots/` do/don't have snapshot
   coverage; record the gap so future work knows what's unguarded.

### Verification
- `./Alfie/scripts/verify.sh` → `✅ FULL VERIFICATION PASSED` with the new target recording + a clean
  no-op re-run.
- Baselines committed; re-running the suite passes (proves the harness is stable on final values).

### Estimated Effort
M–L (new target + SharedUI-local helper + 5 component baselines + coverage audit).
