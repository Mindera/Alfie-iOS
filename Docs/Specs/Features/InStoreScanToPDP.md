# Feature: In-Store Scan to Product Details

**Status**: Implemented
**Created**: 2026-09-09
**Last Updated**: 2026-09-18
**Implementation PR**: #146 (`feature/gh-133-in-store-scan-to-pdp` → `main`)

---

## Overview

A shopper standing in a physical store picks up a garment, scans the **Alfie code** on its swing tag
with the Alfie app, and arrives on that Product's details page — where the existing size and colour
swatches already show what is and is not available.

This is a **feature demo for one client**, not a production rollout. It is deliberately scoped so
that no new commerce-platform credentials and no hosted domain are needed; the only BFF change is
one read-only query.

The central design decision is that Alfie **prints its own Alfie code**, a QR code that already
contains the Handle, and prefers it over anything else on the tag. See
`Docs/adr/0001-print-our-own-alfie-code.md`. The **Barcode** a Swing tag prints is also resolved,
through the BFF's `productByBarcode` query (Alfie-BFF PR #46), but only on SCAYLE: the Shopify
Storefront API has no `barcode:` filter, and reaching Shopify's Admin API would mean provisioning an
Admin-scoped token for a customer-facing service. See `Docs/adr/0002-resolve-barcodes-through-the-bff-on-scayle.md`,
which partly supersedes ADR-0001.

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
**THEN** the _Scanner screen_ is presented full screen, with a back button and a square viewfinder
AND the camera preview starts
AND scanning guidance is shown under the viewfinder

### Scenario 1a: Camera access has not been asked yet

**GIVEN** iOS has not yet asked the shopper for camera access
AND the device can scan
**WHEN** the shopper taps the _Scan button_
**THEN** a native _explainer sheet_ ("Scan a tag"), sized to its content, is shown over the presenting
screen before any system prompt
AND _Continue_ opens the _Scanner screen_, which triggers the system prompt
AND _Not now_, or swiping the sheet down, closes it without remembering the choice, so the next tap
shows it again

> Added from the Figma "Scan Barcode" user flow (node 3353:35620). Once iOS has asked, the sheet is
> never shown again: a refusal is handled by Scenario 6. A device that cannot scan skips it and goes
> straight to Scenario 7 — asking for a camera it cannot use would contradict that scenario.

### Scenario 2: Shopper scans an Alfie code

**GIVEN** the shopper is on the _Scanner screen_
**WHEN** the camera recognises an Alfie code containing a valid Handle
**THEN** a success haptic plays and the viewfinder turns green for 0.3 seconds
AND the _Scanner screen_ is dismissed, unless the shopper tapped _Back_ during those 0.3 seconds, in
which case nothing opens
AND the shopper is navigated to the _Product Details screen_ for that Handle
AND the Variant named by the code's `sku` is selected, or the default Variant when there is no `sku`
or it matches no Variant

### Scenario 3: Availability is visible on arrival

**GIVEN** the shopper has arrived on the _Product Details screen_ from a scan
**WHEN** the Product has a Variant with no stock
**THEN** that size is shown as unavailable in the _Sizing selector_
AND a colour with no available Variant is dimmed in the _Colour selector_
AND an availability note states that stock shown is online stock

### Scenario 4: Shopper scans the manufacturer's Barcode

**GIVEN** the shopper is on the _Scanner screen_
**WHEN** the camera recognises a Barcode — EAN-13 or Code 128 — and no Alfie code
**THEN** the camera preview stays live
AND the guidance is replaced by a small loader and "Finding product…", announced to VoiceOver
AND the Barcode is looked up through `productByBarcode`

> Amended by ADR-0002 (2026-09-17). This scenario first answered a Barcode with the unrecognised
> notice. Classification is by the symbology VisionKit reports, not the payload's shape: a QR code
> holding thirteen digits is unrecognised (Scenario 5) and is never looked up.
>
> Amended again (2026-09-18). Code 128 was added alongside EAN-13. A real Selfridges tag prints its
> GTIN-13 inside a Code 128 symbol, so an EAN-13-only scanner never fired on one. Both symbologies
> take the same path from here — the symbology decides only that this is a Barcode, never what the
> payload means.

### Scenario 4a: Barcode matches a Variant

