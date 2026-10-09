# Research: how SCAYLE models, stores, parses and resolves product barcodes

**Status:** current
**Date:** 2026-09-18

**Scope:** what SCAYLE's own documentation says about EANs on product variants — where the value
lives, how many there can be, how to look one up, whether it is validated, how it is ingested, and
what it takes to write one. Sources are SCAYLE's documentation pages and the OpenAPI specifications
their API reference renders from. Nothing else.

> **Method note.** SCAYLE's docs site serves every prose page as raw Markdown at `<url>.md`, and each
> API reference page renders a per-operation OpenAPI 3.1 document at
> `https://scayle.dev/open_api_specs/<api>-latest/<operation>.json`. All 679 prose pages listed in
> [`https://scayle.dev/llms.txt`](https://scayle.dev/llms.txt) were searched, so "Not documented"
> below means *absent from the whole corpus*, not merely "I did not find it".

---

## Summary

The single most important finding: **`ean` is a first-class, singular `string` property on SCAYLE's
`ProductVariant` entity — a sibling of `referenceKey`, not an attribute.** It is defined in the
Admin API schema with `maxLength: 55` and no format constraint
([spec](https://scayle.dev/open_api_specs/admin-api-latest/products_productIdentifier_variants_get.json),
[prose](https://scayle.dev/documentation/the-basics/products/manage-products-via-api/manage-product-variants)).
It is **not** one of SCAYLE's System Attribute Groups
([list](https://scayle.dev/documentation/the-basics/products/attribute-groups)).

Four consequences matter for us:

| Finding | Consequence |
|---|---|
| The Storefront API's `filters[ean]` is a **dedicated, documented query parameter** on `GET /v1/products`, not the generic attribute filter | Our BFF's URL is right even though its internal model ("an attribute named `ean`") is wrong |
| The generic SAPI attribute filter takes **integer attribute IDs** (`filters[brand]=882`), not strings | If the BFF ever routes `ean` through the generic path, it cannot work |
| The SAPI `ProductVariant` response schema has **no `ean` property**, and no `with=` include exposes one | SAPI can filter by EAN but never tells you *which variant* matched |
| SCAYLE documents `with=attributes:key(ean|shopSize)` as a variant-attribute example | A tenant-defined `ean` **attribute** also exists as a convention — a second, separate store |

The SCAYLE docs contain **zero** occurrences of "barcode" outside the Omnichannel add-on, and zero
occurrences of "GTIN", "UPC", "GS1", "check digit" or "leading zero" anywhere. There is no `Barcode`
type in SCAYLE.

---

## 1. Canonical field

### The canonical field is `ProductVariant.ean`

The Admin API `ProductVariant` schema defines it directly:

```json
"ean": {
  "type": "string",
  "description": "An ean that refers to a product variant .",
  "example": "0000007619991",
  "maxLength": 55
}
```

([`products_productIdentifier_variants_get.json`](https://scayle.dev/open_api_specs/admin-api-latest/products_productIdentifier_variants_get.json))

The same field appears in the prose variant reference
([manage product variants](https://scayle.dev/documentation/the-basics/products/manage-products-via-api/manage-product-variants)),
the composite-variant reference
([composite products](https://scayle.dev/documentation/the-basics/products/composite-products)),
the stock guide
([stock](https://scayle.dev/documentation/the-basics/products/manage-products-via-api/stock)),
and in webhook payloads, where an unset EAN serialises as `"ean": ""`
([product-variant-deleted](https://scayle.dev/documentation/architecture/webhooks/product-events/admin-api-product-events/product-variant-deleted)).

Note it sits alongside `referenceKey`, described as "A key that uniquely identifies the variant of a
product (usually an SKU) within the tenant's ecosystem" — so SCAYLE deliberately models SKU and EAN
as two distinct first-class identifiers.

### `ean` is *not* a System Attribute Group

SCAYLE's complete list of System Attribute Groups is `brand`, `category`, `new`, `product_name`,
`maximumQuantityPerOrder`, `commissionCode`, `isExcludedFromSearch`, `isManualCaptureAllowed`,
`visibleWithoutStock`
([attribute groups](https://scayle.dev/documentation/the-basics/products/attribute-groups)).
`ean` is absent.

### But an `ean` *attribute* is a documented convention

The Storefront API's own `GET /v1/variants` description gives this as its performance example:

> A typical request for a variant list optimized for maximum performance is, for example,
> `?with=attributes:key(ean|shopSize),advancedAttributes:key(modelHeight),lowestPriorPrice`.

([`v1_variants_get.json`](https://scayle.dev/open_api_specs/storefront-api-latest/v1_variants_get.json),
rendered at [list variants](https://scayle.dev/api-guides/storefront-api/resources/variants/list-variants))

So SCAYLE's own documentation treats a **tenant-defined variant attribute group keyed `ean`** as
normal enough to use as the canonical example. Since attribute group keys must be camelCase
alphanumeric ([attribute groups](https://scayle.dev/documentation/the-basics/products/attribute-groups)),
`ean` is a legal tenant-created key.

**How the two relate is Not documented.** No page states whether the first-class `ean` field
populates an `ean` attribute, whether they are synced, or which one `filters[ean]` reads. Treat them
as two independent stores until proven otherwise.

### `Barcode` type / `barcodes` field on a variant

**Does not exist in SCAYLE.** A full-corpus search for "barcode" returns exactly one page — the
Omnichannel add-on's in-store picking flow
([omnichannel orders](https://scayle.dev/add-on-guide/scayle-extensions/omnichannel-add-on/orders)) —
and no schema in any SAPI or Admin API OpenAPI document declares a `Barcode` type or a `barcodes`
property.

*Inference (not cited):* the `Barcode` type and `ProductVariant.barcodes` field in our BFF's GraphQL
schema are BFF-level abstractions (they match Shopify's `ProductVariant.barcode` model, not
SCAYLE's). This explains why `barcodes` returned `null` for our fixture: on the SCAYLE adapter there
is no SCAYLE field to populate it from.

---

## 2. Cardinality

| Store | Cardinality | Source |
|---|---|---|
| `ProductVariant.ean` (canonical) | **Exactly one, or none.** `"type": "string"` — not an array, no `oneOf` | [Admin API spec](https://scayle.dev/open_api_specs/admin-api-latest/products_productIdentifier_variants_get.json) |
| `ean` as a variant attribute | **Depends on the attribute group's `multiSelect` flag** | [SAPI spec](https://scayle.dev/open_api_specs/storefront-api-latest/v1_variants_get.json) |

The SAPI `AttributeItem` schema makes the attribute case explicit:

```json
"multiSelect": { "type": "boolean", "description": "A flag indicating whether the attribute group has multiple selected values." },
"values": {
  "description": "For single-select attribute groups, a single attribute value object.\nFor multi-select attribute groups, an array of attribute value objects.\n",
  "oneOf": [ { "$ref": "#/components/schemas/AttributeValue" }, { "type": "array", "items": { "$ref": "#/components/schemas/AttributeValue" } } ]
}
```

So the wire shape for an `ean` attribute is **polymorphic**: a bare object when the group is
single-select, an array when it is multi-select. This is the documented explanation for our BFF
reading it into a `string[]` — but it also means a single-select `ean` group returns an *object*, not
a one-element array, and a naive array-shaped parser would miss it.

- **Delimited string?** Not documented.
- **Repeated attribute entries under one key?** Not documented — the schema keys attributes by group,
  so repetition is not expressible.
- **Is `ean` unique across variants?** **Not documented.** The Admin API schema declares no
  uniqueness constraint and `POST /products/{id}/variants` declares no `409` response
  ([create variant spec](https://scayle.dev/open_api_specs/admin-api-latest/products_productIdentifier_variants_post.json)).
  The Panel's product-aggregation feature assumes collisions are routine: "If a merchant variant's
  EAN matches an existing shop variant, a window opens…"
  ([panel PDP](https://scayle.dev/documentation/the-basics/products/products-in-scayle-panel/product-detail-page)).

---

## 3. Querying

### Storefront API — `GET /v1/products?filters[ean]=…`

This is a **dedicated parameter**, defined separately from the generic attribute filter:

```json
{
  "name": "filters[ean]",
  "in": "query",
  "description": "Retrieve a list of products matching the specified `ean` value, e.g., `filters[ean]=121213213`.\n",
  "explode": false,
  "schema": { "default": [], "type": "array", "items": { "type": "string", "example": "ABC123" } }
}
```

([`v1_products_get.json`](https://scayle.dev/open_api_specs/storefront-api-latest/v1_products_get.json),
rendered at [list products](https://scayle.dev/api-guides/storefront-api/resources/products/list-products))

Three things to read off this:

1. It accepts an **array** (`explode: false` ⇒ comma-separated), so several EANs can be queried at
   once.
2. The item example is `"ABC123"` — a non-numeric string — and the description's example is
   `121213213`, nine digits, which is not a valid GTIN length. SCAYLE documents the value as an
   **opaque string**.
3. It returns **products**, not variants.

**Contrast with the generic attribute filter** on the same endpoint:

```json
{
  "name": "filters",
  "description": "Only include results with the specified attribute ID for the attribute parameter `attributeKey`, e.g., `filters[brand]=882`.",
  "style": "deepObject",
  "schema": { "type": "object", "additionalProperties": { "type": "array", "items": { "type": "integer" } } }
}
```

The generic path takes **integer attribute IDs**. A barcode string could never be passed through it.
`filters[ean]` works because SCAYLE special-cases it, not because `ean` is an attribute.

The sibling `filters[variants.referenceKey]` exists for SKU lookup, but **there is no
`filters[variants.ean]`**.

### Storefront API — no EAN lookup on `/v1/variants`

`GET /v1/variants` takes only `ids` (variant IDs), `campaignKey`, `pricePromotionKey` and `with`
([`v1_variants_get.json`](https://scayle.dev/open_api_specs/storefront-api-latest/v1_variants_get.json)).
You cannot fetch a variant by EAN.

### Storefront API — the response never contains the EAN

The SAPI `ProductVariant` schema has these properties and no others: `id`, `isComposite`,
`advancedAttributes`, `appliedPricePromotionKey`, `attributes`, `lowestPriorPrice`, `price`,
`referenceKey`, `firstLiveAt`, `stock`, `customData`, `merchant`, `relatedVariants`, `createdAt`,
`updatedAt`
([`v1_products_get.json`](https://scayle.dev/open_api_specs/storefront-api-latest/v1_products_get.json)).
No `ean`. The `with=` include list has no `ean` entry either. **The canonical EAN is filterable but
not readable through SAPI.** The only way to see an EAN in a SAPI response is if the tenant also
maintains an `ean` *attribute* and you request `with=variants.attributes:key(ean)`.

### Storefront API — `GET /v2/search/resolve`

> The endpoint searches and returns: … products by their unique ids (reference keys, EANs or internal
> ids)

([`v2_search_resolve_get.json`](https://scayle.dev/open_api_specs/storefront-api-latest/v2_search_resolve_get.json),
rendered at [resolve v2](https://scayle.dev/api-guides/storefront-api/resources/search/resolve-v2))

The search documentation is emphatic about the matching semantics:

> A matching product is only returned if there is an exact match between the search term and the
> product identifiers. The product identifiers can be either the product's ID, reference key, EAN, or
> one of the advanced attributes defined in the SCAYLE Panel.

([search](https://scayle.dev/documentation/the-basics/shops/search))

EANs are indexed in SCAYLE's search database as a primary-entity identifier alongside product ID and
reference key, and "Product IDs, Reference Keys and EANs are already matched by default, so you do
not need to configure them here"
([search configuration](https://scayle.dev/documentation/the-basics/shops/search/search-configuration-in-scayle-panel)).

**Caveat:** resolve prefers categories. "A category match takes precedence over a product match"
([search](https://scayle.dev/documentation/the-basics/shops/search)).

### Admin API — `GET /products?filters[variantEan]=…`

```json
{
  "name": "filters[variantEan]",
  "description": "Comma-separated list of variant EANs that should be used for filtering.",
  "explode": false,
  "schema": { "type": "array", "items": { "type": "string", "maxLength": 55 } }
}
```

([`products_get.json`](https://scayle.dev/open_api_specs/admin-api-latest/products_get.json)), with a
worked example `"filters[variantEan]": "01010101,01010102"`
([manage products](https://scayle.dev/documentation/the-basics/products/manage-products-via-api/manage-products)).

This is the cleanest documented barcode lookup SCAYLE offers, and it reads the canonical field by
name. It still returns **products**, not variants. The Admin API has no global variants collection —
every variant endpoint is nested under `/products/{productIdentifier}/variants`
([Admin API reference nav](https://scayle.dev/api-guides/admin-api)) — so there is no way to ask
"which variant has this EAN" in one call either.

### Exact match and collisions

- **Exact-match guarantee for `filters[ean]` / `filters[variantEan]`: Not documented.** Neither
  description states whether matching is exact, prefix, case-sensitive or fuzzy. (`/v1/products` has
  a separate `disableFuzziness` parameter, but it is documented against `filters[term]`, not
  `filters[ean]`.)
- **Exact-match *is* guaranteed for `/v2/search/resolve`** (quoted above).
- **What happens when several variants share a barcode: Not documented.** Both filters return product
  collections, so multiple hits are representable, but no page describes the ordering or
  disambiguation.

---

## 4. Validation / parsing

**Not documented — for every single item asked about.**

A search across all 679 documentation pages and the Admin API and Storefront API OpenAPI documents
found **no occurrence** of: `GTIN`, `UPC`, `GS1`, `check digit`, `leading zero`, or any discussion of
normalising an EAN.

What the schema *does* constrain:

| Constraint | Value | Source |
|---|---|---|
| Type | `string` | [Admin API spec](https://scayle.dev/open_api_specs/admin-api-latest/products_productIdentifier_variants_get.json) |
| Max length | `55` | same |
| `pattern` | **none** | same |
| Required | no (only `referenceKey` is required on `ProductVariant`) | same |

The absence of `pattern` is meaningful by contrast: the sibling `referenceKey` in the same schema
*does* carry `"pattern": "^[a-zA-Z0-9-_\\. ]*$"`. SCAYLE constrains SKU format and deliberately does
not constrain EAN format.

*Inference (not cited):* SCAYLE stores and matches the EAN as an opaque string, with no check-digit
validation, no length check, no leading-zero stripping, no UPC-A→EAN-13 widening and no documented
whitespace trimming. Supporting circumstantial evidence, all from official examples: the Admin API
example value is `0000007619991` (13 characters, leading zeros preserved rather than stripped), the
`filters[ean]` example is `121213213` (9 digits — not a valid GTIN length at all), the schema item
example is `ABC123` (not numeric), and the `filters[variantEan]` example is `01010101,01010102`.
None of these is a valid GTIN, and SCAYLE uses them as its own documentation.

**Practical reading:** if matching is exact-string as the evidence suggests, the value we send must
be byte-identical to the value stored. Do not normalise on our side unless we normalise on the way
in too.

---

## 5. Ingestion

### Admin API (the documented primary path)

> Create products via the Admin API because this is the easiest way to handle lots of products.

([import products](https://scayle.dev/documentation/the-basics/products/manage-products-via-api/import-products))

Two routes, both writing the canonical field:

| Route | Shape |
|---|---|
| `POST /products` with a `variants: ProductVariant[]` array | [import products](https://scayle.dev/documentation/the-basics/products/manage-products-via-api/import-products) |
| `POST /products/{productIdentifier}/variants` | [manage product variants](https://scayle.dev/documentation/the-basics/products/manage-products-via-api/manage-product-variants) |

The documented minimal variant payload is exactly two fields:

```json
{ "referenceKey": "myReferenceKey", "ean": "0000007738357" }
```

([manage product variants](https://scayle.dev/documentation/the-basics/products/manage-products-via-api/manage-product-variants))

### Panel file import

The Panel's Imports area accepts CSV/XLSX for prices, merchants, translations, settings, shops,
products, customers, vouchers and checkout configurations
([imports](https://scayle.dev/documentation/the-basics/scayle-panel/settings/imports-and-jobs/imports)).
**No documented import template includes an EAN column.** Whether the product-list import carries
EAN is Not documented.

### Panel UI

The Panel displays the EAN read-only, and only conditionally:

> The EAN is displayed below the variant ID as soon as the product assignment feature is active.

([panel PDP](https://scayle.dev/documentation/the-basics/products/products-in-scayle-panel/product-detail-page))

The Panel *uses* EANs in three documented places: product-list search ("Search for one or more
merchant product variant EANs")
([product list](https://scayle.dev/documentation/the-basics/products/products-in-scayle-panel/product-list)),
bulk media upload reference criteria ("Merchant Identifiers, Product IDs, or EAN")
([media](https://scayle.dev/documentation/the-basics/products/products-in-scayle-panel/media)), and
merchant-variant aggregation
([panel PDP](https://scayle.dev/documentation/the-basics/products/products-in-scayle-panel/product-detail-page)).

### Which field does a standard import map a GTIN into?

`ProductVariant.ean`. There is no other candidate — SCAYLE has no `gtin`, `upc` or `barcode` field.

### Retailer in-store codes vs manufacturer GTINs

**Not documented.** SCAYLE gives no guidance on GS1 restricted-circulation prefixes (20–29), on
in-store-only codes, or on reconciling a retailer code with a manufacturer GTIN.

The closest thing to a statement of intent is in the Omnichannel add-on, and it points the other way
entirely:

> For successful scanning, ensure that the scanned barcodes contain the variant reference key stored
> in SCAYLE. This ensures accurate and swift processing.

([omnichannel orders](https://scayle.dev/add-on-guide/scayle-extensions/omnichannel-add-on/orders))

SCAYLE's own first-party in-store scanning feature expects the barcode to encode the **variant
reference key**, not the EAN.

---

## 6. Writing one

| | |
|---|---|
| **Endpoint** | `PUT /products/{productIdentifier}/variants/{variantIdentifier}` |
| **Body** | the full `ProductVariant`, including `ean` |
| **Partial updates** | not supported — "It does not support partial updates… not provided properties will get deleted", except the nested `attributes`, `prices`, `stocks`, `customData`, `relatedVariants` |
| **Identifiers** | both path params accept an ID *or* a reference key ([identifiers](https://scayle.dev/api-guides/admin-api/getting-started/identifiers)) |
| **Rate-limit scope** | `productWrite` |
| **Required resource** | `products` (`"x-resources": ["products"]`) |

([`products_productIdentifier_variants_variantIdentifier_put.json`](https://scayle.dev/open_api_specs/admin-api-latest/products_productIdentifier_variants_variantIdentifier_put.json),
rendered at [update an existing product variant](https://scayle.dev/api-guides/admin-api/resources/product-variants/update-an-existing-product-variant))

### Token and permission

Admin API authentication is a Panel-issued key in the `X-Access-Token` header:

> Each API Key needs to have so-called "resources" assigned. A resource is a group of endpoints; for
> example, "Products" and "Variants" are combined into a resource called "Products." You can select
> "read" or "write" permissions when assigning resources.

([Admin API authentication](https://scayle.dev/api-guides/admin-api/getting-started/authentication))

Creating the key requires the Panel permission `api_key__create`, and the key can be further
restricted by company, shop and IP allow-list
([API keys](https://scayle.dev/documentation/the-basics/scayle-panel/settings/general/api-keys)).

**So the access we would need is: an Admin API key with the `products` resource at write scope.** Our
read-only Storefront API token cannot do it — the Storefront API exposes no write path for product
data at all, and uses its own separate `X-Access-Token` credential
([SAPI authentication](https://scayle.dev/api-guides/storefront-api/getting-started/authentication)).

Editing an EAN through the **Panel UI** is **Not documented** — the Panel pages describe the EAN only
as displayed, searched and matched, never edited.

---

## 7. What this means for Alfie

### Is `2600030000445` vs `96848723` the right diagnosis?

**Yes, and the docs sharpen it.** Because SCAYLE stores `ean` as an unvalidated opaque string with no
`pattern` and a 55-character ceiling
([spec](https://scayle.dev/open_api_specs/admin-api-latest/products_productIdentifier_variants_get.json)),
`96848723` is a perfectly acceptable value to SCAYLE even though it fails the EAN-8 check digit.
SCAYLE will neither reject it on write nor repair it on read. Nothing in the platform will ever make
`filters[ean]=2600030000445` match a record whose stored value is `96848723`.

The fixture is simply wrong for the tag: the swing tag's Code 128 symbol carries `2600030000445`, so
that is the string that must be stored. `96848723` is the human-readable text, not the encoded
payload. Storing the printed text rather than the scanned payload is the whole bug.

Two corollaries worth acting on:

- **Do not add normalisation to the BFF as a fix.** There is no documented normalisation on SCAYLE's
  side to mirror, so any transformation we add (stripping leading zeros, widening UPC-A, padding)
  makes our string *less* likely to be byte-identical to the stored one.
- **Do preserve leading zeros end-to-end.** SCAYLE's own examples are zero-padded (`0000007619991`),
  and a scanner or JSON layer that treats the payload as a number would silently destroy them.

### Where our model diverges from the docs

| Our understanding | What SCAYLE documents |
|---|---|
| `ean` is a custom **attribute** the tenant defined | `ean` is a **first-class `string` property** on `ProductVariant`, not in the System Attribute Group list ([variants](https://scayle.dev/documentation/the-basics/products/manage-products-via-api/manage-product-variants), [attribute groups](https://scayle.dev/documentation/the-basics/products/attribute-groups)) |
| The BFF builds `attributes: [{type:'attributes', key:'ean', values:[…]}]` | `filters[ean]` is a **dedicated parameter**; the generic attribute filter takes **integer attribute IDs** (`filters[brand]=882`) and could not carry a barcode string ([spec](https://scayle.dev/open_api_specs/storefront-api-latest/v1_products_get.json)) |
| The `ean` attribute is multi-valued; the BFF reads `string[]` | The canonical field is a single `string`. An `ean` *attribute*, if the tenant has one, is single-object **or** array depending on its `multiSelect` flag ([spec](https://scayle.dev/open_api_specs/storefront-api-latest/v1_variants_get.json)) |
| SCAYLE has a `Barcode` type and `barcodes` on a variant | **No such type or field exists in SCAYLE.** It is a BFF-level abstraction; `null` is the only value SCAYLE could ever produce for it |

The first two are model errors, not wire errors: the URL the BFF emits (`filters[ean]=<value>`)
happens to be the documented one. The risk is that the internal "it's an attribute" model invites a
future refactor onto the generic attribute path, which cannot work.

### Mechanisms we are not using

1. **`GET /v2/search/resolve`** — the only SCAYLE endpoint with a *documented* exact-match guarantee
   on EAN, and it also accepts reference keys and product IDs, so one call could resolve a barcode,
   a SKU or an internal ID
   ([resolve v2](https://scayle.dev/api-guides/storefront-api/resources/search/resolve-v2),
   [search](https://scayle.dev/documentation/the-basics/shops/search)). It is reachable with a
   read-only SAPI token. The catch is that a category match beats a product match, so a numeric code
   colliding with a category name would resolve to the category — worth guarding.
2. **`filters[variants.referenceKey]` on `/v1/products`** — SKU lookup with the same shape as
   `filters[ean]` ([spec](https://scayle.dev/open_api_specs/storefront-api-latest/v1_products_get.json)).
   Given that SCAYLE's own in-store scanner expects the **variant reference key** in the barcode
   ([omnichannel orders](https://scayle.dev/add-on-guide/scayle-extensions/omnichannel-add-on/orders)),
   trying the code as a reference key when the EAN lookup misses is a cheap second chance.
3. **`with=variants.attributes:key(ean)`** — if the tenant *does* maintain an `ean` attribute,
   this is the only way to read the value back through SAPI, which would let the BFF pick the right
   variant instead of returning the product alone
   ([spec](https://scayle.dev/open_api_specs/storefront-api-latest/v1_variants_get.json)).

### The structural limitation to design around

**SCAYLE cannot tell us which variant matched.** `filters[ean]` and `filters[variantEan]` both return
*products*, and the SAPI variant response carries no `ean` at all. ADR-0002's decision — return the
variant only when exactly one variant carries the code, otherwise fall back to the product's default
variant — is therefore not a conservative choice we made, it is the only behaviour SAPI supports,
unless the tenant maintains a readable `ean` attribute as well (mechanism 3 above).

### Fixing the staging fixture

Set `ProductVariant.ean` on variant 1836 to `2600030000445` via
`PUT /products/567/variants/1836` with the full variant body — the endpoint does not support partial
updates. This needs an Admin API key with the `products` resource at **write** scope, issued from the
Panel; our read-only SAPI token cannot do it, and no Panel UI path for editing an EAN is documented
([update variant](https://scayle.dev/api-guides/admin-api/resources/product-variants/update-an-existing-product-variant),
[API keys](https://scayle.dev/documentation/the-basics/scayle-panel/settings/general/api-keys)).

## Sources

- [SCAYLE docs index (`llms.txt`)](https://scayle.dev/llms.txt)
- [Products — data model and entity levels](https://scayle.dev/documentation/the-basics/products)
- [Attribute Groups — System Attribute Groups list](https://scayle.dev/documentation/the-basics/products/attribute-groups)
- [Manage Product Variants](https://scayle.dev/documentation/the-basics/products/manage-products-via-api/manage-product-variants)
- [Manage Products — `filters[variantEan]`](https://scayle.dev/documentation/the-basics/products/manage-products-via-api/manage-products)
- [Import Products](https://scayle.dev/documentation/the-basics/products/manage-products-via-api/import-products)
- [Composite Products](https://scayle.dev/documentation/the-basics/products/composite-products)
- [Search — entities, suggestions, resolve](https://scayle.dev/documentation/the-basics/shops/search)
- [Search configuration in the Panel](https://scayle.dev/documentation/the-basics/shops/search/search-configuration-in-scayle-panel)
- [Panel — product detail page](https://scayle.dev/documentation/the-basics/products/products-in-scayle-panel/product-detail-page)
- [Panel — product list](https://scayle.dev/documentation/the-basics/products/products-in-scayle-panel/product-list)
- [Panel — media](https://scayle.dev/documentation/the-basics/products/products-in-scayle-panel/media)
- [Panel — imports](https://scayle.dev/documentation/the-basics/scayle-panel/settings/imports-and-jobs/imports)
- [Panel — API keys](https://scayle.dev/documentation/the-basics/scayle-panel/settings/general/api-keys)
- [Webhook — product variant deleted](https://scayle.dev/documentation/architecture/webhooks/product-events/admin-api-product-events/product-variant-deleted)
- [Omnichannel add-on — orders and in-store picking](https://scayle.dev/add-on-guide/scayle-extensions/omnichannel-add-on/orders)
- [Admin API — authentication](https://scayle.dev/api-guides/admin-api/getting-started/authentication)
- [Admin API — identifiers](https://scayle.dev/api-guides/admin-api/getting-started/identifiers)
- [Admin API — list product variants](https://scayle.dev/api-guides/admin-api/resources/product-variants/list-product-variants)
- [Admin API — update an existing product variant](https://scayle.dev/api-guides/admin-api/resources/product-variants/update-an-existing-product-variant)
- [Storefront API — authentication](https://scayle.dev/api-guides/storefront-api/getting-started/authentication)
- [Storefront API — list products](https://scayle.dev/api-guides/storefront-api/resources/products/list-products)
- [Storefront API — list variants](https://scayle.dev/api-guides/storefront-api/resources/variants/list-variants)
- [Storefront API — resolve v2](https://scayle.dev/api-guides/storefront-api/resources/search/resolve-v2)
- OpenAPI documents: [`products_get`](https://scayle.dev/open_api_specs/admin-api-latest/products_get.json), [`products_{productIdentifier}_variants_get`](https://scayle.dev/open_api_specs/admin-api-latest/products_productIdentifier_variants_get.json), [`…_variants_post`](https://scayle.dev/open_api_specs/admin-api-latest/products_productIdentifier_variants_post.json), [`…_variants_{variantIdentifier}_put`](https://scayle.dev/open_api_specs/admin-api-latest/products_productIdentifier_variants_variantIdentifier_put.json), [`v1_products_get`](https://scayle.dev/open_api_specs/storefront-api-latest/v1_products_get.json), [`v1_variants_get`](https://scayle.dev/open_api_specs/storefront-api-latest/v1_variants_get.json), [`v2_search_resolve_get`](https://scayle.dev/open_api_specs/storefront-api-latest/v2_search_resolve_get.json)
