# Slice 6 — Category-driven size layouts

**Epic:** ALFMOB-427 · **Blocked by:** no agreed category→layout mapping

## Why separate

The design has **four** size-selector layouts. Slice 1 ships two of them (chip grid, vertical list) chosen by size count. The other two are category-driven.

## Scope

- **Card grid with per-variant imagery** (food) — `variants.media` is already fetched.
- **Card grid with sub-label and price delta** (dimensioned goods) — e.g. `Small / 25x26x18 cm / -8€`.
- Select `OmniProduct.productType` (and/or `categories`) in `ProductDetailsFragment` — a one-line query change, no backend work.
- Drive layout selection from category rather than size count.

## Blockers

- **No agreed productType→layout mapping.** The schema fields exist; the mapping does not.

## Open questions (`.scratch/pdp-modern-design/to-questionnaire-pdp-control-behaviour.md`)

- Which product types map to which of the four layouts?
- Does category selection override the size-count rule from Slice 1, or combine with it?