**GIVEN** a Barcode lookup is in flight
**WHEN** the BFF returns a match with a `variantId`
**THEN** the success haptic and green viewfinder of Scenario 2 follow
AND the Product opens through the deep-link path as `alfie://alfie.target/product/<productId>?variantId=<variantId>`
AND that Variant is selected on arrival

### Scenario 4b: Barcode matches a Product only

**GIVEN** a Barcode lookup is in flight
**WHEN** the BFF returns a match without a `variantId` — the code is on several Variants, or none
**THEN** the Product opens as `alfie://alfie.target/product/<productId>` with its default Variant

### Scenario 4c: Barcode not found

**GIVEN** a Barcode lookup is in flight
**WHEN** the BFF returns no match, including an ambiguous one
**THEN** the notice "We couldn't find this product." is shown and dismisses itself after four seconds,
or earlier from its close button
AND the camera keeps running, and scanning the same Barcode again looks it up again

### Scenario 4d: Barcode lookup fails

**GIVEN** a Barcode lookup is in flight
**WHEN** the request fails — including on a non-SCAYLE platform, where the query errors
**THEN** the notice "Something went wrong. Try scanning again." is shown, dismissing as in 4c
AND the camera keeps running, and scanning the same Barcode again looks it up again

### Scenario 4e: Codes recognised during a lookup

**GIVEN** a Barcode lookup is in flight
**WHEN** the camera recognises any code, an Alfie code included
**THEN** it is ignored
AND if the lookup then finds nothing or fails while an Alfie code is held, that Alfie code opens
instead of the notice

### Scenario 4f: Shopper closes the scanner during a lookup

**GIVEN** a Barcode lookup is in flight
**WHEN** the shopper taps _Back_, or the camera stops
**THEN** the lookup is cancelled and nothing opens

### Scenario 5: Shopper scans an unrelated code

**GIVEN** the shopper is on the _Scanner screen_
**WHEN** the camera recognises a QR code that opens nothing in Alfie
**THEN** the scanner stays open and the self-dismissing notice "We don't recognize this barcode." is shown
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
// What the camera read, as VisionKit reported it. CameraScanService publishes [ScannedPayload].
public struct ScannedPayload: Equatable {
    public enum Symbology: Equatable { case qr, ean13, code128 }
    public let symbology: Symbology
    public let value: String
}

// What the scanner recognised — classified by symbology, never by payload shape (ADR-0002)
public enum ScannedCode: Equatable {
    /// A QR code carrying an Alfie link, e.g. https://localhost:4000/product/<handle>?sku=<sku>
    case alfieCode(URL)
    /// A product Barcode (EAN-13, or a GTIN-13 in a Code 128 symbol), resolved through productByBarcode
    case barcode(value: String)
    /// Anything else the camera recognised, including a QR code holding thirteen digits
    case unrecognised(payload: String)

    /// Which of several codes read in one frame is acted on — lower first. A Swing tag prints both
    /// codes side by side, so both are routinely read at once and the Alfie code has to win.
    public var precedence: Int { ... }
}

public extension Collection where Element == ScannedCode {
    /// The one code the scanner acts on out of everything the camera is holding. Ties keep the
    /// camera's own order. This is what `ScannerViewModel` calls.
    var codeToActOn: ScannedCode? { ... }
}
// Built by #139. #138 needed only Alfie-code-or-not, which one `guard` expressed; the manufacturer
// Barcode is what made the third case real.

// What productByBarcode resolved. variantId is nil unless exactly one Variant carries the code.
public struct BarcodeMatch: Equatable {
    public let productId: String
    public let variantId: String?
}

