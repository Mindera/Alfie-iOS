## Phase 1: Badge token migration

### Goal
Replace the remaining hardcoded sizing and raw-primitive color references in the two Badge view
modifiers with generated design tokens, with no visual change and no call-site change.

### Acceptance criteria
- [ ] All `BadgeViewModifier.Constants` numeric style values are token-backed, except the two with
      no token equivalent (`borderLineWidth`, `capsuleOffsetXFactor`), which stay literals with a
      brief comment noting no token exists.
- [ ] Badge colors reference the semantic `Theme.*` layer (fill / text / stroke) in both modifiers.
- [ ] Dead `badgePadding` constant removed.
- [ ] `BadgeHelperTests` green; label logic unchanged (AC2).
- [ ] Public API `badgeView(...)` / `tabItemBadge(...)` signatures unchanged (AC4); no call site edited.

### Steps
1. **Migrate sizing constants** (file: `SharedUI/Components/Indicators/BadgeViewModifier.swift:10`,
   size: XS) — in `Constants`, set `badgeHeight = Primitives.Spacing.spacing16`,
   `textPadding = Primitives.Spacing.spacing4`, `indicatorHeight`/`indicatorWidth =
   Primitives.Spacing.spacing12`. Remove unused `badgePadding`. Leave `borderLineWidth = 1.0` and
   `capsuleOffsetXFactor = 3` as literals (no token) with a one-line `// no design token` comment.
   Why: closes the actual token gap. Test: build (values identical → no behavior change).
2. **Elevate colors to `Theme.*`** (file: `SharedUI/Components/Indicators/BadgeViewModifier.swift:37`,
   size: XS) — fill `Theme.surfaceBackgroundDestructive`, text
   `Theme.contentContentInvertedPrimary`, stroke `Theme.surfaceBackgroundPrimary` (both `.fill`
   and `.stroke` sites in capsule + indicator branches). Why: semantic layer per design-system
   intent. Test: build; values resolve identically.
3. **Elevate tab-badge colors** (file: `SharedUI/Components/Indicators/BadgeTabViewModifier.swift:20`,
   size: XS) — `badgeColor = Theme.surfaceBackgroundDestructive.ui`; text attribute
   `.foregroundColor = Theme.contentContentInvertedPrimary.ui`. Font already tokenized. Why: AC3
   parity across both variants. Test: build.
   *(Grill dropped the optional AC2 label-test step — `BadgeHelperTests` already covers the
   below-max and above-max branches; `1`/`9` are redundant.)*

### Checkpoint
- [ ] `./Alfie/scripts/verify.sh` passes (build + unit; integration skippable — no BFF surface).
- [ ] All acceptance criteria above met.
- [ ] Manual: `BadgeDemoView` preview renders badge + indicator identically to `main`.

### Depends on
none
