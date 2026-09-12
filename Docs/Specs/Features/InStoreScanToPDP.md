# Feature: In-Store Scan to Product Details

**Status**: Implemented
**Created**: 2026-09-09
**Last Updated**: 2026-09-12
**Implementation PR**: #146 (`feature/gh-133-in-store-scan-to-pdp` → `main`)

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
**WHEN** the camera recognises a QR code that opens nothing in Alfie
**THEN** the scanner stays open and a notice says so
AND a Product Details screen is not opened

> Amended by #138. This scenario originally handed the URL to the existing deep-link fallback, which
> would open an arbitrary scanned link in a web view — a stranger's QR code deciding what the app
> shows. The scanner now classifies the payload and says so instead.
>
> "Opens nothing" is the test, not "is not a Product". An Alfie code carries an Alfie link and the
> deep-link path decides where it lands, so a code resolving to any in-app destination is opened
> normally. The notice is for the three that reach nothing: a link that is not ours, one we cannot
> parse, and one whose only route is the web-view fallback this scenario exists to prevent.

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

    /// Which of several codes read in one frame is acted on — lower first. A Swing tag prints both
    /// codes side by side, so both are routinely read at once and the Alfie code has to win.
    public var precedence: Int { ... }

    /// Thirteen digits with a valid EAN-13 check digit. The check digit is tested and not merely the
    /// shape, so a QR code holding thirteen digits is not answered with "that's the product barcode".
    public static func isBarcode(_ payload: String) -> Bool { ... }
}

public extension Collection where Element == ScannedCode {
    /// The one code the scanner acts on out of everything the camera is holding. Ties keep the
    /// camera's own order. This is what `ScannerViewModel` calls.
    var codeToActOn: ScannedCode? { ... }
}
// Built by #139. #138 needed only Alfie-code-or-not, which one `guard` expressed; the manufacturer
// Barcode is what made the third case real.

// ViewModel State Model
public struct ScannerViewStateModel: Equatable {
    let guidance: String
    let notice: ScannerNotice?
}

