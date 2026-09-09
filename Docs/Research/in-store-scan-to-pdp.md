# Research: in-store scan → open Alfie iOS on the right PDP

**Status:** research / no approach committed to yet
**Date:** 2026-09-09
**Scenario:** a customer in a physical store picks up a garment (jeans, shorts), scans the code on
its swing tag / care label with a phone, and lands on that exact product's PDP inside the Alfie iOS
app.

## 0. Assumptions

The brief was dictated and two words are ambiguous. This document assumes:

- **"scan tobacco"** → scan the **barcode** (EAN-13 / UPC-A on the swing tag) or a **QR code**
  printed next to it.
- **"unfish application"** → an unidentified scanning app. Two readings are covered:
  - the scan happens **inside Alfie** (§3 option A), or
  - the scan happens **outside Alfie** — iOS Camera, or a third-party / retail-owned app — which
    then hands off to Alfie via a link (§3 options B–E).

If either guess is wrong, only §3 changes; §1, §2 and §4 hold regardless.

---

## 1. What Alfie already has (the good news)

Roughly 70% of the "…and then navigate to the PDP" half is already built and tested.

| Piece | Where |
|---|---|
| `DeepLink.LinkType.productDetail(slug:route:query:)` | `Alfie/AlfieKit/Sources/Model/Services/DeepLink/DeepLink.swift:19` |
| URL → deep link parsing for `/product/<slug>` | `Alfie/AlfieKit/Sources/DeepLink/Parsers/ProductDetailsDeepLinkParser.swift` |
| Parser registry + fallback to web view | `Alfie/AlfieKit/Sources/Core/Services/DeepLinking/DeepLinkService.swift` |
| Queueing links received before the UI is ready | `Alfie/AlfieKit/Sources/DeepLink/DeepLinkHandler.swift` (`pendingLinks`, `isReadyToHandleLinks`) |
| Routing a link to the PDP | `AppFeatureViewModel.navigate(for:)` → `.shop(.productDetails(.productDetails(.deepLink(handle:))))` |
| PDP entry point that accepts a deep-link handle | `Alfie/AlfieKit/Sources/ProductDetails/Models/ProductDetailsConfiguration.swift` |
| OS entry points already wired | `Alfie/Alfie/AlfieApp.swift` — `.onOpenURL` (custom scheme) **and** `.onContinueUserActivity(NSUserActivityTypeBrowsingWeb)` (universal links) |
| Custom URL scheme registered | `Alfie/Alfie/Info.plist` → `CFBundleURLSchemes = ["alfie"]` |
| Debug harness for firing links by hand | `Alfie/AlfieKit/Sources/DebugMenu/UI/DeepLinking/DeepLinkDemoView.swift` |
| Unit tests for all of the above | `Alfie/AlfieKit/Tests/DeepLinkTests/` |

So a URL of the shape `alfie://alfie.target/product/<slug>` or `https://<host>/product/<slug>`
**already opens the correct PDP today**. The unsolved half is everything upstream of that URL.

## 2. What is actually missing

Three real gaps, in order of difficulty.

### 2.1 Barcode → product resolution (the hard one)

The deep link carries a **slug** (`/product/mens-slim-jeans-indigo`). A swing tag carries an
**EAN-13 / UPC-A**, which identifies a **variant** — this style *in this colour, in this size*.
Nothing in the app or the BFF converts one to the other.

BFF schema evidence (`Alfie/AlfieKit/Sources/BFFGraph/CodeGen/Schema/schema.graphqls`):

```graphql
type ProductVariant {
  id: ID!
  sku: String!
  barcodes: [Barcode]     # Barcode = { type: String!, value: String! }
  ...
}

type Query {
  productDetails(handle: String!, ...): OmniProduct   # by slug only
  searchProducts(searchTerm: String!, ...): ProductListResponse!
  productList(collectionHandle: String!, ...): ProductListResponse!
}
```

The data exists on the variant, but **no query looks a product up by barcode or SKU**. Options,
best first:

1. **New BFF query** — `productByBarcode(value: String!, type: String)`, or an optional `barcode:`
   argument on `productDetails`, returning the `OmniProduct` plus the matching `variantId`. One
   round trip, and the BFF owns the platform differences (Shopify vs BigCommerce barcode indexing).
   **Recommended.**
2. **Reuse `searchProducts(searchTerm: <barcode>)`** — zero BFF work *if* the commerce platform
   indexes barcodes in search. Shopify's storefront search does not reliably match barcodes; treat
   this as a spike, not a plan.
3. **Put the slug in the tag instead** — print a QR containing
   `https://<host>/product/<slug>?variant=<variantId>` alongside the existing EAN. No BFF change at
   all, but it needs a change to tag artwork and the print pipeline: a retail-ops project, not an
   app project.

