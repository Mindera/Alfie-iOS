# Feature: In-Store Scan to Product Details

**Status**: Draft
**Created**: 2026-09-09
**Last Updated**: 2026-09-09
**Implementation PR**: _(link when implemented)_

---

## Overview

A shopper standing in a physical store picks up a garment, scans the **Alfie code** on its swing tag
with the Alfie app, and arrives on that Product's details page — where the existing size and colour
swatches already show what is and is not available.

This is a **feature demo for one client**, not a production rollout. It is deliberately scoped so
that nothing outside the iOS app has to change: no BFF work, no new commerce-platform credentials,
no hosted domain.

The central design decision is that Alfie **does not read the manufacturer's Barcode**. Neither
commerce platform can resolve a Barcode with the credentials the BFF holds — the Shopify Storefront
API has no `barcode:` filter, and reaching Shopify's Admin API would mean provisioning an
Admin-scoped token for a customer-facing service. Instead we print our own **Alfie code**, a QR code
that already contains the Handle. See `Docs/adr/0001-print-our-own-alfie-code.md`.

---

## User Stories

- **As a** shopper in a store, **I want to** scan the tag on a garment **so that** I can see the
  product in the app without searching for it by name
- **As a** shopper in a store, **I want to** see which sizes are available **so that** I know
  whether the garment is available in my size
- **As a** shopper in a store, **I want to** see which colours are available **so that** I can
  consider a colour that is not on the rail in front of me
- **As a** shopper, **I want** the scanner to tell me when I have scanned the wrong code **so that**
  I do not think the app is broken
- **As a** shopper who has declined camera access, **I want** a clear explanation **so that** I know
  why scanning does not work
- **As a** salesperson demonstrating the app, **I want** scanning to be reachable in one tap from
  the search bar **so that** I do not have to hunt for it
- **As a** solutions engineer running the demo, **I want** a repeatable way to generate Alfie codes
  **so that** I can add products the night before a client meeting

---

## Acceptance Criteria

### Scenario 1: Shopper opens the scanner

**GIVEN** the shopper is on a screen showing the _Search bar_
**WHEN** the shopper taps the _Scan button_ in the _Search bar_
**THEN** the _Scanner screen_ is presented modally
AND the camera preview starts
AND scanning guidance is shown

### Scenario 2: Shopper scans an Alfie code

**GIVEN** the shopper is on the _Scanner screen_
**WHEN** the camera recognises an Alfie code containing a valid Handle
**THEN** the _Scanner screen_ is dismissed
AND the shopper is navigated to the _Product Details screen_ for that Handle
AND the Product's default Variant is selected

### Scenario 3: Availability is visible on arrival

**GIVEN** the shopper has arrived on the _Product Details screen_ from a scan
**WHEN** the Product has a Variant with no stock
**THEN** that size is shown as unavailable in the _Sizing selector_
AND a colour with no available Variant is dimmed in the _Colour selector_
AND an availability note states that stock shown is online stock

### Scenario 4: Shopper scans the manufacturer's Barcode by mistake

**GIVEN** the shopper is on the _Scanner screen_
**WHEN** the camera recognises an EAN-13 Barcode instead of an Alfie code
**THEN** the scanner stays open
AND a message explains that this is the product's Barcode and that the Alfie code should be scanned
instead

### Scenario 5: Shopper scans an unrelated code

**GIVEN** the shopper is on the _Scanner screen_
**WHEN** the camera recognises a QR code that is not an Alfie code
**THEN** the existing deep-link fallback handles the URL
AND a Product Details screen is not opened

### Scenario 6: Camera permission is refused

**GIVEN** the shopper has denied camera access to Alfie
**WHEN** the shopper opens the _Scanner screen_
**THEN** an explanation is shown instead of the camera preview
AND a control is offered to open the system Settings

### Scenario 7: Device cannot scan

**GIVEN** the device does not support live data scanning
**WHEN** the shopper opens the _Scanner screen_
**THEN** an explanation is shown instead of the camera preview
AND no camera permission is requested

---

## Data Models

```swift
// What the scanner recognised
public enum ScannedCode: Equatable {
    /// A code carrying an Alfie link, e.g. https://localhost:4000/product/<handle>?sku=<sku>
    case alfieCode(URL)
    /// A manufacturer Barcode, which Alfie cannot resolve
    case barcode(value: String)
    /// Anything else the camera recognised
    case unrecognised(payload: String)
}

// ViewModel State Model
public struct ScannerViewStateModel: Equatable {
    let guidance: String
    let notice: String?
}

// Error Types
public enum ScannerViewErrorType: Error, Equatable {
    case cameraPermissionDenied
    case deviceNotSupported
    case generic
}
```

