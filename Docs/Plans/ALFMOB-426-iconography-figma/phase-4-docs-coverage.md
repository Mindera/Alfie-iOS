## Phase 4: Docs + appearance coverage

### Goal
Document how to re-export icons from Figma, and lock in appearance coverage via unit tests
(snapshots being disabled repo-wide).

### Acceptance criteria
- [ ] `Docs/Iconography.md` documents: Figma file/page (key `PWVgEoKrIw9Hv7QlOCcUoq`, node 3001-7582),
      the name→node-ID map, how to export (MCP `download_figma_images` and/or manual SVG export),
      catalog conventions (template + preserve-vector, kebab-case naming), Fill + OS-variant handling,
      and how to add/replace an icon end-to-end.
- [ ] Catalog-completeness unit test: every in-scope Figma name (from the documented map) has an
      imageset in `Icons.xcassets` — fails if an icon is added to the map but not bundled (and vice-versa).
- [ ] "no in-scope case resolves via `systemName`" assertion in place (guards accidental regressions).
- [ ] `verify.sh` green.

### Steps
1. **Re-export runbook** (file: `Docs/Iconography.md`, size: S) — step-by-step + the node-ID table
   (lift from `scope.md`). Link from `Docs/QuickReference.md` if that index lists design-system docs.
2. **Completeness + guard tests** (file: `AlfieKit/Tests/SharedUITests/IconTests.swift`, size: S) —
   finalize the in-scope catalog-completeness test and the systemName-regression guard.

### Checkpoint
- [ ] `./Alfie/scripts/verify.sh` passes
- [ ] Doc reviewed for accuracy against the shipped catalog
- [ ] Manual: none

### Depends on
Phase 1, Phase 2 (Phase 3 optional for docs)