Side note: the PDP fragment already requests `variants { sku }` but **not** `variants { barcodes }`
(`Queries/Products/Details/Fragments/ProductDetailsFragment.graphql`). Worth adding either way, then
re-running `run-apollo-codegen.sh` — never hand-edit `BFFGraph/API/`.

### 2.2 Variant preselection

A barcode identifies a size and colour, not just a style. Landing on the PDP with nothing selected
throws away the most useful part of the scan. This needs:

- `DeepLink.LinkType.productDetail` to carry a variant. It already carries a `query: [String: String]?`
  dictionary parsed straight off the URL, so a `?variant=` parameter likely needs **no wire-format
  change** — only consumption downstream.
- `ProductDetailsConfiguration` / `ProductDetailsViewModel` to honour it and preselect the swatch
  and size.

This is also the highest-value part for the store: *"I'm holding a 32R — show me the 32R and whether
you have it."*

### 2.3 Universal-link hosting

`LinkConfiguration` currently accepts hosts `localhost` and `alfie.target`
(`Alfie/AlfieKit/Sources/Model/Models/Themed/ThemedURL.swift`). Real universal links need:

- a real HTTPS host,
- an `apple-app-site-association` file served from `/.well-known/` on it,
- the `com.apple.developer.associated-domains` entitlement — **`Alfie/Alfie/Alfie.entitlements`
  contains only `aps-environment` today**, so this is a genuine to-do.

Without it, only the `alfie://` custom scheme works. That is fine for a demo but fails the
"customer doesn't have the app" case and is trivially hijackable by another app claiming the same
scheme.

---

## 3. The five candidate mechanisms