// ViewModel State Model
public struct ScannerViewStateModel: Equatable {
    let guidance: String
    let notice: ScannerNotice?
    let isRecognised: Bool
    /// A Barcode is being resolved; the camera keeps running but no code is acted on
    let isLookingUp: Bool
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

For an Alfie code, none: the Handle travels inside the code, and the Product is fetched by the
existing `ProductDetailsQuery(handle:)` through the existing deep-link path.

For a Barcode, one query added by Alfie-BFF PR #46 (`ProductByBarcodeQuery.graphql`), reached through
`ProductServiceProtocol.productByBarcode(_:) -> BarcodeMatch?`:

```graphql
productByBarcode(barcode: String!): BarcodeMatch   # { id, name, slug, variantId }
```

SCAYLE only. `null` when no Product carries the code or more than one does; `variantId` is `null`
unless exactly one Variant carries it. Other platforms fail the query. The returned `id` is a bare
SCAYLE id, which `productDetails(handle:)` accepts.

---

## Navigation

### Entry Points

- Any screen with the _Search bar_ → tap _Scan button_ → Scanner screen, or the explainer sheet first
  while camera access has not been asked
- Scanner screen → recognises an Alfie code → Product Details screen
- Scanner screen → Barcode lookup matches → Product Details screen

### Exit Points

- Tap _Back_ → returns to the presenting screen
- Explainer sheet → _Not now_ → returns to the presenting screen
- Successful scan → Product Details screen, in the Shop tab

### Routes and FlowViewModel Methods

The Scanner is **presented as the tab's overlay** and adds no `Route` case. The ViewModel owns no navigation of
its own: on recognising an Alfie code it hands the URL back over the `openScannedLink` closure it was
built with, and the wiring behind that closure passes it to the existing deep-link path. Classifying
the payload is the scanner's job — a code that opens nothing must leave the camera running — while
opening the page is not.

```swift
// ScannerPresentation.makeViewModel, shared by every tab that offers Scan
openScannedLink: { deepLinkService.openUrls([$0]) }
```

That construction lives in one place rather than in each tab's `FlowViewModel`: the decisions behind
it — where a recognised link goes, that Settings is the one recovery a refused camera has, and that closing clears the tab's
overlay — are the same wherever the Scan control appears. Only the
last is supplied by the tab, because only the tab knows what it is covering.

`DeepLinkService` parses it with the existing `ProductDetailsDeepLinkParser`, and
`AppFeatureViewModel.navigate(for:)` routes it to
`.shop(.productDetails(.productDetails(.deepLink(handle:sku:))))`, and the Product Details page
selects the Variant whose SKU matches. This means the scan reuses a
navigation path that is already covered by tests, and it accepts the existing behaviour that all
deep links land in the Shop tab.

Whether to explain camera access first is the scanner's own state, not the tab's:
`ScannerViewModel.isExplainingCameraAccess` starts from `CameraScanServiceProtocol.canAskForCameraAccess`
(device supported and authorisation `.notDetermined`), and `ScannerView` presents the explainer as a
`.sheet` with a content-height `presentationDetents` over a clear overlay. The tabs only ever present
one `.scanner` overlay. The 0.3-second confirmation and the four-second notice are both timed through
the container's injected `schedule`, so they are unit-tested without waiting.

The `sku` is read in `TabRoute`, so it preselects a Variant for **every** product deep link, not only
a scan — a shared `/product/<handle>?sku=<sku>` link lands on the same Variant. This is intended: the
link format is the same one the Alfie code prints.

A Barcode match takes the same path: the ViewModel builds `alfie://alfie.target/product/<productId>`,
adding `?variantId=<id>` (`DeepLink.variantIdQueryItem`) when the match names one, and hands it to
`openScannedLink`. `TabRoute` carries it into `ProductDetailsConfiguration.deepLink(handle:sku:variantId:)`,
and Product Details preselects by `sku`, then `variantId`, then the default Variant. Like `sku`,
`variantId` applies to every product deep link.

---

## Localization

| Key | English | Notes |
|-----|---------|-------|
| `scanner.title` | "Scan" | Screen title |
| `scanner.guidance.message` | "Point the camera at the Alfie code on the tag" | Shown under the preview |
| `scanner.unrecognised.message` | "We don't recognize this barcode." | Scenario 5 — the design's wording; replaces `scanner.barcode_detected.message` |
| `scanner.lookup.message` | "Finding product…" | Scenario 4 — replaces the guidance during a lookup |
| `scanner.not_found.message` | "We couldn't find this product." | Scenario 4c |
| `scanner.lookup_failed.message` | "Something went wrong. Try scanning again." | Scenario 4d |
| `scanner.intro.title` | "Scan a tag" | Scenario 1a |
| `scanner.intro.message` | "Allow camera access to scan the Alfie code on a tag and go straight to the product." | Scenario 1a |
| `scanner.intro.continue` | "Continue" | Scenario 1a |
| `scanner.intro.not_now` | "Not now" | Scenario 1a |
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

**When**: An Alfie code is recognised, or a Barcode lookup matches, and navigation begins
**Parameters**:
- `handle`: String - The Product Handle from the code; for a Barcode, the matched `productId`
- `has_variant`: Bool - Whether the scan named a specific Variant: a SKU on the code, or a `variantId` on a Barcode match

### Event: `scan_failed`

**When**: A scan does not open a Product — a code that is not ours, or a camera that cannot run
**Parameters**:
- `reason`: String - "barcode" | "unrecognised" | "permission_denied" | "unsupported" | "generic"

`generic` covers a camera that exists and is permitted but will not start; `barcode` is a Barcode
lookup that found nothing or failed (Scenarios 4c, 4d). The lookup adds no events. See `ScanFailureReason`.

---

## Edge Cases

| Scenario | Expected Behavior |
|----------|-------------------|
| Alfie code carries a Handle the catalogue does not have | Existing Product Details error state handles it |
| Alfie code carries a `sku` parameter | That Variant is selected on arrival |
| Alfie code's `sku` matches no Variant | The default Variant is selected, silently |
| Handle contains `/` (BigCommerce route path) | Parsed correctly — requires the parser fix below |
| Camera recognises two codes at once | The Alfie code wins, then a Barcode, then anything else; scanner stops recognising once one opens. Amended by #139: a Swing tag prints the Barcode beside the Alfie code, so "first wins" would correct a shopper who scanned correctly. The scanner reads a frame at a time and ranks what it holds — see `ScannedCode.precedence` |
| Shopper scans while offline | Product Details shows its existing no-connection error state |
| Shopper scans the same code twice quickly | Second scan is ignored while navigation is in flight |
| Barcode is on several Products | BFF returns `null`; treated as not found (Scenario 4c) |
| Barcode is on several Variants of one Product | Product opens on its default Variant (Scenario 4b) |
| Any code arrives during a Barcode lookup | Ignored, Alfie codes included (Scenario 4e) |
| Same Barcode rescanned after a notice | Looked up again |
| Barcode scanned on a non-SCAYLE BFF | Query fails; lookup-failed notice (Scenario 4d) |
| QR code holding thirteen digits | Unrecognised notice; not looked up |
| Shopper taps _Back_ during a lookup | Lookup cancelled; nothing opens |
| Shopper taps _Back_ while the viewfinder is green | The scanner closes and the Product does not open |
| App is backgrounded mid-scan | Scanning stops and resumes when the screen reappears |

---

## Dependencies

### Services Required

- `DeepLinkServiceProtocol` (Core/Services) - Parse the scanned URL and route to Product Details
- `AlfieAnalyticsTracker` (Core/Services) - Track scan events
- `HapticsServiceProtocol` (Core/Services) - Success haptic on recognition
- `ProductServiceProtocol` (Core/Services) - Resolve a Barcode through `productByBarcode`

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

The seams are `CameraScanServiceProtocol`, which hands the ViewModel `[ScannedPayload]`, and
`ProductServiceProtocol` for the Barcode lookup, so the ViewModel is tested without a camera or BFF. Everything downstream of the payload is existing, already-tested code.

### Unit Tests (`ScannerTests`)

- [ ] An Alfie code payload results in the URL being passed to `DeepLinkService`
- [ ] A Barcode payload — EAN-13 or Code 128 — starts a lookup and shows the loader; a match opens the Product with and
  without `variantId`; not found and failure show their notices; codes during a lookup are ignored;
  closing cancels it; a QR holding digits is not looked up (`ScannerViewModelTests`)
- [ ] Product Details preselects by `variantId` (`ProductDetailsViewModelTests`); `TabRoute` carries
  `variantId` (`DeepLinkRoutingTests`)
- [ ] `ProductService.productByBarcode` maps the BFF match (`ProductServiceTests`); an unknown code
  returns `nil` against a real BFF (`BarcodeIntegrationTests`)
- [ ] An Alfie code sets the recognised state and triggers a success haptic before navigating
- [ ] Back during the confirmation opens nothing
- [ ] A notice dismisses itself after four seconds; a repeated notice gets its own four seconds
- [ ] The explainer shows only while the service can ask for camera access; Continue starts the
  camera, Not now closes
- [ ] `CameraScanService.canAskForCameraAccess` is false on an unsupported device (`CoreTests`)
- [ ] `TabRoute` carries the `sku` into Product Details, and Product Details selects the matching
  Variant, falling back to the default
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
- [ ] Unrecognised notice
- [ ] Recognised (green viewfinder)
- [ ] Explainer sheet
- [ ] Looking up a Barcode (`test_scanner_view_looking_up`)

The camera preview itself is not tested — it is a system component, and the simulator has no camera.
The developer will verify the camera path manually on device.

---

## Accessibility

- The _Scan button_ has the label "Scan a tag"
- The Scanner screen announces its guidance text when presented
- Notices are announced, not only shown — they dismiss themselves after four seconds, so the
  announcement is what a VoiceOver user relies on; the close button stays for anyone who wants it
  gone sooner
- All new controls carry `AccessibilityID` entries from the `AccessibilityIdentifiers` module

---

## Known Limitations

- **Availability is online stock, not store stock.** The BFF exposes `Inventory { available: Int }`
  with no location dimension, and neither adapter queries location-scoped inventory. The app cannot
  tell a shopper whether a size is in the store they are standing in. Scenario 3 states this
  explicitly on screen so nobody in the demo infers a capability that does not exist.
- **Manufacturer Barcodes resolve on SCAYLE only.** Other platforms fail the query and the shopper
  sees the lookup-failed notice (ADR-0002). A Barcode on several Products is not resolvable at all.
- **A Barcode acquired first wins over the Alfie code beside it.** The scanner ranks everything the
  camera is *holding* (`allItems`), so once both codes on a tag are tracked the Alfie code wins. But
  a 1D Barcode locks on faster than a QR, and in the moment when it is the only thing tracked there
  is nothing to tell the scanner an Alfie code is a frame away: the Barcode lookup starts, and the
  Alfie code joining the frame is ignored because every code is ignored during a lookup. On a match
  the same Product opens anyway, only a lookup later. On not found or failure, an Alfie code the
  camera held during the lookup opens then, with no notice and no `scan_failed`.

