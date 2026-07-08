## Phase 2: Migrate spec classes to tokens
### Goal
Re-point `TypographyHeader/Paragraph/Small/Tiny` at the generated tokens via the Phase-1 bridge,
removing hardcoded sizes/weights/family, while keeping the `header/paragraph/small/tiny` API stable.

### Acceptance criteria
- [ ] Every `UIFont` var in the four spec classes derives from a `Typography.*` token (per the
      approved mapping) — zero `FontNames.sfProMedium.withSize(N)` literals remain in the specs.
- [ ] AttributedString builders (String + `LocalizedStringResource`) still return styled text for all
      variants (normal/italic/bold/boldItalic/underline/strike).
- [ ] Pre-existing bug fixed: `TypographyHeaderProtocol.swift:64` `h3(_ res:)` calls `h3(...)`, not `h2`.
- [ ] `TypographyDemoView` still renders all levels; snapshot baselines refreshed.

### Mapping (decided — see plan.md Decisions)
`h1→Heading.large` · `h2→Heading.medium` · `h3→Heading.small` · `paragraph.*→Body.medium` ·
`small.*→Body.small` · `tiny.*→Body.small`. Font metrics only (family/weight/size). All variants of
a scale read the same base token (no synthesized bold/italic).

### Steps
1. **Header** (file: `.../Specifications/TypographyHeaderProtocol.swift:31-33,64`, size: S)
   — `h1→Typography.Heading.large.uiFont`, `h2→Heading.medium`, `h3→Heading.small`; fix the
   `h3(_ res:)`→`h2` typo (line 64).
2. **Paragraph** (file: `.../Specifications/TypographyParagraphProtocol.swift:45-48`, size: S)
   — all of `normal/normalItalic/bold/boldItalic` → `Typography.Body.medium.uiFont`.
3. **Small** (file: `.../Specifications/TypographySmallProtocol.swift:41-44`, size: S)
   — all variants → `Typography.Body.small.uiFont` (14→12).
4. **Tiny** (file: `.../Specifications/TypographyTinyProtocol.swift:32-35`, size: S)
   — all variants → `Typography.Body.small.uiFont`.
5. **FontNames cleanup** (file: `.../Helpers/FontNames.swift`, size: S)
   — after migration, grep for remaining `FontNames.sfProMedium` uses; if none, remove the
   `withSize` size-hardcode path. Keep `FontManager` registration only if a bundled font is still
   referenced elsewhere.
6. ~~Refresh snapshots~~ **N/A** — the snapshot test files are not in the `AlfieTests` target
   membership (`ProductDetailsViewSnapshotTests.swift:8` "TODO: Re-add Target Membership once
   Snapshot tests are checked for working properly"), so they don't compile/run in verify or CI.
   No baseline refresh needed; re-enabling them is out of scope.

### Checkpoint
- [ ] `./Alfie/scripts/verify.sh` passes.
- [ ] Manual: `TypographyDemoView` shows each level at the token size/weight.
- [ ] Grep: no hardcoded font size/weight/family in `Theme/Typography/`.

### Depends on
Phase 1 (+ the mapping decisions from the grill/approval gate)
