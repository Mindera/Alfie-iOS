---
title: Implement Product Details via BFF
ticket: ALFMOB-332
status: in-progress
mode: hard
blockedBy: []
blocks: []
created: 2026-06-01
---

## Base Branch

Branch `ALFMOB-332-pdp-bff-integration` off **`ALFMOB-334-bff-error-observability`** (NOT `main`).
Stack: `main` → `ALFMOB-331` (PLP, PR #74) → `ALFMOB-334` (error/observability, PR #75) → `ALFMOB-332`.
334 fully contains the 331 BFF foundation (`executeFetch`, `CancellableBox`, `ProductListing+Converter`,
the `getProduct` stub) plus the error-handling our PDP error mapping uses. PR targets 334 until the
stack lands in `main`, then rebase.

## Progress (2026-06-01)

- ✅ **Phase 1** — `ProductDetailsQuery` + `ProductDetailsFragment` authored, Apollo codegen run.
- ✅ **Phase 2** — `ProductDetails+Converter` (options→typed colour/size, default-variant rule, stock
  from `inventory.available`, HTML strip), `getProduct(handle:platform:)` across protocols/client/
  mocks.
- ✅ **Platform resolved** (team, 2026-06-01) — `platform` is a **predefined app-level** choice, NOT
  per-product. Added `BFFPlatform` enum `{ shopify, bigCommerce }` with a single
  `BFFPlatform.predefined = .shopify` source of truth; signatures now take `BFFPlatform`. The earlier
  empty-string fail-safe was removed (the enum is always valid). **List-tap PDP entry is now fully
  functional** (handle = product `slug`, platform = `.predefined`).
- ✅ **Phase 4 (partial)** — 14 converter unit tests + `ProductServiceTests` signature update + PDP
  ViewModel test signatures. `./Alfie/scripts/verify.sh` → ✅ 466 tests pass, 0 fail.
- 🟡 **Phase 3 (entry-point wiring)** — list-tap / `.product` / `.selectedProduct` entries DONE (slug
  handle + predefined platform). Only the **deep-link `.id` path** remains: it passes the 8-digit id as
  the handle (TODO marker) pending Open Q #1 (handle source). Deep-link parser / FlowViewModel /
  AppFeature not yet rewired.

### Accepted for now (decided 2026-06-01)
- **Colour swatch imagery** — the BFF exposes no dedicated swatch source (`Image` is only `{url,altText}`,
  no hex). Swatches fall back to the variant's first product photo, else a solid colour. **Accepted as-is**
  — colours still function (selection drives the variant); proper swatches (BFF hex value or dedicated
  swatch-image URL; iOS `SwatchType` already supports both) to be wired when the BFF provides them.

### Code-review follow-ups (deferred, not blocking Phase 1-2)
- ✅ **Sale price now renders (AC3, fixed 2026-06-01)** — converter now leaves `priceRange` nil for
  single-price products (`low == high`), so `Product.priceType` reaches its `.sale` branch and shows
  the struck-through `was` price. Covered by 3 converter tests. (Range products still show `.range`;
  the model can't express range + sale simultaneously — accepted.)
- ✅ **Variant media for colourless products now surfaced (fixed 2026-06-01)** — Shopify single-option
  ("Title") products (e.g. `sandals-lv`, `capucines-bb`) showed a blank PDP carousel because media was
  carried only on a `colour` that didn't exist. Converter now wraps variant media (falling back to the
  product `primaryImage`) in a nameless colour when there's no colour option. 2 tests added.
- ~~Variant media dropped when a variant has no colour option~~ (superseded by the fix above) — `Product.Variant.media` reads
  `colour?.media`; a colourless variant with images shows an empty carousel. Model coupling; edge case
  (most PDP products have colour). (Important — confirm BFF contract or carry media without colour)
- **Money `Float`→minor-units rounding + `amountFormatted` locale** — inherited from PLP
  `MoneyFragment.toDomainMoney()`; not locale-aware (wrong for 0-decimal currencies). Pre-existing
  known follow-up, now also on the PDP path. (Important, shared with PLP)
- **`defaultVariantId` may point at an out-of-stock variant** → selected as default. Confirm product
  rule (ties into Open Q "default-variant selection rule"). (product decision)
- **Colour identity is the raw option value** — `"Red"` vs `"red"` would not dedup; first-occurrence
  media wins on dedup. Normalise key if BFF data proves dirty. (minor)
- **GraphQL error→`.notFound` vs `.generic` inconsistency** — a backend "not found" GraphQL *error*
  maps to `.generic`, while a `null productDetails` maps to `.notFound`. Lives in the 334 error layer.

## Inherited from base branch 334 — do NOT rebuild

Re-scout on the 334 base found the PDP **error/observability path is already complete**. Scope shrinks
accordingly — we wire the happy path and let the existing layer handle failures:

- `ProductDetailsViewErrorType` + `ProductDetailsViewErrorType.from(error:)` — maps `BFFRequestError`
  → `.notFound` / `.rateLimited` / `.serverError` / `.noInternet` / `.generic`. **Done.**
- `ProductDetailsViewModel.loadProductIfNeeded()` (line 233–239) already catches any error and sets
  `state = .error(ProductDetailsViewErrorType.from(error:))`. We change **only** the `getProduct` call
  on line 234 — the catch block is untouched.
- `ProductDetailsView` error UI (`errorView`, lines ~219–237 / 530–543) + L10n keys. **Done.**
- `executeFetch` auto-calls `reportError(_:operationName:)` on `BFFRequestError` (line 159–160) →
  `BFFErrorReporter` (Analytics + Crashlytics). **Telemetry is automatic** — don't call it manually.
- `RetryInterceptor` + `RetryAfterParser` run for every query in the interceptor chain → `getProduct`
  inherits exponential backoff + RFC-7231 `Retry-After` **for free**.
- `ProductService.getProduct` already remaps `isNotFound` → `.product(.noProduct)`, else `.generic`.

Net: implementing `getProduct` = author query + converter + flip the call signature. Errors, retry,
telemetry, and the error UI all come from 334.

## Overview

Rewire the PDP (`ProductDetails` module) from the obsolete BFF schema onto the current
`productDetails(handle:platform:): OmniProduct` query. `BFFClientService.getProduct` is currently a
stub that throws `.generic` (left by ALFMOB-331). We add the GraphQL operation, a converter that maps
`OmniProduct` → domain `Product` (rebuilding typed colour/size selectors from generic
`OmniVariant.optionValues[]`), change the service signatures from `id` → `handle`/`platform`, thread
the handle through PDP entry points, and select a default variant from `defaultVariantId`.

This mirrors the PLP integration already on this branch (`ProductListing+Converter`,
`ProductListQuery`) — reuse those patterns for DRY.

## Acceptance Criteria

- AC1 — PDP loads against the BFF `productDetails` query.
- AC2 — Colour and size selectors render from `OmniVariant.optionValues[]`.
- AC3 — Selected variant drives price and stock state.
- AC4 — A default variant is selected on load using a defined rule.
- AC5 — HTML description renders (or is sanitised to plaintext) per design.
- AC6 — No references remain to the obsolete `GetProductQuery` / `defaultVariant` (data source) /
  `colours` / `stock` field names from the old schema.

## Schema Reality Check (corrections to ticket assumptions)

Read from `BFFGraph/CodeGen/Schema/schema.graphqls` — the ticket's field names are slightly off:

| Ticket says | Actual current schema |
|---|---|
| `productDetails(handle, platform): OmniProduct` | ✅ confirmed (`Query.productDetails`, line 137) |
| `variants[].inventoryQuantity` | Actually `ProductVariant.inventory.available: Int` |
| `defaultVariant` **no longer returned** | ❌ wrong — `OmniProduct.defaultVariantId: String` **IS** returned |
| `OmniVariant.options: [{name,value}]` | Type is `ProductVariant.optionValues: [VariantOption!]!` where `VariantOption {name, value}`; product-level dimensions in `OmniProduct.options: [ProductOption{name, values[]}]` |
| colour swatch from `images[]`/`metafield[]` | `Image {url, altText}` only — **no hex / dedicated swatch field**. Best source = per-variant `media: [Image]`. |

Field renames confirmed present: `brandName`, `descriptionHtml`. Dropped: `styleNumber`,
`shortDescription`, `labels` (no equivalent). `ProductVariant.attributes: [Metafield]` exists.

## Approach

**Single approach** (no competing designs needed — the PLP converter is the proven template):

1. Add `ProductDetailsQuery` + `ProductDetailsFragment` `.graphql`, run Apollo codegen.
2. New `ProductDetails+Converter.swift` maps `OmniProduct` → `Product`, deriving colour/size from
   `optionValues[]` via a case-insensitive name-matching layer.
3. Change `getProduct(id:)` → `getProduct(handle:platform:)` across protocols, service, client, mocks.
4. Thread `handle` (= product `slug`) through `ProductDetailsConfiguration` + entry points; deep link
   parser yields a slug.
5. Default-variant rule in the converter / ViewModel.

### Design decisions (resolving ticket Open Questions)

- **handle** = product `slug`. PLP `Product` already carries `slug`, so `.product` entry threads it
  directly. Deep-link parser changes to capture the slug path segment.
  ⚠️ *Open Q — needs BFF/PM confirm: does `productDetails.handle` equal Shopify-style slug, and does
  the deep-link URL format expose a slug vs the current 8-digit id?* (see Open Questions)
- **platform** = a constant `BFFPlatform.ios` (string value TBC with BFF — likely `"ios"`).
- **colour/size mapping** — read each variant's `optionValues` (`ProductVariant.optionValues:
  [VariantOption{name,value}]` — the ticket's `OmniVariant.options` doesn't exist by that name). Match
  `name` case-insensitively: colour ∈ {`color`,`colour`}, size ∈ {`size`}. Derive
  `Product.Colour`/`ProductSize` per variant. Stable `id` = the option value string. Graceful fallback:
  unmatched option names → colour/size nil (the selectors already hide when items ≤ 1 / empty).
- **ordering** — selectors follow the `variants[]` array order as the BFF returns it. We do **not**
  fetch/read `OmniProduct.options` and do **not** re-sort (no fixed S→M→L).
- **swatch imagery** — no swatch/hex field exists. Use the variant's first `media` image as
  `Colour.swatch` (`SwatchType.url`); existing code already falls back to `.color(black)` when nil.
  ⚠️ *Open Q — proper swatches need BFF support (a metafield). Best-effort for now.*
- **default variant** — pick `variants.first { id == defaultVariantId }`; else first variant with
  `inventory.available > 0`; else first variant. (Colour auto-selects from it; size still requires a
  user tap, preserving current UX.)
- **HTML description** — strip `descriptionHtml` to plaintext for this ticket (cheap, matches "or
  sanitise to plaintext as design dictates"). Full HTML rendering = follow-up.
  ⚠️ *Open Q — design to confirm strip vs render.*
- **dropped fields** — `styleNumber`/`shortDescription` → `""` (model requires non-optional String);
  `attributes` mapped from variant `attributes: [Metafield]` if `AttributeCollection` allows, else nil.

## Phases

1. **Data / GraphQL** — add `ProductDetailsQuery` + fragment, codegen. → `phase-1-graphql.md`
2. **Converter + service signature** — `OmniProduct`→`Product` mapping, options→selectors,
   default-variant rule, `getProduct(handle:platform:)` across protocols/client/mocks.
   → `phase-2-data.md`
3. **PDP wiring** — `ProductDetailsConfiguration` handle, entry points, deep-link parser, ViewModel
   call site + `productId`→`productHandle`, HTML strip. → `phase-3-ui.md`
4. **Tests** — unit (converter, ViewModel default-variant + selectors), update ProductServiceTests,
   UITest sanity. → `phase-4-tests.md`

## File Changes (Summary Table)

| File | Module | Type | Change |
|------|--------|------|--------|
| `BFFGraph/CodeGen/Queries/Products/Details/ProductDetailsQuery.graphql` | BFFGraph | New | `productDetails` operation |
| `BFFGraph/CodeGen/Queries/Products/Details/Fragments/ProductDetailsFragment.graphql` | BFFGraph | New | Field set on `OmniProduct` |
| `BFFGraph/API/**` | BFFGraph | Generated | Apollo codegen output — DO NOT hand-edit |
| `Core/Services/BFFService/Converters/ProductDetails+Converter.swift` | Core | New | `OmniProduct`→`Product`, options→colour/size, default variant |
| `Core/Services/BFFService/BFFClientService.swift:58` | Core | Service | Implement `getProduct(handle:platform:)` |
| `Core/Services/API/Product/ProductService.swift:13` | Core | Service | Signature → `handle`/`platform` |
| `Model/Services/Product/ProductServiceProtocol.swift:4` | Model | Protocol | Signature change |
| `Model/Services/BFFService/BFFClientServiceProtocol.swift:5` | Model | Protocol | Signature change |
| `Mocks/Core/Services/MockProductService.swift:8` | Mocks | Mock | Signature change |
| `Mocks/Core/Services/MockBFFClientService.swift:12` | Mocks | Mock | Signature change |
| `Core/.../BFFPlatform.swift` (or const) | Core | New | `platform` constant |
| `ProductDetails/Models/ProductDetailsConfiguration.swift` | ProductDetails | Enum | Carry `handle` for `.id`/handle entry |
| `ProductDetails/UI/ProductDetailsViewModel.swift:25,234` | ProductDetails | ViewModel | `productId`→`productHandle`; call `getProduct(handle:platform:)`; HTML strip |
| `ProductListing/Navigation/ProductListingFlowViewModel.swift:100` | ProductListing | Flow | Pass slug/handle on list tap |
| `AppFeature/Navigation/AppFeatureViewModel.swift:228` | AppFeature | Flow | Map deep link to handle |
| `DeepLink/Parsers/ProductDetailsDeepLinkParser.swift:55` | DeepLink | Parser | Extract slug handle |
| `Utils/.../HTMLString.swift` (or existing util) | Utils | New | Strip HTML → plaintext |
| `Tests/CoreTests/.../ProductDetails*ConverterTests.swift` | Tests | Unit | Converter cases |
| `Tests/CoreTests/ServiceTests/ProductServiceTests.swift` | Tests | Unit | Signature + cases |
| `Tests/ProductDetailsTests/ProductDetailsViewModelTests.swift` | Tests | Unit | default-variant + selector cases |

## Feature Flag

- Name: **n/a** — this is a like-for-like rewire of an already-stubbed (non-functional) screen, not a
  new user-facing feature. The PLP rewire on this branch carries no flag either; match that.
- If PM wants a kill-switch, gate `getProduct` behind an existing config check — but default behaviour
  is "the PDP simply works again".

## Testing Strategy

- **Unit (primary):**
  - `ProductDetails+Converter` — option name matching (color/colour/size, mixed case), default-variant
    rule (defaultVariantId hit / miss → first-in-stock / all-out-of-stock), stock from
    `inventory.available`, brandName/descriptionHtml mapping, graceful fallback for unknown option
    names, HTML strip.
  - `ProductDetailsViewModel` — extend existing 73 tests for new fetch signature, default-variant
    pre-selection, price/stock driven by selected variant.
  - `ProductServiceTests` — `getProduct(handle:platform:)` calls client, error mapping unchanged.
  - **Do NOT** re-test PDP error mapping — `ViewErrorTypeMappingTests` (334) already covers
    `BFFRequestError` → `ProductDetailsViewErrorType`. Retry/telemetry tested by 334's interceptor tests.
- **Snapshot:** none new — selectors already snapshot-tested; verify no regressions.
- **XCUITest:** `ProductDetailsPage` locators unchanged (`colourSelector`/`sizeSelector` AccessibilityIDs
  already exist). Smoke that PDP renders; full integration test is ALFMOB-335 (out of scope).

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Deep-link only has 8-digit id, not a slug `handle` | High | Phase 3 blocked on Open Q #1; interim: bad handle → null `productDetails` → `.notFound` → existing 334 error UI renders it cleanly (no build break, no masked failure) |
| BFF returns option names other than color/size | Med | Case-insensitive match + nil fallback; log unmatched names |
| No real colour swatch source | High | Variant media fallback now; flag BFF metafield follow-up |
| `platform` string value wrong | Med | Single constant, easy to flip; confirm at refinement |
| Money major→minor rounding (inherited from PLP converter) | Low | Reuse existing `MoneyFragment.toDomainMoney()`; same known follow-up |
| Apollo codegen drift / generated files committed | Low | Run `run-apollo-codegen.sh`, never hand-edit `API/` |

## Out of Scope

- PLP rewiring (ALFMOB-331), Search (ALFMOB-333), error/retry (ALFMOB-334), integration tests
  (ALFMOB-335), add-to-bag / Bag domain.
- Full HTML rendering (plaintext strip only this ticket).
- BFF schema changes (e.g. exposing colour swatches) — escalate, don't implement client-side.

## Open Questions (resolve at refinement — some block implementation)

0. ✅ **RESOLVED (team, 2026-06-01)** — `platform` is a **predefined app-level** choice, not
   per-product. Modelled as `BFFPlatform { shopify, bigCommerce }` with `BFFPlatform.predefined =
   .shopify`. (Earlier worry — that `OmniProduct` has no platform field to derive from — is moot now
   that the value is a fixed app constant rather than product-sourced.)
1. **[Deep-link path — tracked in ALFMOB-386]** The deep-link parser extracts only the legacy 8-digit
   id and routing forwards it as the handle, but the BFF resolves by slug. Spun off to **ALFMOB-386**
   (Spike) to confirm the Shopify slug format (id-suffixed vs bare handle) and BigCommerce handle
   semantics before rewiring the parser/routing. List-tap entry already works (carries real `slug`).
3. Colour swatch image source — accept variant `media` best-effort, or wait for a BFF metafield?
4. Description — strip to plaintext (this plan) vs render HTML (follow-up)?
5. Are dropped fields (`styleNumber`, `shortDescription`, `labels`, `attributes`) still needed by
   design? If yes → escalate to BFF.
