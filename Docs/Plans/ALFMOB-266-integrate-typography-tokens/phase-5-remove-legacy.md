## Phase 5: Remove the legacy typography system

### Goal
Once no call site references them (Phases 2-4 merged), delete the legacy typography types and the
provider's legacy group properties, completing the cutover to the token-driven API.

### Acceptance criteria
- [ ] `TypographyHeaderProtocol/Paragraph/Small/Tiny` + `TypographyHeader/Paragraph/Small/Tiny`
  deleted; `TypographyProviderProtocol`/`TypographyProvider` expose only `display/heading/body/
  label/link`.
- [ ] `ThemeProvider.setupAppearance()` uses `font.heading.small.uiFont`.
- [ ] No reference to the deleted symbols anywhere; `verify.sh` green.

### Steps
1. **Delete legacy specs** (files: `Specifications/TypographyHeaderProtocol.swift`,
   `TypographyParagraphProtocol.swift`, `TypographySmallProtocol.swift`, `TypographyTinyProtocol.swift`,
   size: S) — remove files.
2. **Trim provider** (file: `TypographyProvider.swift`, size: S) — drop legacy `header/paragraph/
   small/tiny` properties + protocol requirements + their default-init params.
3. **Update appearance** (file: `ThemeProvider.swift`, size: XS) — `font.header.h3` →
   `font.heading.small.uiFont`.
4. **Final grep gate** — `grep -rE 'TypographyHeader|TypographyParagraph|TypographySmall|
   TypographyTiny|font\.(header|paragraph|small|tiny)\b'` over `source_roots` returns nothing.

### Checkpoint
- [ ] `./Alfie/scripts/verify.sh` passes (full run).
- [ ] Acceptance criteria met; legacy system fully removed.

### Depends on
Phase 2, Phase 3, Phase 4
