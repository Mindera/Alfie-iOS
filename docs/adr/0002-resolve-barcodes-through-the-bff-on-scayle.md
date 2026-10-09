---
status: accepted
---

# Resolve Barcodes through the BFF on SCAYLE

ADR-0001 printed an **Alfie code** because the BFF could not resolve a **Barcode**. On SCAYLE it now
can: `productByBarcode(barcode:)` (Alfie-BFF PR #46) filters the catalogue by the Variant's `ean` and
returns the Product's id, plus the Variant's id when exactly one Variant carries the code. The
scanner therefore resolves a Barcode through the BFF and opens the Product it names. Alfie
codes are still printed and still win when both are in frame, because they need no lookup.

A Barcode here is the value, not the symbology: Selfridges price tags carry a GTIN-13 inside a **Code
128** symbol rather than an EAN-13 one, so the scanner recognises both and looks up either unchanged.

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
- `ean` is a first-class string on a SCAYLE Variant with its own `filters[ean]` parameter, not a
  tenant attribute. The generic attribute filter takes integer attribute ids and cannot carry a
  Barcode, so the lookup must stay off that path.
- SCAYLE stores `ean` as an unvalidated string and documents no normalisation and no exact-match
  guarantee for the filter, so we assume a byte-for-byte match. The Barcode is sent exactly as
  scanned, leading zeros included, and nothing normalises it on the way; the stored value has to be
  what the bars encode, not the digits printed beneath them.
- SCAYLE cannot say which Variant matched: the filter returns Products, and its storefront Variant
  carries no `ean`. Falling back to the Product when the Variant is ambiguous is the only behaviour
  the platform supports, not caution on our side.
- A Swing tag in production may encode a Variant's reference key instead of its `ean`, as SCAYLE's
  omnichannel guidance tells retailers to. Such a scan misses and looks identical to absent data.
  `/v2/search/resolve` matches either on the token the BFF already holds, but lets a category match
  beat a Product match.
- A scan now waits on the network. While a lookup is in flight the camera keeps running but every
  code, including an Alfie code, is ignored, and closing the scanner cancels the lookup.
