## Phase 2: Sizing literals + gap documentation

### Goal
Tokenize the one raw literal that has an exact token (`iconSize`), and document the literals that
genuinely have no token so the file honestly reflects token coverage.

### Acceptance criteria
- [ ] `Constants.iconSize` references `Sizing.iconsIconSmall` (== 16, identical rendering).
- [ ] `smallHeight/mediumHeight/bigHeight` (36/44/52) and the `lineWidth: 1` stroke carry a comment
      noting no design token exists (gap), so they are not mistaken for un-migrated values.
- [ ] `./Alfie/scripts/verify.sh` green.

### Steps
1. **iconSize → token** (file: `ThemedButton.swift:139`, size: XS) — `static let iconSize: CGFloat = Sizing.iconsIconSmall`.
   Why: `Sizing.iconsIconSmall` resolves to `Primitives.Spacing.spacing16` = 16 — same value, now tokenized (AC1).
2. **Document literal gaps** (file: `ThemedButton.swift:140-142,184`, size: XS) — add a comment above the
   height constants and the `.stroke(..., lineWidth: 1)` call: `// no design token for button height / 1pt stroke`.
   Why: makes the remaining literals intentional & reviewable, not oversights.

### Checkpoint
- [ ] `./Alfie/scripts/verify.sh` passes.
- [ ] Acceptance criteria above all met.
- [ ] Manual: previews unchanged (icon size 16 identical).

### Depends on
Phase 1 (same files region; keeps a single clean diff on ThemedButton.swift)
