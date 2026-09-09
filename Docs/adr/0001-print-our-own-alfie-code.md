---
status: accepted
---

# Print our own Alfie code instead of reading the manufacturer's Barcode

For in-store scanning we print an **Alfie code** — a QR code containing
`https://<host>/product/<handle>?sku=<sku>` — rather than reading the EAN-13 **Barcode** already
printed on a garment's swing tag. A Barcode identifies a **Variant** and would have to be resolved
to a **Handle** through the catalogue, and the BFF cannot do that lookup with the credentials it
holds. Encoding the Handle directly removes the lookup entirely.

## Considered options

- **Resolve the Barcode through the BFF.** Rejected. Shopify's Storefront API — the only Shopify
  credential the BFF has — exposes `ProductVariant.barcode` as a readable field but offers no
  `barcode:` or `sku:` filter on `products(query:)`, and `search(query:)` is free-text relevance
  only. The documented route is Shopify's **Admin** GraphQL `productVariants(query: "barcode:…")`,
  which needs an Admin-scoped access token that a customer-facing BFF should not be holding.
  BigCommerce could reach `GET /v3/catalog/products?upc=…` with the management token it already
  has, but its adapter hardcodes `barcodes: []` and never queries the upstream field — so the
  platform conformance harness would demand new work on both platforms for a feature neither
  supports today.
- **Fuzzy-match the Barcode via `predictiveSearch` with `searchableFields: [VARIANTS_BARCODE]`.**
  Rejected. It is relevance matching with no exact-match guarantee. A scanner that usually returns
  the right garment is worse than no scanner.

## Consequences

- Only garments we have tagged with an Alfie code are scannable. A shopper scanning an ordinary
  swing tag Barcode gets an explanatory message, not a Product.
- Printing is now a dependency of the feature: adding Products to a demo means regenerating and
  reprinting codes.
- The app needs no new BFF query, no new credential, and no associated-domains entitlement, because
  the Handle arrives inside the code and the URL is parsed in-app.
- If in-store scanning ever becomes a production feature across a real estate of stock, this
  decision should be revisited — at that scale, tagging every garment is likely harder than
  provisioning an Admin credential.