State is held as `ViewState<ScannerViewStateModel, ScannerViewErrorType>`.

---

## API Contracts

**None.** This feature adds no GraphQL query, mutation or fragment, and requires no BFF change. The
Handle travels inside the Alfie code, and the Product is then fetched by the existing
`ProductDetailsQuery(handle:)` through the existing deep-link path.

---

## Navigation

### Entry Points

- Any screen with the _Search bar_ → tap _Scan button_ → Scanner screen
- Scanner screen → recognises an Alfie code → Product Details screen

### Exit Points

- Tap _Close_ → returns to the presenting screen
- Successful scan → Product Details screen, in the Shop tab

### Routes and FlowViewModel Methods

The Scanner is **presented modally** and adds no `Route` case. On a successful scan it hands the URL
to the existing deep-link path:

```swift
// ScannerViewModel, on recognising an Alfie code
deepLinkService.openUrls([url])
```

`DeepLinkService` parses it with the existing `ProductDetailsDeepLinkParser`, and
`AppFeatureViewModel.navigate(for:)` routes it to
`.shop(.productDetails(.productDetails(.deepLink(handle:))))`. This means the scan reuses a
navigation path that is already covered by tests, and it accepts the existing behaviour that all
deep links land in the Shop tab.

---

## Localization

| Key | English | Notes |
|-----|---------|-------|
| `scanner.title` | "Scan" | Screen title |
| `scanner.guidance.message` | "Point the camera at the Alfie code on the tag" | Shown under the preview |
| `scanner.barcode_detected.message` | "That's the product barcode. Scan the Alfie code on the tag instead." | Scenario 4 |
| `scanner.unrecognised.message` | "That code isn't from Alfie." | Scenario 5 |
| `scanner.error.permission_denied.title` | "Camera access is off" | Scenario 6 |
| `scanner.error.permission_denied.message` | "Turn on camera access in Settings to scan tags." | Scenario 6 |
| `scanner.error.permission_denied.action` | "Open Settings" | Scenario 6 |
| `scanner.error.unsupported.message` | "This device can't scan codes." | Scenario 7 |
| `search.scan_button.accessibility_label` | "Scan a tag" | Search bar control |
| `pdp.availability.online_note` | "Availability shown is online stock" | Scenario 3 |

---

## Analytics

### Event: `scan_started`

**When**: The Scanner screen is presented
**Parameters**:
- `source`: String - Entry point, e.g. "search_bar"

### Event: `scan_succeeded`

**When**: An Alfie code is recognised and navigation begins
**Parameters**:
- `handle`: String - The Product Handle from the code
- `has_sku`: Bool - Whether the code carried a SKU

### Event: `scan_failed`

**When**: A code is recognised but cannot open a Product
**Parameters**:
- `reason`: String - "barcode" | "unrecognised" | "permission_denied" | "unsupported"

---

## Edge Cases

| Scenario | Expected Behavior |
|----------|-------------------|
| Alfie code carries a Handle the catalogue does not have | Existing Product Details error state handles it |
| Alfie code carries a `sku` parameter | Parsed and ignored; the default Variant is selected |
| Handle contains `/` (BigCommerce route path) | Parsed correctly — requires the parser fix below |
| Camera recognises two codes at once | First recognised code wins; scanner then stops recognising |
| Shopper scans while offline | Product Details shows its existing no-connection error state |
| Shopper scans the same code twice quickly | Second scan is ignored while navigation is in flight |
| App is backgrounded mid-scan | Scanning stops and resumes when the screen reappears |

---

## Dependencies

### Services Required

- `DeepLinkServiceProtocol` (Core/Services) - Parse the scanned URL and route to Product Details
- `AlfieAnalyticsTracker` (Core/Services) - Track scan events

### External Dependencies

- `VisionKit` — `DataScannerViewController`, iOS 16+, which matches the project's deployment target
- `NSCameraUsageDescription` in `Info.plist` — **not present today, must be added**

### Internal Dependencies

- ViewState: `ViewState<ScannerViewStateModel, ScannerViewErrorType>`
- `AccessibilityID` entries for the Scan button and the Scanner screen
- No new `Route` case, and no change to `DeepLink.LinkType`

---

## Testing Strategy

