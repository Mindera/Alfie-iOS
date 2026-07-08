## Phase 0: Unblock build (fix token source + regenerate)
### Goal
Make the SharedUI module compile again by correcting the source-JSON defect that produced an
invalid `Typography+Generated.swift` (a `String` assigned to the `Int fontWeight` field).

### Acceptance criteria
- [ ] `typography.styles.tokens.json` `body-medium-strikethrough.fontWeight` references
      `{body-medium-strikethrough-font-weight}` (not `-font-family`).
- [ ] Regenerated `Typography+Generated.swift` line for `Body.mediumStrikethrough` reads
      `fontWeight: Primitives.Typography.fontWeightRegular`.
- [ ] Build compiles (`verify.sh` gets past the SharedUI compile error).

### Steps
1. **Fix source token ref** (file: `Alfie/AlfieKit/Sources/SharedUI/DesignTokens/typography.styles.tokens.json:27`, size: XS)
   — change `"fontWeight": "{body-medium-strikethrough-font-family}"` →
   `"fontWeight": "{body-medium-strikethrough-font-weight}"`. The target alias already exists
   (`typography.alfie-theme.tokens.json:54`, value `{typography-font-weight-regular}` = 400).
2. **Regenerate tokens** (size: XS) — run `./Alfie/scripts/generate-design-tokens.sh`; commit the
   regenerated `GeneratedTokens/Typography+Generated.swift`. Do **not** hand-edit the generated file.
3. **Raise upstream** (size: XS, non-code) — note in the PR / ticket that the Figma token source has
   the same binding defect so the fix isn't lost on the next `pull-design-tokens.sh`.

### Checkpoint
- [ ] `./Alfie/scripts/verify.sh` passes (or at minimum SharedUI compiles).
- [ ] Only the one composite changed; `git diff` on generated file shows exactly the one field flip.

### Depends on
none