| # | Mechanism | Needs app installed? | Physical change to tag | App work |
|---|---|---|---|---|
| A | In-app scanner (VisionKit) | Yes | **None** — reuses the existing EAN | Medium |
| B | QR on tag → universal link | No | New QR on tag | Low |
| C | NFC tag in garment / hangtag | No | New NFC inlay | Low–Medium |
| D | App Clip / App Clip Code | No (that's the point) | New code or NFC | High |
| E | Third-party app hands off via `alfie://` | Yes | None | Low |

### A. In-app barcode scanner — recommended first build

Customer opens Alfie → taps "Scan in store" → points at the swing tag → PDP.

- **API:** `VisionKit.DataScannerViewController` (iOS 16+, which matches Alfie's deployment target
  of exactly iOS 16.0). Live camera scanning of text and machine-readable codes; configure
  `.barcode(symbologies: [.ean13, .ean8, .upce, .code128, .qr])`.
- **Gate on `DataScannerViewController.isSupported`** (requires a Neural Engine device) **and**
  `.isAvailable` (permission / restrictions), with a graceful unsupported state. Fall back to
  `AVCaptureMetadataOutput` only if the older-device tail turns out to matter.
- Needs `NSCameraUsageDescription` in `Info.plist` — **currently absent**. Adding a new source file
  also means asking the user to add it to the Xcode project; do not edit `project.pbxproj`.
- **Architecture fit:** a new `Scanner` module under `AlfieKit/Sources` with a
  `ScannerViewModelProtocol`, `ViewState<ScannedCode, ScannerError>` state, a `ScannerFlowViewModel`
  closure routing into the existing `.productDetails(.deepLink(handle:))` route, `L10n` keys for
  every string, and `AccessibilityID` entries for UI tests. It reaches the barcode-resolution
  service through `DependencyContainer`.
- **Why first:** entirely within our control — no print run, no NFC procurement, no AASA hosting, no
  App Store Connect configuration. It also forces us to build §2.1, which every other option needs
  anyway.

### B. QR code on the swing tag → universal link

Print `https://<host>/product/<slug>?variant=<variantId>` as a QR next to the EAN. The **iOS Camera
app** recognises it with no app installed; tapping the banner opens Alfie if present, or the website
(with a Smart App Banner) if not.

- Almost no app work — the existing `ProductDetailsDeepLinkParser` already handles this URL shape.
- Requires §2.3 (AASA + entitlement) and a change to tag artwork.
- **Sidesteps the barcode-resolution problem entirely**, because the slug is already in the link.
  Cheapest path to a working end-to-end demo *if* someone can reprint tags.

### C. NFC tag

An NDEF tag in the hangtag holding the same universal link. iPhone XS and later read NDEF tags in
the **background** — no app open, no camera, the customer just taps the phone against the tag.
`CoreNFC` is only needed to read tags from *inside* Alfie (foreground session; requires the NFC
entitlement and `NFCReaderUsageDescription`).

- Best in-store experience by a distance. Highest hardware cost (an inlay per garment) and easiest
  to defeat — tags get removed or swapped between garments.
- Realistic scope: NFC on **fixture / shelf signage** for a category or hero product, EAN scanning
  for individual garments.

### D. App Clip

The real unlock for **customers who don't have Alfie installed** — the majority of people in a
store. An App Clip Code (a scannable Apple-designed marker, optionally with an embedded NFC tag), or
a plain QR, launches a lightweight PDP in seconds; if the full app is installed it deep-links
straight into it instead.

- Requires: a separate App Clip target (≤15 MB uncompressed), advanced App Clip experiences
  configured in App Store Connect, associated domains, and a slimmed PDP that runs without the full
  dependency graph. Apple recommends Type 5 NFC tags of at least 35 mm when embedding NFC in an App
  Clip Code.
- **Not a first step.** Phase 3. A modular `AlfieKit` makes the target feasible later, but
  `ProductDetails` currently pulls in a large dependency container that would need untangling.

### E. Hand-off from a third-party scanning app

If "the scanning app" is a separate, existing (possibly retail-owned) app, it can simply call
`UIApplication.open(URL(string: "alfie://alfie.target/product/<slug>")!)`. This works **today** with
no change to Alfie beyond §2.1 — but the *other* app then needs the barcode→slug mapping, which just
moves the hard problem across the boundary. Prefer a universal link even here, since custom schemes
give no ownership guarantee.

---

## 4. Recommended shape

```
Customer scans EAN-13 on the swing tag  (in-app scanner, option A)
        │
        ▼
Scanner module emits { rawCode, symbology }
        │
        ▼
BarcodeResolutionService ──▶ BFF: productByBarcode(value:type:)   ← NEW (§2.1)
        │                        returns { handle, variantId }
        ▼
DeepLink.LinkType.productDetail(slug: handle, query: ["variant": variantId])
        │
        ▼
Existing DeepLinkHandler → AppFeatureViewModel.navigate(for:)     ← unchanged
        │
        ▼
PDP opens: right product, right colour, right size
```

Routing through the **existing** `DeepLink` type rather than a bespoke scanner→PDP path means one
code path serves options A–E, it is already unit-tested (`Tests/DeepLinkTests/`), and navigation
stays inside the `FlowViewModel` convention.

### Phasing

1. **Phase 1 — app-only, demoable.** In-app scanner + barcode resolution + variant preselection.
   Depends on one new BFF query. No physical or retail-ops changes.
2. **Phase 2 — needs infrastructure.** Production host, AASA + associated-domains entitlement,
   QR/NFC on tags. Unlocks "scan with the Camera app, no Alfie needed".
3. **Phase 3 — needs a lot.** App Clip for customers without the app.

## 5. Open questions

- **Does the commerce platform actually hold barcodes for every variant?** `ProductVariant.barcodes`
  is nullable *and* a list. If the catalogue is sparse the premise fails for part of the range — a
  data audit should come before any code.
- Is the store's EAN the manufacturer's or a retailer-internal one? Determines whether one code maps
  to exactly one product.
- What happens on a miss — unknown code, own-brand item absent from the app catalogue, a code from a
  competitor's product? Needs a designed empty state, not a silent no-op.
- Store Wi-Fi reliability: a scan that needs a network round trip to resolve will feel broken on bad
  in-store connectivity. Worth measuring; a cached barcode→handle map is one mitigation.
- Analytics: an in-store scan is a genuinely new event type (`scan_to_pdp`) and probably the most
  commercially interesting signal in the whole feature.
- Does the retailer want the scan to also surface **stock at this store**? That is a different BFF
  capability, and arguably the real business case for the whole thing.

## Sources

- [DataScannerViewController — Apple Developer](https://developer.apple.com/documentation/visionkit/datascannerviewcontroller)
- [DataScannerViewController.isSupported](https://developer.apple.com/documentation/visionkit/datascannerviewcontroller/issupported)
- [Scanning data with the camera](https://developer.apple.com/documentation/visionkit/scanning-data-with-the-camera)
- [Capture machine-readable codes and text with VisionKit — WWDC22](https://developer.apple.com/videos/play/wwdc2022/10025/)
- [Creating App Clip Codes](https://developer.apple.com/documentation/appclip/creating-app-clip-codes)
- [Overview of App Clips — App Store Connect Help](https://developer.apple.com/help/app-store-connect/offer-app-clip-experiences/overview-of-app-clips/)
- [Configure and link your App Clips — WWDC20](https://developer.apple.com/videos/play/wwdc2020/10146/)