The seam is `CameraScanServiceProtocol`: the ViewModel receives recognised payload strings and is tested
without a camera. Everything downstream of the payload is existing, already-tested code.

### Unit Tests (`ScannerTests`)

- [ ] An Alfie code payload results in the URL being passed to `DeepLinkService`
- [ ] An EAN-13 payload produces the Barcode notice and does not navigate
- [ ] An unrecognised payload does not navigate
- [ ] Denied permission produces `.cameraPermissionDenied`
- [ ] An unsupported device produces `.deviceNotSupported` without requesting permission
- [ ] A second payload during navigation is ignored

### Unit Tests (`DeepLinkTests`)

- [ ] `ProductDetailsDeepLinkParser` parses a multi-segment Handle, e.g. `/product/mens/jeans/slim-indigo`
- [ ] An unknown `sku` query parameter is preserved and does not prevent parsing

Prior art: `Alfie/AlfieKit/Tests/DeepLinkTests/Parsers/ProductDetailsDeepLinkParserTests.swift`.

### Localization Tests (`SharedUITests`)

- [ ] All new keys exist in all supported languages

### Snapshot Tests

- [ ] Permission-denied state
- [ ] Device-unsupported state
- [ ] Barcode-detected notice

The camera preview itself is not tested — it is a system component, and the simulator has no camera.
The developer will verify the camera path manually on device.

---

## Accessibility

- The _Scan button_ has the label "Scan a tag"
- The Scanner screen announces its guidance text when presented
- Notices (Barcode detected, unrecognised code) are announced, not only shown
- All new controls carry `AccessibilityID` entries from the `AccessibilityIdentifiers` module

---

## Known Limitations

- **Availability is online stock, not store stock.** The BFF exposes `Inventory { available: Int }`
  with no location dimension, and neither adapter queries location-scoped inventory. The app cannot
  tell a shopper whether a size is in the store they are standing in. Scenario 3 states this
  explicitly on screen so nobody in the demo infers a capability that does not exist.
- **Manufacturer Barcodes are not resolvable.** Only Alfie codes work.
- **The printed URL does not resolve in a browser.** It points at `localhost:4000`, which is the
  configured host. Scanning an Alfie code with the iOS Camera app will not open Alfie.
- **The Variant is not preselected.** The scanned SKU is carried in the code but ignored; the
  shopper lands on the Product's default Variant.
- **The shopper must already have Alfie installed.** No App Clip, no universal links.

---

## Implementation Notes

- Alfie code payload format: `https://localhost:4000/product/<handle>?sku=<sku>`. The `sku` is
  printed now so that reprinting is not needed when preselection is implemented later.
- Configure the scanner for QR **and** EAN-13. EAN-13 is recognised only in order to show a helpful
  message; it is never resolved.
- Gate the scanner on both `DataScannerViewController.isSupported` and `.isAvailable`.
- `ProductDetailsDeepLinkParser` currently captures a single path segment, so a Handle containing
  `/` fails to parse and falls through to the web view. This is a pre-existing defect that affects
  BigCommerce Handles generally, not only scanning. Fix it as part of this work.
- A generator script lives in `Tools/`: it takes a list of Handles and writes print-ready PNG files.
- New Swift files must be added to the Xcode project by a human — agents must not edit
  `project.pbxproj`.
- For the demo, print codes for five to eight Products, of which at least two have an out-of-stock
  size and one has an unavailable colour. Verify the stock values against the running BFF before
  printing, because the catalogue is a real store and its stock changes.

---

## Questions & Decisions

### Decisions

- [x] Resolve the manufacturer's Barcode, or print our own code?
  - **Decision**: Print our own Alfie code. Barcode lookup is not possible with the BFF's
    credentials. See ADR-0001.
- [x] What does the Alfie code contain?
  - **Decision**: An `https` URL. It is parsed in-app, so no associated-domains entitlement is
    needed, and the format survives into a later phase that adds a real host.
- [x] Which host?
  - **Decision**: `localhost:4000`, matching the configured `LinkConfiguration` host. No config
    change needed.
- [x] Preselect the scanned Variant?
  - **Decision**: No. Carry the SKU in the code, implement preselection later.
- [x] Recognise EAN-13?
  - **Decision**: Yes, to show a helpful message. It is the most likely demo mishap.

### Open Questions

- [ ] Which five to eight Products are printed for the demo? Needs the live catalogue checked.

---

## Changelog

| Date | Change | Author |
|------|--------|--------|
| 2026-09-09 | Initial spec created from `/grill-with-docs` session | Khoi Nguyen |