  Closing it would mean letting an Alfie code cancel an in-flight lookup. That is deliberately not
  done: ignoring codes while looking up is what keeps one tag from producing two navigations, and
  the common outcome — a match — lands on the right Product regardless.
- **A code arriving beside an already-answered Barcode gets no notice of its own.** The scanner
  answers one code per frame and suppresses a code it has already answered. When a Barcode is still
  in view and an unrecognised QR joins it, the Barcode wins on precedence and is then suppressed as
  a repeat, so the frame is answered with silence and no second lookup runs: the shopper sees the
  earlier not-found or lookup-failed notice, which may still be on screen, but nothing is said about
  the new code. Covered by `test_barcode_still_in_view_as_another_code_joins_is_looked_up_once`.

  This is the cost of the rule that stops one physical code producing two notices and two
  `scan_failed` events, and it is paid in the case that matters least — the shopper is holding a
  Swing tag whose Barcode has already been answered, and the guidance on screen ("Point the camera at
  the Alfie code on the tag") is the advice the new code would also have earned. Answering per code rather
  than per frame would fix it and reopen the double-notice it was written to close.
- **A real Selfridges tag scans but does not resolve on staging.** The tag photographed in store
  carries two different numbers: its bars encode `2600030000445`, a valid EAN-13 whose `260` prefix
  is GS1 restricted circulation (a retailer's own in-store range), while the text printed beneath
  them reads `96848723`, which fails the EAN-8 check digit and is not a GTIN at all. Staging's
  fixture keys Variant 1836 on the printed text, so the scanner reads the tag correctly and the
  lookup then returns nothing. The app is not at fault and no app change fixes it — the `ean`
  attribute on the SCAYLE Variant has to carry the value the bars encode. Scanning that tag today
  shows the not-found notice of Scenario 4c.
- **Production tags may key on the reference key, not the `ean`.** SCAYLE's Omnichannel guidance
  tells retailers to encode a Variant's **reference key** in in-store barcodes, and `productByBarcode`
  filters on the `ean` attribute only. A production scan could therefore miss for a reason that
  looks identical to absent data. `/v2/search/resolve` matches either and is reachable on the token
  the BFF already holds; see `Docs/Research/scayle-barcode-handling.md`.
- **The printed URL does not resolve in a browser.** It points at `localhost:4000`, which is the
  configured host. Scanning an Alfie code with the iOS Camera app will not open Alfie.
- **The shopper must already have Alfie installed.** No App Clip, no universal links.

---

## Implementation Notes

- Alfie code payload format: `https://localhost:4000/product/<handle>?sku=<sku>`. The `sku`
  selects the Variant the shopper arrives on.
- Configure the scanner for QR, EAN-13 **and** Code 128 — three symbologies, matching
  `CameraScanService`'s `recognizedDataTypes`. Each payload keeps the symbology VisionKit
  reported, and every Barcode read is looked up. Selfridges price tags print their GTIN-13 in a Code
  128 symbol rather than an EAN-13 one, so EAN-13 alone never sees a real swing tag.
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
    credentials. See ADR-0001. _Partly superseded 2026-09-17 below: Alfie codes are still printed
    and preferred, but Barcodes now resolve on SCAYLE._
- [x] Resolve the manufacturer's Barcode after all? (2026-09-17)
  - **Decision**: Yes, on SCAYLE, through the BFF's `productByBarcode` (Alfie-BFF PR #46). See
    ADR-0002. Classify by reported symbology rather than the check-digit heuristic; show a loader
    and ignore all codes while looking up; open a match through the existing deep-link path with an
    optional `variantId`; answer not-found and failure with self-dismissing notices. No new analytics
    events.
- [x] What does the Alfie code contain?
  - **Decision**: An `https` URL. It is parsed in-app, so no associated-domains entitlement is
    needed, and the format survives into a later phase that adds a real host.
- [x] Which host?
  - **Decision**: `localhost:4000`, matching the configured `LinkConfiguration` host. No config
    change needed.
- [x] Preselect the scanned Variant?
  - **Decision**: Yes (revised 2026-09-14, from the Figma flow's "Smart Selection"). First decided
    "carry the SKU, implement later"; the PDP already matched Variants by SKU, so passing it through
    `TabRoute` made it cheap enough for the demo. An unmatched SKU falls back to the default Variant.
- [x] Follow the Figma "Scan Barcode" flow (node 3353:35620) literally?
  - **Decision**: No — its "barcode" means any scannable code; ADR-0001 stands. Taken: explainer sheet
    before the first camera prompt, full-screen header with back button, square viewfinder, success
    haptic and green frame, the design's "We don't recognize this barcode." as a self-dismissing
    notice. Dropped: manual barcode entry and its "couldn't find that number" error (nothing to look a
    typed Barcode up against), the torch button, the sheets' "Remove All" link. The design's copy
    slips (garbled scanner guidance, "Scan Barcode"/"Scan barcode", "Shippings", mixed £/$) go back
    to the designer.
- [x] Which Barcode symbologies?
  - **Decision**: EAN-13 at first, to show a helpful message — the most likely demo mishap. _Since
    2026-09-17 it is looked up instead (ADR-0002). Since 2026-09-18 Code 128 is read too, because
    that is what a real Selfridges tag prints; EAN-13 alone never fired in store._

### Open Questions

- [ ] Which five to eight Products are printed for the demo? Needs the live catalogue checked.

---

## Changelog

| Date | Change | Author |
|------|--------|--------|
| 2026-09-09 | Initial spec created from `/grill-with-docs` session | Khoi Nguyen |
| 2026-09-10 | #139: `ScannedCode` built with `precedence`; two-codes-at-once edge case amended; Barcode-notice snapshot added | Khoi Nguyen |
| 2026-09-12 | Spec squared with the shipped code after review: Navigation block corrected to the `openScannedLink` seam, parser scope and the `TabRoute`/`IconLayout` additions recorded, per-frame notice limitation documented, status set to Implemented | Khoi Nguyen |
| 2026-09-14 | Figma flow review (`/grill-with-docs`): explainer sheet (Scenario 1a), full-screen scanner with square viewfinder and success feedback, single self-dismissing notice in the design's wording, Variant preselection by SKU; manual entry and torch dropped | Khoi Nguyen |
| 2026-09-14 | Review fixes: explainer is a native sheet owned by `ScannerViewModel` and skipped on unsupported devices; Back cancels the pending open; notice timer and close button in the ViewModel/view; header stays black in failure states; `sku` preselection documented as applying to all product links | Khoi Nguyen |
| 2026-09-17 | ADR-0002: Barcodes resolved through the BFF's `productByBarcode` on SCAYLE (Alfie-BFF PR #46); symbology-based classification; Scenario 4 replaced by lookup scenarios 4–4f; `variantId` deep-link preselection; lookup keys, edge cases, limitation and tests updated | Khoi Nguyen |
| 2026-09-18 | Code 128 added beside EAN-13, because Selfridges tags print their GTIN-13 in a Code 128 symbol; Scenario 4, Q2 and the test checklist widened from EAN-13 to "a Barcode"; the real-tag and reference-key limitations recorded | Khoi Nguyen |
