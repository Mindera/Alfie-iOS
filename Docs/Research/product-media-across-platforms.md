# Research: product media across the BFF, SCAYLE, Shopify and BigCommerce

**Status:** current
**Date:** 2026-10-13

**Scope:** what "product images / variant media" means in the BFF contract, in each of the three
commerce platforms behind it, and in the three clients — in order to pin down what
[AF-155](https://mindera.atlassian.net/browse/AF-155) ("[BFF][SCAYLE] productDetails returns no
variant media") is actually about. No code was changed.

> **Method note.**
> - **BFF** read at `Alfie-BFF` `main` @ `0bf8ee9` (2026-10-01). Paths below are relative to that repo's
>   `src/` unless prefixed. Code was read, not executed; **no live platform was called**.
> - **iOS** read at this worktree, `043ec40e`. **Android** `main` @ `009a4ee` (2026-08-24) and **Web**
>   `main` @ `0529ff1` (2026-09-01) are local checkouts and may be behind their remotes.
> - **Platform facts** come only from vendor documentation, the OpenAPI/GraphQL definitions those
>   docs render from, and the installed `@scayle/storefront-api@18.21.0` type declarations. SCAYLE and
>   BigCommerce pages were fetched as raw Markdown (`<url>.md`); Shopify pages are API version `2026-10`.
> - Jira: AF-155, AF-130, AF-124 were read. AF-129, AF-118 and AF-127 (linked from those) were **not**.
> - Each statement is tagged **[V]** verified against the cited source, or **[I]** inferred.

---

## Summary — the sharpened problem

AF-155 describes a SCAYLE adapter gap. The evidence says it is a **contract gap that SCAYLE merely
exposes**:

1. **`ProductVariant.media` has no definition, and the three adapters and three clients each assume a
   different one.** [V] It is declared as a bare `[Image]` with no description (`schema.gql:243`).
   iOS and Android treat it as *"the gallery to show when this variant is selected"*. The Shopify
   adapter fills it with *"the one image this variant points at"*. BigCommerce and SCAYLE leave it
   empty. Web ignores it and reads `OmniProduct.images`.
2. **No platform's storefront API has a per-variant gallery.** [V] Shopify: one `image` per variant.
   BigCommerce: one `defaultImage` per variant. SCAYLE: nothing on the variant at all. Galleries live
   on the product in all three. So "variant media = N photos" (AF-155's *Expected* column) is a value
   **no upstream supplies**; it can only ever be synthesised by the BFF.
3. **The user-visible defect is on iOS, and it is not SCAYLE-only.** [V] The iOS PDP gallery is
   `variant.media`, else a single `primaryImage`; iOS never selects `OmniProduct.images`. Result: the
   iOS gallery is capped at **one image on every platform** — SCAYLE (0 → fallback 1), BigCommerce
   (0 → fallback 1), Shopify (1). This was already recorded for Shopify on 2026-08-11 in
   `Docs/Specs/Features/ProductDetailsModernDesign.md:357-389` and never ticketed against the BFF.
4. **AF-155's fix would work for SCAYLE and leave the other two as they are**, making SCAYLE the only
   platform with a multi-image iOS gallery and widening the divergence AF-130 exists to close. [I]
5. **Separate, adjacent gaps the ticket folds in or misses** [V]: colour on SCAYLE is a *sibling
   product*, which the BFF never requests; non-image media (video, 3D) is dropped on all three
   platforms; `Image` carries only `url` + `altText`; Shopify and BigCommerce silently truncate at 10
   images; the BigCommerce adapter reads a variant field that does not exist upstream.

**One-line restatement:** *the BFF has not decided whether `ProductVariant.media` means "this
variant's own image(s)" or "the gallery for this variant", so every adapter and client guessed; the
iOS guess yields a one-image PDP gallery on all three platforms.*

---

## 1. Side-by-side

| | BFF contract | SCAYLE (Storefront API) | Shopify (Storefront API) | BigCommerce (GraphQL Storefront) |
|---|---|---|---|---|
| **"Product" is** | `OmniProduct` | Middle of Master → Product → Variant; Product holds shared traits "color, material, or pattern" | "An item listed in a shop's catalog"; all option combinations | e.g. "a t-shirt" |
| **"Variant" is** | `ProductVariant` | "different sizes … a t-shirt, in yellow in size M" — lowest level, what is bought | "differentiated by options like size or color" | "a small, red t-shirt"; one SKU |
| **Colour lives on** | `optionValues[]` name matched by clients | Product level by default; other colours are `siblings` sharing a `masterKey` | A product option | A product option (`SwatchOptionValue` has `hexColors`, `imageUrl`) |
| **Product images** | `images: [Image!]!`, `media: [Image]`, `primaryImage` | `Product.images[]` | `Product.images`, `Product.media`, `featuredImage` | `Product.images`, `Product.defaultImage` |
| **Variant images** | `media: [Image]` | **None** — no image field on `ProductVariant` | **One**: `image` (falls back to product image) | **One**: `defaultImage` |
| **Primary image** | `primaryImage` | No field; SCAYLE's own storefront filters on an image attribute (`ATTRIBUTE_KEY_PRIMARY_IMAGE`) | `featuredImage` ≡ `images(first: 1)` | `defaultImage`; `Image.isDefault` |
| **Ordering** | list order, unspecified | `position`, 0-based, per shop-country overridable (Admin API) | connection order | REST `sort_order`; GraphQL connection order |
| **Video** | none | `Product.videos[]`, opt-in `with=videos` | `Video`, `ExternalVideo` in `media` | `Product.videos` (`title`, `url`); YouTube only |
| **3D** | none | not documented | `Model3d` in `media` | not in schema |
| **Alt text** | `altText: String` | none on `Image` | `Image.altText`, `Media.alt` | `Image.altText: String!` |
| **Dimensions** | none | none | `width`, `height` | none |
| **Image roles** | none | image `attributes` (`type`, `angle`, …), `customData` | `mediaContentType`, `presentation` | `isDefault` only |
| **Resizing** | none; adapter-decided | CDN modifiers; `Image.url` "ready-to-use" | `url(transform:)` — `maxWidth`, `maxHeight`, `crop`, `scale`, `preferredContentType` | `url(width:, height:, lossy:)`, `urlTemplate` |
| **What the BFF emits for variant `media`** | — | **absent** (`undefined`) | 0–1 image | **always `[]`** |
| **What the BFF emits for product `media`** | — | duplicate of `images` | **always `[]`** | duplicate of `images` |

Sources for every cell are in §2 and §3.

---

## 2. BFF contract and adapters

### 2.1 Schema [V]

```graphql
type Image { altText: String  url: String! }            # schema.gql:104-107
type OmniProduct   { images: [Image!]!  media: [Image]  primaryImage: Image … }   # :170, :172, :176
type ProductVariant { media: [Image] … }                # :243
type CartItem      { image: Image … }                   # :42
```

- `media` is typed `[Image]` on both product and variant: there is **no media-kind discriminator**, so
  a video or 3D model cannot be represented, only flattened to a still.
- None of the four fields carries a description. `OmniProduct.images` vs `OmniProduct.media` has no
  stated difference. (Compare `sizeGuideUrl`, which does document its semantics, `schema.gql:180-183`.)
- `Image` has no width, height, id, position, role or content type.

### 2.2 Per platform

| | SCAYLE | Shopify | BigCommerce |
|---|---|---|---|
| Upstream requested | `images: 'all'`; **no `siblings`, no `videos`** — `scayle/scayle-adapter.service.ts:127-142`, `scayle/scayle.service.ts:108-119` | `featuredImage`, `images(first: 10)`, per-variant `image`; **`media` selected by no query** — `shopify/queries/get-product-details.query.gql:30-41,83-86` | `images { url(width: 500) altText }` with **no `first`**; **nothing image-related on variants** — `bigcommerce/queries/get-product-by-slug.query.gql:51-58,98-125` |
| `images` | `product.images[].hash` → URL, in upstream order — `scayle-adapter.service.ts:696-708` | `images.edges` — `shopify-adapter.service.ts:172-176` | `images.edges` — `bigcommerce-adapter.service.ts:479-482` |
| `primaryImage` | `images[0]` — `:675`, `:877` | `featuredImage` — `:177-182` | `imageEdges[0]` — `:483-488` |
| Product `media` | same array as `images` — `:676`, `:878` | reads `node.media`, which is never fetched → `[]` — `:183-190` | re-maps `images` — `:489-492` |
| Variant `media` | **not set** — `normalizeVariant`, `:746-767` | `[variant.image]` or `[]` — `:490-492` | reads `node.images.edges`, never fetched → `[]` — `:751-755` |
| `altText` | hardcoded `''` — `:705-706` | product `images`: passthrough, may be `null`; elsewhere `\|\| ''` | `\|\| ''` |
| URL | `imageBaseUrl` + hash; absolute hashes pass through — `:1139-1145` | upstream original, no transform | fixed 500 px wide |
| Dropped | image `attributes`, `name`, `customData`, upstream `url`; videos; siblings | all `media` (video, 3D, external video); `width`/`height`; images and variants beyond the 10th | `defaultImage`, `isDefault`, `videos`, `urlTemplate`; images beyond the 10th |
| Synthesised | `altText: ''`; CDN prefix from tenant config | cart line image falls back variant → `featuredImage` — `:445-454` | cart `altText: ''` — `:422` |

Notes, all [V] unless marked:

- **SCAYLE `normalizeVariant` is shared** by the list mapper (`:655`) and the detail mapper (`:842`),
  so it also serves `productList`, `searchProducts` (`:625`) and `relatedProducts`
  (`scayle.service.ts:457`). A fix there changes all four queries, not only `productDetails`.
- **SCAYLE variant `media` is `undefined`, not `[]`** — GraphQL serialises it as `null`. AF-155 says
  "empty"; the wire value is `null`. Clients coalesce both.
- **Shopify truncation.** `productDetails` requests `images(first: 10)` and `variants(first: 10)`
  (`get-product-details.query.gql:34,64`); listing and search request `images(first: 1)` and
  `variants(first: 100)` (`get-products-by-collection.query.gql:47,72`, `search-products.query.gql:57,82`).
  A product with more than 10 images or 10 variants is silently cut on the PDP; `OmniProduct.images`
  on a list result has at most one entry.
- **BigCommerce truncation.** `images` is requested without `first`; BigCommerce documents "If `first`
  is not specified, a query returns only 10 items by default"
  ([overview](https://docs.bigcommerce.com/developer/docs/storefront/guides/graphql-storefront-api/overview)).
- **BigCommerce adapter reads a field that does not exist.** `node.images` on a variant
  (`bigcommerce-adapter.service.ts:751-755`): the upstream `Variant` type has `defaultImage: Image` and
  no `images` (§3.3). The specs that "prove" the mapping build the fixture by hand
  (`bigcommerce-adapter.service.spec.ts:604-613,688-699`), so they pass against a shape upstream
  cannot return.
- **Shopify product `media` mapping has dead fallbacks.** `edge.node.url` and `edge.node.altText`
  (`shopify-adapter.service.ts:186-189`) are fields of no `Media` implementation (§3.2); only
  `previewImage.url` / `image.url` / `alt` can match. Covered by fixture-only specs
  (`shopify-adapter.service.spec.ts:247-301`).
- **Nothing guards any of this.** The conformance suite has no invariant mentioning `media`, `images`
  or `primaryImage` (`platform/commerce-platform.conformance.spec.ts`; the only hits are fixture data
  in `platform/conformance/*.ts`). Its own header warns "Fixtures are hand-written, so a green run
  shows platforms agree, not that upstream returns this" (`:168-169`).
- **Cart.** Shopify and BigCommerce emit `CartItem.image`; the SCAYLE basket is not implemented
  (`scayle.service.ts:476-478`, AF-127).
- **Barcode lookup** deliberately fetches no images (`scayle-adapter.service.ts:151-155`).

### 2.3 Consistency across queries [V]

| Query | SCAYLE | Shopify | BigCommerce |
|---|---|---|---|
| `productDetails` | all images; variant media absent | ≤ 10 images; variant media 0–1 | ≤ 10 images @500w; variant media `[]` |
| `productList` / `searchProducts` | all images; variant media absent | **1** image; variant media 0–1 | ≤ 10 images; variant media `[]` |
| `relatedProducts` | as list | ≤ 10 images, ≤ 10 variants | ≤ 10 images, 1 variant |
| `cart` | not implemented | variant image → `featuredImage` | `imageUrl` |

---

## 3. Platform truth

### 3.1 SCAYLE

**Data model** [V]
- Three default entities: "**Master** is the superordinate level … t-shirt, sofa, or notebook";
  "**Product** … describes shared characteristics under the master. Examples are color, material, or
  pattern"; "**Variant** … different sizes because a customer buys a t-shirt, in yellow in size M".
  A fourth entity, **Media**, exists so that attribute groups ("detail", "hover", "model") can be
  attached to images.
  ([entities](https://scayle.dev/documentation/the-basics/products/entities))
- Which attribute group sits on which entity is tenant configuration ("you can create Attribute Groups
  and attribute values", same page). Colour-on-product is the documented default, **not a guarantee**. [I]
- Other colours are separate products: the SAPI `Product` has `masterKey` ("Identifies the master
  product which this product belongs") and `siblings` ("The siblings of the product"), opt-in via
  `with=siblings`
  ([spec](https://scayle.dev/open_api_specs/storefront-api-latest/v1_products_productId_get.json)).
  SCAYLE's own storefront: "The current implementation supports displaying only color variants in the
  sibling section … Clicking on a sibling navigates the user to the PDP of that specific sibling"
  ([PDP](https://scayle.dev/documentation/storefront/storefront-application/features/product-detail-page)).

**Where media attaches** [V]
- SAPI `Product.images: Image[]` ("The images of the product") and `Product.videos: Video[]`.
  SAPI `ProductVariant` has 15 properties and **none is an image, video or media field**
  (same spec, `components.schemas.ProductVariant`).
- Admin API image endpoints are all under `/products/{productIdentifier}/images`
  ([manage media/assets](https://scayle.dev/documentation/the-basics/products/manage-products-via-api/manage-media-assets));
  the docs index lists no variant-image endpoint ([`llms.txt`](https://scayle.dev/llms.txt)).
- Sibling media is reachable in the same request: `with=siblings.images.attributes`, `siblings.videos`
  (spec, `productsWith`).

**What an image carries** [V]
- SAPI `Image`: `hash`, `name`, `url` ("Ready-to-use image URL. Empty for products indexed before image
  URLs were introduced"), `attributes`, `customData`. **No alt text, no dimensions.**
- Admin `ProductImage`: `id`, `referenceKey`, `name`, `mimeType`, `position` ("Counting starts with 0"),
  `assetUrl`, `attributes`, `shopCountrySpecific` positions. "Image attributes, such as `angle` and
  `type`, can enhance the image data" (manage media/assets, above).
- Order: "Product assets are saved in the provided order"; default is last position (same page).
- Formats: PNG, JPEG, GIF, PDF; video MP4/MOV/WebM
  ([media](https://scayle.dev/documentation/the-basics/products/products-in-scayle-panel/media)).
- SDK `ProductImage` in the installed version is `{ hash: string; attributes?: Attributes }` and
  `ImageAttributes` names `type: 'model' | 'bust' | string`, `focus`, `view`, `angle`, `background`, …
  (`Alfie-BFF/node_modules/@scayle/storefront-api/dist/shared/storefront-api.BfdO4Ukq.d.ts:100-113`).

**Video** [V]
- `with=videos`; "Storefront API later returns the full URL, including the CDN base"; up to 5 per
  product on the free tier
  ([manage media/videos](https://scayle.dev/documentation/the-basics/products/manage-products-via-api/manage-media-videos)).
- "Requires `@scayle/storefront-api` 19.6.0 or later. That release added `Product.videos`,
  `ProductWith.videos`, and `ProductImage.url`"
  ([PDP customization](https://scayle.dev/documentation/storefront/storefront-application/features/product-detail-page/customization)).
  The BFF pins **18.21.0** (`Alfie-BFF/package.json:37`), whose `ProductWith` has no `videos`
  (`…BfdO4Ukq.d.ts:358-371`). Videos and `Image.url` are unreachable through typed SDK calls today.

**Primary image** [V] SCAYLE's storefront requests `images.attributes` with key
`ATTRIBUTE_KEY_PRIMARY_IMAGE` (PDP customization, above) — i.e. primary is an image attribute, not
position 0. The constant's string value is not shown on that page. The BFF uses `images[0]`. Whether
this tenant sets that attribute is unknown.

**Resizing** [V] done by CDN modifiers in SCAYLE's storefront components, not by the API
([images](https://scayle.dev/documentation/storefront/storefront-application/features/images)).
The modifier URL grammar is not documented on the pages read.

### 3.2 Shopify (Storefront API 2026-10 — the API the BFF calls, `shopify/shopify-connector.service.ts:31`)

- `Product`: `images: ImageConnection!` "List of images associated with the product";
  `media: MediaConnection!` "Valid media are images, 3D models, videos"; `featuredImage` "This field is
  functionally equivalent to `images(first: 1)`". [V]
  ([Product](https://shopify.dev/docs/api/storefront/latest/objects/Product))
- `ProductVariant`: "A specific version of a product available for sale, differentiated by options like
  size or color". Its only image field is `image: Image` — "Image associated with the product variant.
  **This field falls back to the product image if no image is available.**" There is **no `media`
  field**. [V] ([ProductVariant](https://shopify.dev/docs/api/storefront/latest/objects/ProductVariant))
- `Media` interface: `alt`, `id`, `mediaContentType`, `presentation`, `previewImage`; implemented by
  `MediaImage` (`image`), `Video` (`sources`), `ExternalVideo` (`embedUrl`, `host`, `originUrl`),
  `Model3d` (`sources`). `MediaContentType`: `EXTERNAL_VIDEO`, `IMAGE`, `MODEL_3D`, `VIDEO`. [V]
  ([Media](https://shopify.dev/docs/api/storefront/latest/interfaces/Media),
  [MediaContentType](https://shopify.dev/docs/api/storefront/latest/enums/MediaContentType))
- `Image`: `url(transform:)`, `altText`, `width`, `height`, `id`, `thumbhash`. `ImageTransformInput`:
  `crop`, `maxHeight`/`maxWidth` (1–5760), `preferredContentType`, `scale` (1–3). [V]
  ([Image](https://shopify.dev/docs/api/storefront/latest/objects/Image),
  [ImageTransformInput](https://shopify.dev/docs/api/storefront/latest/input-objects/ImageTransformInput))
- The **Admin** API does have `ProductVariant.media: MediaConnection!` and marks `image` deprecated
  ([Admin ProductVariant](https://shopify.dev/docs/api/admin-graphql/latest/objects/ProductVariant)).
  The BFF does not use the Admin API. [V]

Consequences:
- Because `image` falls back to the product image, a Shopify variant's BFF `media` is empty **only when
  the product has no image at all**; otherwise it is exactly one. [I, from the quoted sentence]
- AF-130's "`primaryImage` — Shopify uses the merchant-chosen `featuredImage` … BigCommerce takes the
  first image positionally" is not a real divergence on the Shopify side: by Shopify's own definition
  the two are the same thing. [V]

### 3.3 BigCommerce (GraphQL Storefront — the API the BFF calls, `bigcommerce/bigcommerce-connector.service.ts:16`)

- `Product`: `images(…): ImageConnection!`, `defaultImage: Image`, `videos(…): VideoConnection!`. [V]
  ([Product](https://docs.bigcommerce.com/developer/api-reference/graphql/storefront/types/objects/product))
- `Variant`: `defaultImage: Image` — "Default image for a variant". **No `images`, no `videos`.** [V]
  ([Variant](https://docs.bigcommerce.com/developer/api-reference/graphql/storefront/types/objects/variant))
- REST confirms the cardinality: "Only one image can be explicitly associated with a Variant … The
  image displays on the storefront when the Variant is selected." [V]
  ([create variant image](https://docs.bigcommerce.com/developer/api-reference/rest/admin/catalog/product-variants/images/create-product-variant-image))
- `Image`: `url(width: Int!, height: Int, lossy: Boolean): String!`, `urlOriginal`, `urlTemplate`
  ("a `{:size}` parameter … `123w` or `123x123`"), `altText: String!`, `isDefault: Boolean!`. [V]
  ([Image](https://docs.bigcommerce.com/developer/api-reference/graphql/storefront/types/objects/image))
- `Video`: `title`, `url`. REST: "you must load videos through YouTube"; `type` allowed value
  `youtube`. [V]
  ([Video](https://docs.bigcommerce.com/developer/api-reference/graphql/storefront/types/objects/video),
  [create video](https://docs.bigcommerce.com/developer/api-reference/rest/admin/catalog/products/videos/create-product-video))
- Model: "A product might be a t-shirt, while the variant would be 'a small, red t-shirt'"; variants
  "Can have their own price, weight, dimensions, image, etc. - or they can inherit these values from
  the product". REST image fields: `is_thumbnail`, `sort_order`, `description`. [V]
  ([catalog overview](https://docs.bigcommerce.com/developer/docs/admin/catalog-and-inventory/products-overview),
  [list product images](https://docs.bigcommerce.com/developer/api-reference/rest/admin/catalog/products/images/get-product-images))
- Colour: `SwatchOptionValue` has `hexColors` ("up to 3") and `imageUrl` ("swatch texture image"). [V]
  ([SwatchOptionValue](https://docs.bigcommerce.com/developer/api-reference/graphql/storefront/types/objects/swatch-option-value))

Consequence: AF-130's acceptance criterion "BigCommerce query documents request … `media`" has no
literal counterpart — there is no `media` field; the reachable inputs are `Variant.defaultImage` (one)
and `Product.videos`. [V]

---

## 4. What the clients do

| | PDP gallery source | Fallback | Colour picker source | List / bag / wishlist |
|---|---|---|---|---|
| **iOS** | selected variant's `media` | **one** `primaryImage` | `optionValues` named `color`/`colour` | list: `primaryImage`; bag: `CartItem.image`; wishlist: first of the selected variant's resolved media |
| **Android** | selected-colour variant's `media` | **all** `OmniProduct.images` | `optionValues` | list: `primaryImage`; bag and wishlist: `variant.media.first`, **no fallback** |
| **Web** | `OmniProduct.images` | — | `options` + `optionValues` | list: `primaryImage`; cart: `CartItem.image` |

**iOS** [V]
- `ProductDetailsFragment` selects `primaryImage` and `variants { media }`; **not** `images`, not product
  `media` — `Alfie/AlfieKit/Sources/BFFGraph/CodeGen/Queries/Products/Details/Fragments/ProductDetailsFragment.graphql:17-20,37-40`.
- `resolvedMedia = variantMedia.isEmpty ? fallbackMedia : variantMedia`, where `fallbackMedia` is the
  single `primaryImage` — `Alfie/AlfieKit/Sources/Core/Services/BFFService/Converters/ProductDetails+Converter.swift:10-13,111-114`.
- Gallery = `selectedVariant?.media` — `Alfie/AlfieKit/Sources/ProductDetails/UI/ProductDetailsViewModel.swift:60`;
  `Product.Variant.media` is `colour?.media` — `Alfie/AlfieKit/Sources/Model/Models/Product/Product.swift:80-82`.
- The colour swatch is `resolvedMedia.first` (`ProductDetails+Converter.swift:120-127`), so a colour's
  swatch is its variant's first media item.
- Every `Media` is built as `.image`; the domain enum has a `.video` case that the BFF path never
  produces (`ProductDetails+Converter.swift:165-169`, `Alfie/AlfieKit/Sources/Model/Models/Base/Media.swift:3-5`).
- Already documented: "The gallery can currently show only one image — needs its own ticket"
  (`Docs/Specs/Features/ProductDetailsModernDesign.md:357-389`).

**Android** [V, at a possibly stale checkout]
- Selects `images`, `primaryImage` and `variants { media }` —
  `network/src/main/graphql/bff/fragments/ProductFragment.graphql:27-29,39-44`.
- `variantImages.ifEmpty { images }` — `feature/pdp/…/ProductDetailsUIFactory.kt:168-174`; on colour
  change, falls back to the existing gallery — `:114-119`.
- Bag `variant?.media?.firstOrNull()` — `feature/bag/…/BagUiFactory.kt:48`; wishlist
  `defaultVariant?.media?.firstOrNull()` — `feature/wishlist/…/WishlistUIFactory.kt:45`.

**Web** [V, at a possibly stale checkout]
- `ProductDetail` fragment selects `images` and no variant `media` —
  `src/components/product/product-detail.tsx:32-35`; gallery `<ProductGallery images={p.images} …/>` — `:242`.

### What a shopper sees today [I — derived from §2 and §4, not observed on devices]

| | SCAYLE | Shopify | BigCommerce |
|---|---|---|---|
| iOS PDP gallery | **1 image** | **1 image** | **1 image** |
| Android PDP gallery | all images | **1 image** (variant image wins over `images`) | ≤ 10 images |
| Web PDP gallery | all images | ≤ 10 images | ≤ 10 images |
| Android bag / wishlist thumbnail | blank | variant image | blank |
| Colour picker | none; sibling colours unreachable | from options | none (`optionValues: []`, AF-130) |

---

## 5. AF-155 against the evidence

| AF-155 says | Verdict | Evidence |
|---|---|---|
| On SCAYLE, every variant has empty `media` | **Confirmed in code** [V]; not re-checked on the live tenant. Precisely: the field is unset → `null` | `scayle-adapter.service.ts:746-767` |
| Photos are only on the product's `images` | **Confirmed**, plus a duplicate in product `media` [V] | `:674-676`, `:864`, `:878` |
| Scope is `productDetails` | **Too narrow.** Same mapper serves list, search and related [V] | `:625`, `:655`, `:842`; `scayle.service.ts:457` |
| "A client that shows the photos of the selected variant has nothing to show" | **Contradicted.** iOS shows one image, Android shows the full product gallery, Web never reads the field [V] | §4 |
| Shopify "has photos on the product and the variant" | **Imprecise.** One image per variant, which itself falls back to the product image; the gallery is product-level [V] | §3.2 |
| Shopify variant = "one colour and size" | **Imprecise.** Any option combination [V] | §3.2 |
| SCAYLE product = "one colour of a style"; variant = "one size" | **Supported as the documented default**; tenant-configurable; not verified for this tenant's data [V/I] | §3.1 |
| SCAYLE "has photos on the product only" | **Confirmed** [V] | §3.1 |
| Expected: variant `media` = the product's N photos | **A new definition, not an existing one.** Shopify yields ≤ 1 and BigCommerce 0 under the same field [V] | §2.2 |
| Fix: copy product images into each variant in `normalizeVariant` | **Mechanically sound and SCAYLE-correct** (one product = one colour ⇒ product photos are that variant's photos). **Does not fix the defect class**: iOS stays at one image on Shopify and BigCommerce [I] | §4 |
| "Schema stays the same" | True, and that is the problem: the field still has no stated meaning [I] | `schema.gql:243` |
| "Shopify and BigCommerce responses are the same as before" | Achievable; it also freezes the divergence AF-130 lists as `ProductVariant.media` [I] | AF-130 "Stubbed on one side" |
| Open question: skip the copy when the product has a colour option | **Weak guard.** (a) The adapter detects colour by key pattern `/colou?r/i` on *variant* attributes (`:124`, `:805-825`), and its own spec notes "No colour attribute exists anywhere on the live tenant (432 products scanned)" (`scayle-adapter.service.spec.ts:2247-2249`) — so the branch is untestable against real data. (b) If it ever fired, SCAYLE still has no per-variant image, so the alternative is `null` → iOS falls back to one image; neither outcome is right. The only upstream signal that could split images by colour is image `attributes`, which the adapter drops [V for facts, I for conclusion] | §3.1 |
| Related: AF-130 tracks `ProductVariant.media` | **Confirmed**, but AF-130's line references are stale (`B:802-806` is now `:751-755`) and its remedy ("request `media`" on BigCommerce) names a field that does not exist [V] | §3.3 |

Not in the ticket at all:
- **SCAYLE colour = sibling products**, never requested. A SCAYLE PDP cannot offer other colours. This is
  the real "colour" issue on SCAYLE and is independent of media. [V]
- **Video / 3D** is dropped on all three platforms and unrepresentable in the schema. [V]
- **`Image` metadata** — no dimensions, role or kind; alt text is always `''` on SCAYLE. [V]
- **Truncation at 10** on Shopify (explicit) and BigCommerce (default). [V]
- **BigCommerce variant mapping targets a non-existent field.** [V]
- **No conformance invariant** covers any image field. [V]

---

## 6. The decision AF-155 is missing

The fix depends on which definition the contract adopts. Both are defensible; they lead to different
work. [I — framing, not a finding]

| | A. `media` = this variant's **own** image(s); may be empty | B. `media` = the **gallery** for this variant; never empty when the product has images |
|---|---|---|
| Matches upstream | Yes, all three (0 / 1 / 1) | No; synthesised by every adapter |
| SCAYLE | leave unset (or `[]`) — AF-155 becomes "won't fix" | copy product images (AF-155 as written) |
| Shopify | as today | must merge variant `image` with product `images`; no upstream rule says which product images belong to which variant |
| BigCommerce | select `defaultImage` | same merge problem |
| Clients | gallery = `OmniProduct.images`, variant image used to pick the start frame / swatch. iOS must select `images` (Android and Web already do) | unchanged |
| Cost | one iOS fragment + converter change; one BigCommerce query change | three adapter changes plus a per-colour image-assignment rule that Shopify and BigCommerce do not supply |

Under either, the field needs a schema description and a conformance invariant, or it will drift again.

---

## 7. Unknowns

- **Live tenant data.** Whether SCAYLE products on the tenant share `masterKey`s (i.e. have colour
  siblings), carry a product-level colour attribute, set image attributes such as `primaryImage` /
  `type`, or return `Image.url`. No credentials were used.
- **Deployed config.** Whether `imageBaseUrl` is set where the SCAYLE BFF runs; without it URLs are bare
  hashes (`scayle-adapter.service.ts:1137-1142`).
- **Real Shopify / BigCommerce stores.** Whether any product exceeds 10 images or 10 variants; whether
  BigCommerce variants have `defaultImage`s set.
- **Device behaviour.** §4's "what a shopper sees" is derived from code, not observed.
- **Android and Web** were read at local checkouts dated 2026-08-24 and 2026-09-01.
- **SCAYLE CDN modifier grammar** and **Shopify 3D on mobile** were not researched.
- **AF-129, AF-118, AF-127** were not read.

## Sources

SCAYLE
- [Entities](https://scayle.dev/documentation/the-basics/products/entities)
- [Media (Panel)](https://scayle.dev/documentation/the-basics/products/products-in-scayle-panel/media)
- [Manage Media / Assets](https://scayle.dev/documentation/the-basics/products/manage-products-via-api/manage-media-assets)
- [Manage Media / Videos](https://scayle.dev/documentation/the-basics/products/manage-products-via-api/manage-media-videos)
- [Storefront Application — Product Detail Page](https://scayle.dev/documentation/storefront/storefront-application/features/product-detail-page)
- [Storefront Application — PDP customization](https://scayle.dev/documentation/storefront/storefront-application/features/product-detail-page/customization)
- [Storefront Application — Images](https://scayle.dev/documentation/storefront/storefront-application/features/images)
- [Storefront API — get a product (OpenAPI)](https://scayle.dev/open_api_specs/storefront-api-latest/v1_products_productId_get.json)
- [Docs index](https://scayle.dev/llms.txt)
- `@scayle/storefront-api@18.21.0` type declarations, as installed in `Alfie-BFF/node_modules`

Shopify (Storefront API 2026-10 unless noted)
- [Product](https://shopify.dev/docs/api/storefront/latest/objects/Product)
- [ProductVariant](https://shopify.dev/docs/api/storefront/latest/objects/ProductVariant)
- [Media](https://shopify.dev/docs/api/storefront/latest/interfaces/Media)
- [MediaContentType](https://shopify.dev/docs/api/storefront/latest/enums/MediaContentType)
- [MediaImage](https://shopify.dev/docs/api/storefront/latest/objects/MediaImage), [Video](https://shopify.dev/docs/api/storefront/latest/objects/Video), [ExternalVideo](https://shopify.dev/docs/api/storefront/latest/objects/ExternalVideo), [Model3d](https://shopify.dev/docs/api/storefront/latest/objects/Model3d)
- [Image](https://shopify.dev/docs/api/storefront/latest/objects/Image)
- [ImageTransformInput](https://shopify.dev/docs/api/storefront/latest/input-objects/ImageTransformInput)
- [Admin API — ProductVariant](https://shopify.dev/docs/api/admin-graphql/latest/objects/ProductVariant)

BigCommerce
- [GraphQL Storefront — Product](https://docs.bigcommerce.com/developer/api-reference/graphql/storefront/types/objects/product)
- [GraphQL Storefront — Variant](https://docs.bigcommerce.com/developer/api-reference/graphql/storefront/types/objects/variant)
- [GraphQL Storefront — Image](https://docs.bigcommerce.com/developer/api-reference/graphql/storefront/types/objects/image)
- [GraphQL Storefront — Video](https://docs.bigcommerce.com/developer/api-reference/graphql/storefront/types/objects/video)
- [GraphQL Storefront — SwatchOptionValue](https://docs.bigcommerce.com/developer/api-reference/graphql/storefront/types/objects/swatch-option-value)
- [GraphQL Storefront API overview](https://docs.bigcommerce.com/developer/docs/storefront/guides/graphql-storefront-api/overview)
- [GraphQL Storefront — Variants guide](https://docs.bigcommerce.com/developer/docs/storefront/guides/graphql-storefront-api/products-and-catalog/variants)
- [Catalog overview](https://docs.bigcommerce.com/developer/docs/admin/catalog-and-inventory/products-overview)
- [REST — list product images](https://docs.bigcommerce.com/developer/api-reference/rest/admin/catalog/products/images/get-product-images)
- [REST — create product variant image](https://docs.bigcommerce.com/developer/api-reference/rest/admin/catalog/product-variants/images/create-product-variant-image)
- [REST — create product video](https://docs.bigcommerce.com/developer/api-reference/rest/admin/catalog/products/videos/create-product-video)

Jira
- [AF-155](https://mindera.atlassian.net/browse/AF-155), [AF-130](https://mindera.atlassian.net/browse/AF-130), [AF-124](https://mindera.atlassian.net/browse/AF-124)
