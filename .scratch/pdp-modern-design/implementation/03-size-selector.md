# 03 — Size selector: grid, vertical list and stock states

**What to build:** A shopper can see every size a product comes in without opening anything. Products with a short size run show all sizes at once as boxed square chips in a grid; products with a long run (shoe sizes, for instance) show one full-width row per size, each able to carry its own price.

Selecting a size marks it with a heavier border rather than filling it. Sizes that cannot be bought are dimmed with their label struck through and a bell shown alongside — the bell is decoration in this ticket, not a control. Sizes running low carry a short message at the trailing edge.

The section is headed by its title on the left and a _Size Guide_ link on the right. That link has no destination yet, so it renders inert.

The size sheet is retired: long size runs are handled inline by the vertical list.

**Blocked by:** 01

**Status:** ready-for-agent

- [ ] Short size runs render as a grid of boxed square chips
- [ ] Long size runs render as a vertical list, with per-size price where available
- [ ] Which layout appears is decided by the shared rules type, not by logic inline in the view
- [ ] Selection is indicated by a heavier border, not by filling the chip
- [ ] Out-of-stock sizes are dimmed with a struck-through label and a bell indicator, and cannot be selected
- [ ] The bell exposes no tap target and no accessibility action, asserted by test
- [ ] The _Size Guide_ link renders as designed and is likewise inert, asserted by test
- [ ] Low-stock messaging appears at the defined thresholds
- [ ] The one-size case renders without the grid, and without the previous hand-assembled label
- [ ] The size sheet no longer has a caller
- [ ] New strings added to the string catalogue and the SwiftGen checksum regenerated
- [ ] Snapshot baselines updated
- [ ] `./Alfie/scripts/verify.sh` passes

**Notes.** The shared sizing components are consumed only by Product Details and one debug demo, so extending them is low-risk — add a vertical-list arrangement rather than building a bespoke view.

The chip border colour depends on a semantic token that does not yet exist upstream; until it lands, borders render lighter than designed.

Four rules here are inferences from static design frames rather than design instructions — the size-count threshold, the low-stock thresholds and their wording. They live in the shared rules type so they are cheap to correct once design confirms.

Detail: `Docs/Specs/Features/ProductDetailsModernDesign.md`
