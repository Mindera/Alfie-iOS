# Alfie

A native iOS storefront for a fashion retailer, backed by a GraphQL BFF that fronts a commerce
platform (Shopify or BigCommerce). This glossary fixes the vocabulary for the catalogue and for the
physical-retail features that reach into it.

## Language

### Catalogue

**Product**:
A style offered for sale, independent of colour and size. What a PDP is about.
_Avoid_: item, article, SKU

**Handle**:
The identifier that addresses a Product in the BFF and in a link. On Shopify it is the platform's
native product handle; on BigCommerce it is a site route path, so it may contain `/`.
_Avoid_: slug, product ID

**Variant**:
A Product in one specific colour and size. The thing a shopper physically picks up and buys.
_Avoid_: option, size, item

**SKU**:
The retailer's identifier for a Variant. The value the app matches on when preselecting which
colour and size a shopper arrives on.

### Physical retail

**Swing tag**:
The card attached to a garment in store, carrying its printed identifiers.

**Barcode**:
The machine-readable number already printed on a Swing tag (EAN-13 or UPC-A). It identifies a
Variant, is issued by the manufacturer, and holds only digits — it cannot carry a Handle.
_Avoid_: EAN, UPC, GTIN (use these only when the specific symbology matters)

**Alfie code**:
A QR code Alfie generates and prints, encoding a link to a Product and the Variant it is attached
to. Distinct from a Barcode: it is ours, it is not digits-only, and it needs no catalogue lookup to
interpret.
_Avoid_: QR, product code, scan code
