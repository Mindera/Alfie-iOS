# 04 — Colour selection

**What to build:** A shopper choosing a colour sees the options without losing their place. Products with a small number of colours show them inline as a card grid — swatch above colour name — between the call-to-action and the description. Products with many colours open a sheet listing them.

The selected colour is marked with a border on its swatch. The previous inline swatch row and its accompanying picker are no longer used on this screen.

**Blocked by:** 01

**Status:** ready-for-agent

- [ ] Few-colour products show an inline colour card grid
- [ ] Many-colour products open a colour sheet
- [ ] Which surface appears is decided by the shared rules type
- [ ] The selected colour is indicated by a border on its swatch
- [ ] Single-colour and no-colour products show no colour section at all
- [ ] The colour sheet is restyled to the design and rebuilt on the shared modal component rather than its current hand-rolled header and rows
- [ ] The hardcoded font-size override in the sheet is removed
- [ ] The fallback swatch colour for invalid swatch images comes from a design token, and its pinning test is updated accordingly
- [ ] Snapshot baselines updated
- [ ] `./Alfie/scripts/verify.sh` passes

**Note.** When each of the three colour surfaces appears is an inference, not a design instruction — the design shows all three but never says which applies when. The assumption mirrors the size rule and lives in the shared rules type.

Detail: `Docs/Specs/Features/ProductDetailsModernDesign.md`
