# Alfie

A native iOS storefront for a fashion retailer, backed by a GraphQL BFF that fronts a commerce
platform (SCAYLE, Shopify or BigCommerce). This glossary fixes the vocabulary for the catalogue and for the
physical-retail features that reach into it.

## Language

### Catalogue

**Product**:
A style offered for sale, independent of colour and size. What a PDP is about.
_Avoid_: item, article, SKU

**Handle**:
The identifier that addresses a Product in the BFF and in a link. On Shopify it is the platform's
native product handle; on BigCommerce it is a site route path, so it may contain `/`; on SCAYLE it
is the Product's name followed by its numeric id.
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
The machine-readable number already printed on a Swing tag (EAN-13 or UPC-A). Issued by the
manufacturer, it holds only digits and cannot carry a Handle, so it is resolved through the
catalogue (SCAYLE only). It usually identifies one Variant; when several Variants share it, it
resolves to the Product alone and no colour or size is preselected.
_Avoid_: EAN, UPC, GTIN (use these only when the specific symbology matters)

**Alfie code**:
A QR code Alfie generates and prints, encoding a link to a Product and the Variant it is attached
to. Distinct from a Barcode: it is ours, it is not digits-only, and it needs no catalogue lookup to
interpret.
_Avoid_: QR, product code, scan code, barcode (designs say "Scan Barcode" for the feature; the
thing scanned is still an Alfie code)

### Product listing

**Page request**:
One fetch of one page of a product listing. Exactly three kinds: **Refresh**, **First page**, **Next page**.
_Avoid_: Load more, following page, pagination request

**Refresh**:
A page request for page 1 triggered by pull-to-refresh, usually over loaded products. A refresh over a blocking error that fails stays a blocking error.

**First page**:
A page request for page 1 made when there are no loaded products (screen open, filter or sort applied, retry).

**Next page**:
A page request for the page after the last one loaded, triggered by scrolling to the last product.
_Avoid_: Load more

**Loaded products**:
Real products currently on screen. Skeleton placeholders are not loaded products.
_Avoid_: Grid, products on screen

**No results**:
A first page or refresh that finds no products to show. On a first page it is a blocking error; on a refresh over loaded products, a transient error.
_Avoid_: Empty error

**Blocking error**:
A page request failure shown as a full-screen error that replaces the listing. Only raised when there are no loaded products.
_Avoid_: Error screen, full-screen error

**Transient error**:
A page request failure shown as a dismissible Snackbar over loaded products, which stay on screen.
_Avoid_: Refresh error
