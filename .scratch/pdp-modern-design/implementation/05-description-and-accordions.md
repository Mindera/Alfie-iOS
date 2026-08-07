# 05 — Description, product reference and accordion rows

**What to build:** The product description reads as plain body text rather than sitting behind a tab control. Beneath it, a metadata line shows the selected colour name and the product reference; when either is unavailable that part is omitted rather than rendering blank.

Below that, the complementary information rows — delivery, payment options and returns — become genuine accordions built on the shared accordion component. Each row shows an expand indicator, and tapping it expands the row in place to reveal a link through to the corresponding information, instead of navigating away immediately.

**Blocked by:** 01

**Status:** ready-for-agent

- [ ] The description renders as plain body text and the tab control is gone
- [ ] A metadata line shows the selected colour name and product reference, degrading gracefully when either is missing
- [ ] Complementary information rows use the shared accordion component, replacing the bespoke row
- [ ] Tapping a row expands it in place; the expanded panel offers a link to the existing information
- [ ] The shared accordion component is migrated to design tokens
- [ ] Row titles and their destinations are unchanged from today
- [ ] Dead constants left behind by the removed bespoke row are deleted
- [ ] New strings added to the string catalogue and the SwiftGen checksum regenerated
- [ ] Snapshot baselines updated
- [ ] `./Alfie/scripts/verify.sh` passes

**Notes.** The shared accordion component is currently used only by a debug demo, so migrating it is low-risk — but confirm that before editing.

Embedding the web content directly inside the expanded panel was considered and rejected: a web view inside a disclosure group inside a scroll view brings nested scrolling and indeterminate height, on a screen that already carries an image carousel.

Whether the row should expand to a link at all, rather than keeping today's single-tap navigation, is out with design — it trades a one-tap journey for two. If design prefers navigation, this ticket becomes a restyle of the existing row.

The product reference is the variant SKU; the design's exact reference format has no field behind it.

Detail: `Docs/Specs/Features/ProductDetailsModernDesign.md`
