---
status: accepted
---

# Resolve Barcodes through the BFF on SCAYLE

ADR-0001 printed an **Alfie code** because the BFF could not resolve a **Barcode**. On SCAYLE it now
can: `productByBarcode(barcode:)` (Alfie-BFF PR #46) filters the catalogue by the `ean` attribute and
returns the Product's id, plus the Variant's id when exactly one Variant carries the code. The
scanner therefore resolves an EAN-13 Barcode through the BFF and opens the Product it names. Alfie
codes are still printed and still win when both are in frame, because they need no lookup.

## Considered options

- **Keep ignoring the Barcode (ADR-0001 as is).** Rejected for SCAYLE. Most garments carry only the
  manufacturer's Barcode, so a Barcode that opens nothing strands the shopper on every untagged item.
- **Tell a Barcode from a QR code by the payload's shape** (thirteen digits, valid check digit).
  Rejected. The camera already reports the symbology it read, so the heuristic was guessing at
  something it could be told. A QR code holding thirteen digits is not a Barcode.
- **Resolve a shared Barcode to a Variant anyway.** Rejected. When several Variants share a Barcode
  the BFF returns the Product only, and the PDP falls back to its default Variant rather than
  preselecting a colour or size the shopper did not pick up.

## Consequences

- SCAYLE only. On Shopify and BigCommerce the query is not implemented, so a scanned Barcode shows
  the generic lookup-failed notice.
- The handoff reuses the deep-link path: `alfie://alfie.target/product/<id>?variantId=<id>`. The PDP
  preselects by SKU, then Variant id, then its default Variant.
- A scan now waits on the network. While a lookup is in flight the camera keeps running but every
  code, including an Alfie code, is ignored, and closing the scanner cancels the lookup.