// A notice carries an identity as well as its words, because it is an event rather than a state:
// a second bad code says what the first one said, and the screen announces on change.
public struct ScannerNotice: Equatable, Identifiable {
    public let id: Int
    public let message: String
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

The Scanner is **presented modally** and adds no `Route` case. The ViewModel owns no navigation of
its own: on recognising an Alfie code it hands the URL back over the `openScannedLink` closure it was
built with, and the wiring behind that closure passes it to the existing deep-link path. Classifying
the payload is the scanner's job — a code that opens nothing must leave the camera running — while
opening the page is not.

```swift
// ScannerPresentation.makeViewModel, shared by every tab that offers Scan
openScannedLink: { deepLinkService.openUrls([$0]) }
```

That construction lives in one place rather than in each tab's `FlowViewModel`: the three decisions
behind it — where a recognised link goes, that Settings is the one recovery a refused camera has,
and that closing clears the tab's overlay — are the same wherever the Scan control appears. Only the
last is supplied by the tab, because only the tab knows what it is covering.

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
| `scanner.unrecognised.message` | "That code doesn't open anything in Alfie." | Scenario 5 |
| `scanner.error.permission_denied.title` | "Camera access is off" | Scenario 6 |
| `scanner.error.permission_denied.message` | "Turn on camera access in Settings to scan tags." | Scenario 6 |
| `scanner.error.permission_denied.action` | "Open Settings" | Scenario 6 |
| `scanner.error.unsupported.message` | "This device can't scan codes." | Scenario 7 |
| `scanner.error.generic.message` | "Something went wrong." | A permitted camera that will not start |
| `accessibility.scan` | "Scan a tag" | Search bar control. Shipped under the `accessibility.*` namespace every other VoiceOver label uses, rather than the `search.scan_button.accessibility_label` first drafted here |
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

**When**: A scan does not open a Product — a code that is not ours, or a camera that cannot run
**Parameters**:
- `reason`: String - "barcode" | "unrecognised" | "permission_denied" | "unsupported" | "generic"

`generic` covers a camera that exists and is permitted but will not start; `barcode` arrives with the
manufacturer-Barcode ticket. See `ScanFailureReason`.

---

## Edge Cases

| Scenario | Expected Behavior |
|----------|-------------------|
| Alfie code carries a Handle the catalogue does not have | Existing Product Details error state handles it |
| Alfie code carries a `sku` parameter | Parsed and ignored; the default Variant is selected |
| Handle contains `/` (BigCommerce route path) | Parsed correctly — requires the parser fix below |
| Camera recognises two codes at once | The Alfie code wins, then a Barcode, then anything else; scanner stops recognising once one opens. Amended by #139: a Swing tag prints the Barcode beside the Alfie code, so "first wins" would correct a shopper who scanned correctly. The scanner reads a frame at a time and ranks what it holds — see `ScannedCode.precedence` |
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
- No new `Route` case. `DeepLink.LinkType` keeps its cases, but `productDetail`'s associated value was
  renamed `slug:` → `handle:` while building this: the scanner made the glossary term load-bearing, and
  the parser it feeds had to be fixed for multi-segment Handles anyway (#134). No behaviour changed.
- `TabRoute.init(deepLinkType:)` was extracted from `AppFeatureViewModel.navigate(for:)`, which is
  more than the rename above. The scan path's correctness rests entirely on that mapping, and inside
  a `navigate` method that also mutates the tab it could not be asserted; `DeepLinkRoutingTests` now
  covers the table directly. The mapping itself is unchanged, case for case.
- `ThemedSearchBarView.IconLayout` is a new `SharedUI` API. Putting a second control inside the bar
  is not a thing the bar could previously do, and the design's "Scan Barcode" variant moves the
  magnifier to the leading edge so the two bracket the text — one layout decision rather than a
  caller-supplied view, so the bar keeps control of its own chrome.

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
- **A Barcode acquired alone can flash its notice before the Alfie code is picked up.** The scanner
  ranks everything the camera is *holding* (`allItems`), so once both codes on a tag are tracked the
  Alfie code wins, and a code already answered is not answered twice as the set grows around it. But
  a 1D Barcode locks on faster than a QR, and in the moment when it is the only thing tracked there
  is nothing to tell the scanner an Alfie code is a frame away: the notice shows and one
  `scan_failed reason=barcode` is recorded, then the Product opens.

  Note this sits outside Scenario 4, which is conditioned on recognising a Barcode *instead of* an
  Alfie code — here the shopper scanned correctly and is briefly told they did not.

  Closing it would mean holding the Barcode notice behind a short grace period and cancelling it if
  an Alfie code joins. That is deliberately not done: it delays the honest Scenario 4 message, the
  one case the ticket exists for, and puts a timer inside a ViewModel that is otherwise synchronous
  and therefore deterministic under test. Revisit if the demo shows the flash actually reads badly.
- **A code arriving beside an already-answered Barcode gets no notice of its own.** The scanner
  answers one code per frame and suppresses a code it has already answered. When a Barcode is still
  in view and an unrecognised QR joins it, the Barcode wins on precedence and is then suppressed as
  a repeat, so the frame is answered with silence: the shopper sees the earlier Barcode notice,
  which is still on screen and still true, but nothing is said about the new code. Covered by
  `test_aBarcodeStillInViewAsAnotherCodeJoinsIsAnsweredOnce`.

  This is the cost of the rule that stops one physical code producing two notices and two
  `scan_failed` events, and it is paid in the case that matters least — the shopper is holding a
  Swing tag whose Barcode has already been named, and the advice on screen ("scan the Alfie code on
  the tag instead") is the advice the new code would also have earned. Answering per code rather
  than per frame would fix it and reopen the double-notice it was written to close.
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
  - Widening the capture changes two things beyond accepting a slash, both deliberate. A trailing
    `/` is now trimmed, so `/product/<handle>/` names the same Product as `/product/<handle>` rather
    than a Handle ending in a separator no catalogue contains. And anything under `/product/` now
    reads as a multi-segment Handle, so a path like `/product/<handle>/reviews` is looked up as a
    Product instead of falling through to the web view. Nothing in Alfie emits such a path, and the
    parser cannot tell a route suffix from a Handle segment without a catalogue to ask — this is the
    same trade BigCommerce route paths force. Worth revisiting if a `/product/` sub-route is ever
    added.
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
| 2026-09-10 | #139: `ScannedCode` built with `precedence`; two-codes-at-once edge case amended; Barcode-notice snapshot added | Khoi Nguyen |
| 2026-09-12 | Spec squared with the shipped code after review: Navigation block corrected to the `openScannedLink` seam, parser scope and the `TabRoute`/`IconLayout` additions recorded, per-frame notice limitation documented, status set to Implemented | Khoi Nguyen |
