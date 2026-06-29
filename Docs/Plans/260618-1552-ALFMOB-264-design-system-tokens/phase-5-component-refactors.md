## Phase 5: Component refactors + snapshot harness (ALFMOB-271/268/273/269/267)

### Goal
Refactor the 5 core components to consume token-generated values; keep every public API
backward-compatible; establish the SharedUI snapshot harness (none exists today) and baseline each
component before/after.

### Depends on
Phases 2–4 (color/typography/spacing/shape are token-backed). After P2–P4 most refactors are
already partly done (components read `Colors.*`/`Spacing.*`/`CornerRadius.*` which are now token-backed);
remaining work = replace any **hardcoded literals** inside each component + add snapshot tests.

### Verification approach (no component snapshot guard yet)
The SharedUI snapshot harness + baselines are built in **P6 (last)**, not here — per stakeholder,
baselining components mid-refactor has no value when tokens are the source of truth and the look is
expected to change. During P5, verify each component via `verify.sh` (build + unit tests) + manual
visual review of all states + the existing app-level snapshots (`Alfie/AlfieTests/Snapshots/`). The
final token-driven appearance is captured as the regression baseline in P6.

### Per component

1. **ThemedButton** (ALFMOB-271) — `Theme/Buttons/ButtonTheme.swift:23`, `ThemedButton.swift:5`
   - `ButtonThemeSpec` literals (`Colors.primary.mono900/500/300/100`, `.white`, `Spacing.space100/200`,
     `CornerRadius.s`, fonts) → token refs. Cover 4 styles × 3 sizes × {normal,disabled,pressed,loading}.
   - Owner: dev-1.

2. **ThemedInput** (ALFMOB-268) — `Theme/Inputs/ThemedInput.swift:5`
   - Per-state border/bg/placeholder/error/success colors, `CornerRadius.xs`, `Spacing.*`, fonts → tokens.
   - States: empty/info/success/error + disabled + icon + char-limit. Owner: dev-2.

3. **Chip** (ALFMOB-273) — `Components/Chips/Chip.swift:44`
   - Colors/`Spacing.*`/`CornerRadius.full`/fonts → tokens; replace hardcoded heights (36/44) +
     border widths (1.0/2.0) with token sizing if tokens define them, else keep + comment.
   - Selected/unselected. Owner: dev-2.

4. **Badge** (ALFMOB-269) — `Components/Indicators/BadgeViewModifier.swift:9`, `BadgeTabViewModifier.swift:9`
   - `Colors.secondary.red700`, `.white`, `CornerRadius.full`, `theme.font.tiny`, hardcoded sizes
     (badgeHeight 16, paddings 4, indicator 12, border 1) → tokens where defined.
   - `BadgeTabViewModifier` also sets `UITabBarItem.appearance()` — keep. Counts 1/9/99/999+.
     `BadgeHelperTests` must stay green. Owner: dev-3.

5. **Typography/Label** (ALFMOB-267) — `Theme/Typography/**`
   - Largely satisfied by Phase 3. This story = **verification**: grep the render path for any
     remaining hardcoded font size/weight/family; confirm `AttributedString`/`UIFont`/`Text.build`
     all flow through tokens. Owner: dev-3.

### Backward-compat rule
No initializer / enum-case signature changes (`ButtonType`, `ButtonTheme`, `InputStatus`,
`ChipConfiguration`, `badgeView`/`tabItemBadge`). If a token-driven value forces an API change, stop
and raise — the epic AC forbids call-site churn.

### Verification
- `./Alfie/scripts/verify.sh` → `✅ FULL VERIFICATION PASSED` after each component.
- Manual visual review of every state per component (token-driven changes accepted per validation).
- App snapshots in `Alfie/AlfieTests/Snapshots/` — diffs reviewed/accepted, not auto-blocking.
- Component snapshot baselines are recorded later in **P6**.

### Estimated Effort
M per component (L total). Parallelizable across dev-1/2/3 once P2–P4 land (generated files
owned by dev-1 to avoid merge churn).
