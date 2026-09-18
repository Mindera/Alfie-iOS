import Core
import Mocks
import Model
import SharedUI
import TestUtils
import XCTest
@testable import Scanner

/// The scanner's behaviour, driven through the ``CameraScanServiceProtocol`` seam rather than a camera.
///
/// The deep-link service is a mock answering with the link type the app's parser chain gives each
/// payload. That the printed Alfie code really resolves to those types is the parser chain's claim,
/// asserted in `ProductDeepLinkChainTests`; this file asserts what the scanner does with the answer.
final class ScannerViewModelTests: XCTestCase {
    private var scanService: MockCameraScanService!
    private var deepLinkService: MockDeepLinkService!
    private var productService: MockProductService!
    private var lookedUpBarcodes: [String]!
    private var lookupGate: LookupGate!
    private var linkTypes: [URL: DeepLink.LinkType]!
    private var openedLinks: [URL]!
    private var closeCount: Int!
    private var openSettingsCount: Int!
    private var mockAnalytics: MockAnalyticsTracker!
    private var mockHaptics: MockHapticsService!
    private var triggeredHaptics: [HapticType]!
    private var scheduler: TestScheduler!
    private var sut: ScannerViewModel!

    /// The format the generator prints — see `Tools/AlfieCodeGen` and ADR-0001.
    private static let alfieCode = ScannedPayload.qr("https://localhost:4000/product/slim-indigo-jean")
    private static let alfieCodeWithSku = ScannedPayload.qr("https://localhost:4000/product/slim-indigo-jean?sku=SKU-42")
    private static let multiSegmentAlfieCode = ScannedPayload.qr("https://localhost:4000/product/mens/jeans/slim-indigo")
    private static let wishlistAlfieCode = ScannedPayload.qr("https://localhost:4000/wishlist")
    private static let foreignLink = ScannedPayload.qr("https://example.com/not-an-alfie-code")
    private static let barcode = ScannedPayload.ean13("5901234123457")
    private static let otherBarcode = ScannedPayload.ean13("4006381333931")
    private static let barcodeProductLink = "alfie://alfie.target/product/8"
    private static let barcodeVariantLink = "alfie://alfie.target/product/8?variantId=22"
    private static let unrecognisedMessage = "We don't recognize this barcode."
    private static let notFoundMessage = "We couldn't find this product."
    private static let lookupFailedMessage = "Something went wrong. Try scanning again."

    override func setUpWithError() throws {
        try super.setUpWithError()

        openedLinks = []
        closeCount = 0
        openSettingsCount = 0
        mockAnalytics = MockAnalyticsTracker()
        triggeredHaptics = []
        scheduler = TestScheduler()
        mockHaptics = MockHapticsService()
        mockHaptics.onTriggerCalled = { [weak self] in self?.triggeredHaptics.append($0) }
        scanService = MockCameraScanService()
        linkTypes = try [
            url(Self.alfieCode): .productDetail(handle: "slim-indigo-jean", route: nil, query: nil),
            url(Self.alfieCodeWithSku): .productDetail(handle: "slim-indigo-jean", route: nil, query: ["sku": "SKU-42"]),
            url(Self.multiSegmentAlfieCode): .productDetail(handle: "mens/jeans/slim-indigo", route: nil, query: nil),
            url(Self.wishlistAlfieCode): .wishlist,
            url(Self.barcodeProductLink): .productDetail(handle: "8", route: nil, query: nil),
            url(Self.barcodeVariantLink): .productDetail(handle: "8", route: nil, query: ["variantId": "22"]),
        ]
        lookedUpBarcodes = []
        lookupGate = LookupGate()
        productService = MockProductService()
        productService.onProductByBarcodeCalled = { [weak self] in
            self?.lookedUpBarcodes?.append($0)
            return nil
        }
        deepLinkService = MockDeepLinkService()
        deepLinkService.onDeepLinkTypeCalled = { [weak self] in self?.linkTypes[$0] }
        sut = makeSUT()
    }

    override func tearDownWithError() throws {
        sut = nil
        mockHaptics = nil
        triggeredHaptics = nil
        scheduler = nil
        deepLinkService = nil
        productService = nil
        lookedUpBarcodes = nil
        Task { [lookupGate] in await lookupGate?.open() }
        lookupGate = nil
        linkTypes = nil
        scanService = nil
        openedLinks = nil
        closeCount = nil
        openSettingsCount = nil
        mockAnalytics = nil
        try super.tearDownWithError()
    }

    // MARK: - Scanning an Alfie code

    func test_scanning_alfie_code_opens_its_link_and_closes_scanner() throws {
        sut.viewDidAppear()

        scanService.recognise(Self.alfieCode)
        finishRecognitionFeedback()

        XCTAssertEqual(openedLinks, [try url(Self.alfieCode)])
        XCTAssertEqual(closeCount, 1)
    }

    /// The scanner is dismissed before the product opens, not left behind it: the deep-link path
    /// pushes onto a tab that the scanner is covering.
    func test_scanning_alfie_code_closes_scanner_before_opening_link() {
        var eventsInOrder: [String] = []
        sut = nil
        sut = makeSUT(
            openScannedLink: { _ in eventsInOrder.append("open") },
            close: { eventsInOrder.append("close") }
        )
        sut.viewDidAppear()

        scanService.recognise(Self.alfieCode)
        finishRecognitionFeedback()

        XCTAssertEqual(eventsInOrder, ["close", "open"])
    }

    func test_recognising_alfie_code_confirms_it_before_opening_anything() throws {
        sut.viewDidAppear()

        let state = XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.scanService.recognise(Self.alfieCode) })

        XCTAssertEqual(state?.value?.isRecognised, true)
        XCTAssertEqual(closeCount, 0)
        XCTAssertTrue(openedLinks.isEmpty)
        guard case .notification(.success) = try XCTUnwrap(triggeredHaptics.first) else {
            return XCTFail("Expected a success haptic, got \(triggeredHaptics ?? [])")
        }
    }

    func test_feedback_finishing_after_closing_opens_nothing() {
        sut.viewDidAppear()
        scanService.recognise(Self.alfieCode)
        sut.didTapClose()

        finishRecognitionFeedback()

        XCTAssertEqual(closeCount, 1)
        XCTAssertTrue(openedLinks.isEmpty)
    }

    func test_recognising_barcode_is_not_confirmed() {
        sut.viewDidAppear()

        let state = XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.scanService.recognise(Self.barcode) })

        XCTAssertEqual(state?.value?.isRecognised, false)
        XCTAssertTrue(triggeredHaptics.isEmpty)
    }

    func test_recognising_foreign_link_is_not_confirmed() {
        sut.viewDidAppear()

        let state = XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.scanService.recognise(Self.foreignLink) })

        XCTAssertEqual(state?.value?.isRecognised, false)
        XCTAssertTrue(triggeredHaptics.isEmpty)
    }

    /// The Handle is a route path on BigCommerce, so it routinely carries separators. The scanner
    /// hands the whole link on; the parser chain's half is in `ProductDeepLinkChainTests`.
    func test_scanning_multi_segment_alfie_code_opens_the_whole_link() throws {
        sut.viewDidAppear()

        scanService.recognise(Self.multiSegmentAlfieCode)
        finishRecognitionFeedback()

        XCTAssertEqual(openedLinks, [try url(Self.multiSegmentAlfieCode)])
    }

    func test_scanning_alfie_code_with_sku_opens_link_carrying_the_sku() throws {
        sut.viewDidAppear()

        scanService.recognise(Self.alfieCodeWithSku)
        finishRecognitionFeedback()

        XCTAssertEqual(openedLinks, [try url(Self.alfieCodeWithSku)])
    }

    // MARK: - Scanning the same code twice

    func test_same_alfie_code_seen_twice_opens_one_link() {
        sut.viewDidAppear()
        scanService.recognise(Self.alfieCode)

        scanService.recognise(Self.alfieCode)
        finishRecognitionFeedback()

        XCTAssertEqual(openedLinks.count, 1)
        XCTAssertEqual(closeCount, 1)
    }

    func test_recognising_alfie_code_stops_scanning() {
        sut.viewDidAppear()

        scanService.recognise(Self.alfieCode)

        XCTAssertFalse(scanService.isScanning)
    }

    /// A scan that has already navigated must not be undone by the screen going away and coming
    /// back — which is exactly what happens as the Product Details page is pushed.
    func test_reappearing_after_alfie_code_opened_does_not_resume_scanning() {
        sut.viewDidAppear()
        scanService.recognise(Self.alfieCode)
        sut.viewDidDisappear()

        sut.viewDidAppear()

        XCTAssertFalse(scanService.isScanning)
    }

    // MARK: - Codes that are not Alfie codes

    func test_scanning_code_that_reaches_nothing_opens_nothing_and_keeps_scanning() {
        let payloads = [
            Self.foreignLink,
            ScannedPayload.qr("5901234123457"),
            ScannedPayload.qr(""),
        ]
        sut.viewDidAppear()

        for payload in payloads {
            scanService.recognise(payload)

            XCTAssertTrue(openedLinks.isEmpty, "payload: \"\(payload.value)\"")
            XCTAssertEqual(closeCount, 0, "payload: \"\(payload.value)\"")
            XCTAssertTrue(scanService.isScanning, "payload: \"\(payload.value)\"")
        }
        XCTAssertTrue(lookedUpBarcodes.isEmpty)
    }

    /// Silence would read as a broken scanner: the shopper is holding the camera over something and
    /// nothing is happening. Saying the code is not ours is what tells them to look for a different
    /// one — and it is said over the running camera, not instead of it.
    func test_scanning_foreign_link_shows_unrecognised_notice() {
        sut.viewDidAppear()

        let state = XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.scanService.recognise(Self.foreignLink) })

        XCTAssertEqual(state?.value?.notice, ScannerNotice(id: 1, message: Self.unrecognisedMessage))
    }

    /// The scanner has to still be *open* for the next code to reach it. Asserting only that the
    /// good code opened would pass on a scanner that had closed and been reopened, which is not what
    /// the shopper standing at the rail experiences — hence the single camera start and single close.
    func test_scanning_alfie_code_after_unrecognised_one_opens_it_from_the_same_session() throws {
        sut.viewDidAppear()
        scanService.recognise(Self.foreignLink)

        scanService.recognise(Self.alfieCode)
        finishRecognitionFeedback()

        XCTAssertEqual(openedLinks, [try url(Self.alfieCode)])
        XCTAssertEqual(scanService.startCount, 1)
        XCTAssertEqual(closeCount, 1)
    }

    func test_recognising_alfie_code_clears_earlier_notice() {
        sut.viewDidAppear()
        scanService.recognise(Self.foreignLink)

        let state = XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.scanService.recognise(Self.alfieCode) })

        XCTAssertNil(state?.value?.notice)
        XCTAssertEqual(state?.value?.isRecognised, true)
    }

    /// An Alfie code carries an Alfie link, and the flow's deep-link path decides where it lands.
    /// Judging the code on "is it a Product?" would tell a shopper holding a real Alfie code that it
    /// is not from Alfie — false, and it would strand a link the app can open perfectly well.
    func test_scanning_alfie_code_for_another_screen_still_opens_it() throws {
        sut.viewDidAppear()

        let state = XCTAssertEmitsValue(from: sut.$state, afterTrigger: {
            self.scanService.recognise(Self.wishlistAlfieCode)
            self.finishRecognitionFeedback()
        })

        XCTAssertEqual(openedLinks, [try url(Self.wishlistAlfieCode)])
        XCTAssertEqual(closeCount, 1)
        XCTAssertNil(state?.value?.notice)
    }

    /// The one Alfie URL that must *not* be opened: nothing in the app answers to it, so the
    /// deep-link path would fall back to a web view — the blank screen this ticket exists to
    /// prevent. It gets the same notice as a stranger's code, because it reaches the shopper the
    /// same way: nothing happened.
    func test_scanning_link_that_resolves_to_web_view_opens_nothing_and_shows_notice() throws {
        let helpLink = try url("https://localhost:4000/help/returns")
        linkTypes[helpLink] = .webView(url: helpLink)
        sut.viewDidAppear()

        let state = XCTAssertEmitsValue(from: sut.$state, afterTrigger: {
            self.scanService.recognise(.qr("https://localhost:4000/help/returns"))
        })

        XCTAssertTrue(openedLinks.isEmpty)
        XCTAssertEqual(closeCount, 0)
        XCTAssertEqual(state?.value?.notice?.message, Self.unrecognisedMessage)
    }

    /// A second bad code in a row says exactly what the first one said. It still has to count as a
    /// new notice: the screen announces on change, so words alone would leave VoiceOver silent at
    /// the moment the shopper has just failed again. See ``ScannerNotice``. The first notice is
    /// `id: 1`, as `test_scanning_foreign_link_shows_unrecognised_notice` asserts.
    func test_same_unrecognised_code_twice_shows_a_distinct_second_notice() {
        sut.viewDidAppear()
        scanService.recognise(Self.foreignLink)

        let state = XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.scanService.recognise(Self.foreignLink) })

        XCTAssertEqual(state?.value?.notice?.message, Self.unrecognisedMessage)
        XCTAssertNotEqual(state?.value?.notice, ScannerNotice(id: 1, message: Self.unrecognisedMessage))
    }

    func test_dismissing_notice_leaves_guidance_in_place() {
        sut.viewDidAppear()
        scanService.recognise(Self.foreignLink)

        let state = XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.didDismissNotice() })

        XCTAssertNil(state?.value?.notice)
        XCTAssertEqual(state?.value?.guidance, "Point the camera at the Alfie code on the tag")
    }

    func test_notice_before_its_duration_stays_on_screen() {
        sut.viewDidAppear()
        scanService.recognise(Self.foreignLink)

        XCTAssertNoEmit(from: sut.$state, afterTrigger: { self.scheduler.advance(by: 3.9) })
    }

    func test_notice_at_its_duration_dismisses_itself_and_keeps_scanning() {
        sut.viewDidAppear()
        scanService.recognise(Self.foreignLink)

        let state = XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.scheduler.advance(by: 4) })

        XCTAssertNil(state?.value?.notice)
        XCTAssertTrue(scanService.isScanning)
    }

    func test_repeated_notice_outlives_the_first_notice_duration() {
        sut.viewDidAppear()
        scanService.recognise(Self.foreignLink)
        scheduler.advance(by: 2)
        scanService.recognise(Self.foreignLink)

        XCTAssertNoEmit(from: sut.$state, afterTrigger: { self.scheduler.advance(by: 2) })
    }

    func test_repeated_notice_dismisses_itself_at_its_own_duration() {
        sut.viewDidAppear()
        scanService.recognise(Self.foreignLink)
        scheduler.advance(by: 2)
        scanService.recognise(Self.foreignLink)

        let state = XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.scheduler.advance(by: 4) })

        XCTAssertNil(state?.value?.notice)
    }

    // MARK: - Explaining camera access

    func test_building_scanner_when_ios_can_still_ask_explains_camera_access() {
        sut = nil

        sut = makeSUT(canAskForCameraAccess: true)

        XCTAssertTrue(sut.isExplainingCameraAccess)
    }

    func test_building_scanner_when_ios_has_asked_neither_explains_nor_starts_camera() {
        sut = nil

        sut = makeSUT(canAskForCameraAccess: false)

        XCTAssertFalse(sut.isExplainingCameraAccess)
        XCTAssertFalse(scanService.isScanning)
    }

    func test_appearing_while_explaining_camera_access_does_not_start_camera() {
        sut = nil
        sut = makeSUT(canAskForCameraAccess: true)

        sut.viewDidAppear()

        XCTAssertTrue(sut.isExplainingCameraAccess)
        XCTAssertFalse(scanService.isScanning)
    }

    func test_appearing_after_continuing_from_explanation_starts_camera() {
        sut = nil
        sut = makeSUT(canAskForCameraAccess: true)
        sut.didTapContinueToCamera()

        sut.viewDidAppear()

        XCTAssertFalse(sut.isExplainingCameraAccess)
        XCTAssertTrue(scanService.isScanning)
        XCTAssertEqual(closeCount, 0)
    }

    func test_declining_explanation_closes_scanner_without_starting_camera() {
        sut = nil
        sut = makeSUT(canAskForCameraAccess: true)

        sut.didDeclineCameraAccess()

        XCTAssertEqual(closeCount, 1)
        XCTAssertEqual(scanService.startCount, 0)
    }

    func test_explanation_going_away_after_continuing_does_not_close() {
        sut = nil
        sut = makeSUT(canAskForCameraAccess: true)
        sut.didTapContinueToCamera()

        sut.didDeclineCameraAccess()

        XCTAssertEqual(closeCount, 0)
    }

    // MARK: - Scanning the manufacturer's Barcode

    func test_scanning_barcode_looks_it_up_while_camera_keeps_running() {
        holdLookups()
        sut.viewDidAppear()

        let state = XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.scanService.recognise(Self.barcode) })

        XCTAssertEqual(state?.value?.isLookingUp, true)
        XCTAssertEqual(state?.value?.isRecognised, false)
        XCTAssertTrue(scanService.isScanning)
    }

    /// A Selfridges price tag carries its GTIN-13 in a Code 128 symbol. It is a product barcode like
    /// any other, so it reaches `productByBarcode` as-is — the symbology it was read as is not part
    /// of the code.
    func test_scanning_code128_looks_up_its_value_as_a_barcode() throws {
        var lookedUp: [String] = []
        productService.onProductByBarcodeCalled = { barcode in
            lookedUp.append(barcode)
            return BarcodeMatch(productId: "8", variantId: "22")
        }
        sut.viewDidAppear()

        recogniseAndAwaitRecognition(.code128("2600030000445"))
        finishRecognitionFeedback()

        XCTAssertEqual(lookedUp, ["2600030000445"])
        XCTAssertEqual(openedLinks, [try url(Self.barcodeVariantLink)])
    }

    func test_scanning_barcode_matching_variant_opens_product_with_variant_id() throws {
        productService.onProductByBarcodeCalled = { _ in BarcodeMatch(productId: "8", variantId: "22") }
        sut.viewDidAppear()

        recogniseAndAwaitRecognition(Self.barcode)
        finishRecognitionFeedback()

        XCTAssertEqual(openedLinks, [try url(Self.barcodeVariantLink)])
        XCTAssertEqual(closeCount, 1)
    }

    func test_scanning_barcode_matching_product_only_opens_product_without_variant_id() throws {
        productService.onProductByBarcodeCalled = { _ in BarcodeMatch(productId: "8", variantId: nil) }
        sut.viewDidAppear()

        recogniseAndAwaitRecognition(Self.barcode)
        finishRecognitionFeedback()

        XCTAssertEqual(openedLinks, [try url(Self.barcodeProductLink)])
    }

    func test_scanning_barcode_matching_nothing_shows_not_found_notice_and_keeps_scanning() {
        sut.viewDidAppear()

        let state = recogniseAndAwaitLookup([Self.barcode])

        XCTAssertEqual(state?.value?.notice, ScannerNotice(id: 1, message: Self.notFoundMessage))
        XCTAssertEqual(state?.value?.isLookingUp, false)
        XCTAssertTrue(openedLinks.isEmpty)
        XCTAssertTrue(scanService.isScanning)
    }

    func test_scanning_barcode_when_lookup_fails_shows_lookup_failed_notice() {
        productService.onProductByBarcodeCalled = { _ in throw BFFRequestError(type: .product(.generic)) }
        sut.viewDidAppear()

        let state = recogniseAndAwaitLookup([Self.barcode])

        XCTAssertEqual(state?.value?.notice?.message, Self.lookupFailedMessage)
        XCTAssertEqual(state?.value?.isLookingUp, false)
        XCTAssertTrue(openedLinks.isEmpty)
    }

    func test_scanning_barcode_again_after_not_found_looks_it_up_again() {
        sut.viewDidAppear()
        recogniseAndAwaitLookup([Self.barcode])

        recogniseAndAwaitLookup([Self.barcode])

        XCTAssertEqual(lookedUpBarcodes, ["5901234123457", "5901234123457"])
    }

    func test_scanning_barcode_while_looking_up_does_not_look_it_up() {
        let started = expectation(description: "lookup started")
        holdLookups(started: started)
        sut.viewDidAppear()
        scanService.recognise(Self.barcode)
        wait(for: [started], timeout: .default)

        scanService.recognise(Self.otherBarcode)

        XCTAssertEqual(lookedUpBarcodes, ["5901234123457"])
    }

    func test_scanning_alfie_code_while_looking_up_does_not_open_it() {
        let started = expectation(description: "lookup started")
        holdLookups(started: started)
        sut.viewDidAppear()
        scanService.recognise(Self.barcode)
        wait(for: [started], timeout: .default)

        scanService.recognise([Self.barcode, Self.alfieCode])

        XCTAssertFalse(sut.isRecognised)
        XCTAssertTrue(sut.isLookingUp)
    }

    func test_alfie_code_held_when_lookup_finds_nothing_opens_it_without_failure() throws {
        let started = expectation(description: "lookup started")
        holdLookups(started: started)
        sut.viewDidAppear()
        scanService.recognise(Self.barcode)
        wait(for: [started], timeout: .default)
        scanService.recognise([Self.barcode, Self.alfieCode])

        XCTAssertEmitsValue(
            from: sut.$state,
            where: { $0.value?.isRecognised == true },
            afterTrigger: { self.releaseLookups() }
        )
        finishRecognitionFeedback()

        XCTAssertEqual(openedLinks, [try url(Self.alfieCode)])
        XCTAssertTrue(reportedScanFailures.isEmpty)
    }

    func test_closing_while_looking_up_cancels_lookup() {
        let started = expectation(description: "lookup started")
        let cancelled = expectation(description: "lookup cancelled")
        holdLookups(started: started, cancelled: cancelled, answer: BarcodeMatch(productId: "8", variantId: "22"))
        sut.viewDidAppear()
        scanService.recognise(Self.barcode)
        wait(for: [started], timeout: .default)

        sut.didTapClose()

        wait(for: [cancelled], timeout: .default)
        XCTAssertTrue(openedLinks.isEmpty)
        XCTAssertEqual(closeCount, 1)
    }

    func test_backgrounding_while_looking_up_cancels_lookup_and_clears_loader() {
        let started = expectation(description: "lookup started")
        let cancelled = expectation(description: "lookup cancelled")
        holdLookups(started: started, cancelled: cancelled, answer: BarcodeMatch(productId: "8", variantId: "22"))
        sut.viewDidAppear()
        scanService.recognise(Self.barcode)
        wait(for: [started], timeout: .default)

        sut.didChangeScenePhase(isActive: false)

        wait(for: [cancelled], timeout: .default)
        XCTAssertFalse(sut.isLookingUp)
        XCTAssertTrue(openedLinks.isEmpty)
    }

    func test_scanning_barcode_in_same_frame_as_alfie_code_does_not_look_it_up() {
        sut.viewDidAppear()

        scanService.recognise([Self.barcode, Self.alfieCode])

        XCTAssertTrue(lookedUpBarcodes.isEmpty)
    }

    func test_scanning_qr_code_holding_barcode_digits_does_not_look_it_up() {
        sut.viewDidAppear()

        let state = XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.scanService.recognise(.qr("5901234123457")) })

        XCTAssertEqual(state?.value?.notice?.message, Self.unrecognisedMessage)
        XCTAssertTrue(lookedUpBarcodes.isEmpty)
    }

    /// Both codes are printed on the same Swing tag, so a camera held over one sees both. Correcting
    /// a shopper who scanned correctly — a frame before the Product opens anyway — would read as the
    /// app arguing with itself.
    func test_scanning_alfie_code_in_same_frame_as_barcode_opens_it_without_notice() throws {
        sut.viewDidAppear()

        let state = XCTAssertEmitsValue(from: sut.$state, afterTrigger: {
            self.scanService.recognise([Self.barcode, Self.alfieCode])
            self.finishRecognitionFeedback()
        })

        XCTAssertEqual(openedLinks, [try url(Self.alfieCode)])
        XCTAssertNil(state?.value?.notice)
    }

    func test_alfie_code_joining_barcode_after_its_lookup_opens_it() throws {
        sut.viewDidAppear()
        recogniseAndAwaitLookup([Self.barcode])

        scanService.recognise([Self.barcode, Self.alfieCode])
        finishRecognitionFeedback()

        XCTAssertEqual(openedLinks, [try url(Self.alfieCode)])
        XCTAssertEqual(closeCount, 1)
    }

    /// The camera republishes everything it holds each time that set grows, so a Barcode still in
    /// view as another code joins it arrives twice. It is one physical code and gets one answer —
    /// otherwise the `scan_failed` breakdown this feature added counts a single mistake twice.
    func test_barcode_still_in_view_as_another_code_joins_is_looked_up_once() {
        sut.viewDidAppear()
        recogniseAndAwaitLookup([Self.barcode])

        scanService.recognise([Self.barcode, Self.foreignLink])

        XCTAssertEqual(lookedUpBarcodes, ["5901234123457"])
    }

    // MARK: - When recognition runs

    func test_appearing_starts_scanning() {
        sut.viewDidAppear()

        XCTAssertTrue(scanService.isScanning)
    }

    func test_disappearing_stops_scanning() {
        sut.viewDidAppear()

        sut.viewDidDisappear()

        XCTAssertFalse(scanService.isScanning)
    }

    func test_backgrounding_stops_scanning() {
        sut.viewDidAppear()

        sut.didChangeScenePhase(isActive: false)

        XCTAssertFalse(scanService.isScanning)
    }

    func test_returning_to_foreground_resumes_scanning() {
        sut.viewDidAppear()
        sut.didChangeScenePhase(isActive: false)

        sut.didChangeScenePhase(isActive: true)

        XCTAssertTrue(scanService.isScanning)
    }

    /// Coming back to the foreground while the scanner is *not* the visible screen must not switch
    /// the camera on behind it.
    func test_returning_to_foreground_after_disappearing_does_not_resume_scanning() {
        sut.viewDidAppear()
        sut.viewDidDisappear()

        sut.didChangeScenePhase(isActive: true)

        XCTAssertFalse(scanService.isScanning)
    }

    /// Repeated appearances do not stack camera sessions.
    func test_activating_already_running_scan_does_not_start_camera_again() {
        sut.viewDidAppear()
        sut.viewDidAppear()

        sut.didChangeScenePhase(isActive: true)

        XCTAssertEqual(scanService.startCount, 1)
    }

    // MARK: - When there is no camera to look through

    func test_camera_failing_with_permission_denied_shows_permission_denied_error() {
        sut.viewDidAppear()

        let state = XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.scanService.fail(with: .permissionDenied) })

        XCTAssertEqual(state?.failure, .cameraPermissionDenied)
    }

    func test_camera_failing_with_device_not_supported_shows_device_not_supported_error() {
        sut.viewDidAppear()

        let state = XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.scanService.fail(with: .deviceNotSupported) })

        XCTAssertEqual(state?.failure, .deviceNotSupported)
    }

    func test_camera_failing_as_unavailable_shows_generic_error() {
        sut.viewDidAppear()

        let state = XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.scanService.fail(with: .unavailable) })

        XCTAssertEqual(state?.failure, .generic)
    }

    /// The explanation replaces the screen, so anything that was being said over the camera goes
    /// with it — a notice about the last code read is meaningless once there is no camera.
    func test_camera_failing_replaces_notice_and_guidance() {
        sut.viewDidAppear()
        scanService.recognise(Self.foreignLink)

        let state = XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.scanService.fail(with: .permissionDenied) })

        XCTAssertNil(state?.value)
    }

    func test_tapping_open_settings_after_permission_denied_opens_settings() {
        sut.viewDidAppear()
        scanService.fail(with: .permissionDenied)

        sut.didTapOpenSettings()

        XCTAssertEqual(openSettingsCount, 1)
    }

    /// Settings is reached by leaving the app, so the fix always arrives as a return to the
    /// foreground. The camera is asked again on the way back rather than leaving the shopper looking
    /// at an explanation of a permission they have just granted.
    func test_returning_to_foreground_after_failure_restarts_camera_and_clears_error() {
        sut.viewDidAppear()
        scanService.fail(with: .permissionDenied)
        sut.didChangeScenePhase(isActive: false)

        let state = XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.didChangeScenePhase(isActive: true) })

        XCTAssertNil(state?.failure)
        XCTAssertTrue(scanService.isScanning)
    }

    /// A failure leaves nothing running, and the service says so by clearing its own start request.
    /// This screen has to agree with it: while it still believed a camera was running, the next
    /// start was declined as redundant and the shopper stayed on the explanation.
    ///
    /// Asserted without a backgrounding step on purpose — the scene-phase round trip hides the bug
    /// by stopping first, which is why the case above passed either way.
    func test_appearing_after_failure_restarts_camera_without_leaving_the_app() {
        sut.viewDidAppear()
        scanService.fail(with: .permissionDenied)

        let state = XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertEqual(scanService.startCount, 2)
        XCTAssertNil(state?.failure)
    }

    // MARK: - Reporting why a scan failed

    /// Every way a scan ends without a Product reports under one event, distinguished by reason —
    /// the reasons are read against each other, so each has to arrive under its own name.
    func test_scanning_foreign_link_reports_unrecognised_failure() {
        sut.viewDidAppear()

        scanService.recognise(Self.foreignLink)

        XCTAssertEqual(reportedScanFailures, ["unrecognised"])
    }

    /// An Alfie code that won the frame is not also a Barcode failure. Reporting the loser would
    /// count a scan that worked as one that did not.
    func test_scanning_barcode_in_same_frame_as_alfie_code_reports_no_failure() {
        sut.viewDidAppear()

        scanService.recognise([Self.barcode, Self.alfieCode])

        XCTAssertTrue(reportedScanFailures.isEmpty)
    }

    func test_scanning_barcode_matching_nothing_reports_barcode_failure() {
        sut.viewDidAppear()

        recogniseAndAwaitLookup([Self.barcode])

        XCTAssertEqual(reportedScanFailures, ["barcode"])
    }

    func test_scanning_barcode_when_lookup_fails_reports_barcode_failure() {
        productService.onProductByBarcodeCalled = { _ in throw BFFRequestError(type: .product(.generic)) }
        sut.viewDidAppear()

        recogniseAndAwaitLookup([Self.barcode])

        XCTAssertEqual(reportedScanFailures, ["barcode"])
    }

    func test_camera_failing_with_permission_denied_reports_permission_denied_failure() {
        sut.viewDidAppear()

        scanService.fail(with: .permissionDenied)

        XCTAssertEqual(reportedScanFailures, ["permission_denied"])
    }

    func test_camera_failing_with_device_not_supported_reports_unsupported_failure() {
        sut.viewDidAppear()

        scanService.fail(with: .deviceNotSupported)

        XCTAssertEqual(reportedScanFailures, ["unsupported"])
    }

    func test_camera_failing_as_unavailable_reports_generic_failure() {
        sut.viewDidAppear()

        scanService.fail(with: .unavailable)

        XCTAssertEqual(reportedScanFailures, ["generic"])
    }

    /// A scan that works is not a failure. Without this the event would count openings as well as
    /// failures and the breakdown would describe nothing.
    func test_scanning_alfie_code_reports_no_failure() {
        sut.viewDidAppear()

        scanService.recognise(Self.alfieCode)

        XCTAssertTrue(reportedScanFailures.isEmpty)
    }

    /// Nor is an Alfie code that opens something other than a Product. Counting it would inflate
    /// `unrecognised` with codes that worked.
    func test_scanning_alfie_code_for_another_screen_reports_no_failure() {
        sut.viewDidAppear()

        scanService.recognise(Self.wishlistAlfieCode)

        XCTAssertTrue(reportedScanFailures.isEmpty)
    }

    // MARK: - Reporting a scan that started, and one that worked

    /// `scan_started` is the denominator the other two scan events are read against, so it carries
    /// the door the shopper came in through.
    func test_appearing_reports_scan_started_with_its_source() {
        sut.viewDidAppear()

        XCTAssertEqual(reportedScanStarts, ["search_bar"])
    }

    /// Presentations, not appearances. The screen appears again every time the app returns to the
    /// foreground, and counting those would inflate the denominator against which the other two
    /// events are read.
    func test_appearing_again_in_same_presentation_does_not_report_scan_started_again() {
        sut.viewDidAppear()
        sut.didChangeScenePhase(isActive: false)
        sut.didChangeScenePhase(isActive: true)

        sut.viewDidAppear()

        XCTAssertEqual(reportedScanStarts, ["search_bar"])
    }

    func test_scanning_alfie_code_reports_success_with_its_handle() {
        sut.viewDidAppear()

        scanService.recognise(Self.alfieCode)

        XCTAssertEqual(reportedScanSuccessHandles, ["slim-indigo-jean"])
        XCTAssertEqual(reportedScanSuccessSkuFlags, [false])
    }

    func test_scanning_alfie_code_with_sku_reports_success_with_sku_flag() {
        sut.viewDidAppear()

        scanService.recognise(Self.alfieCodeWithSku)

        XCTAssertEqual(reportedScanSuccessHandles, ["slim-indigo-jean"])
        XCTAssertEqual(reportedScanSuccessSkuFlags, [true])
    }

    func test_scanning_barcode_matching_variant_reports_success_with_sku_flag() {
        productService.onProductByBarcodeCalled = { _ in BarcodeMatch(productId: "8", variantId: "22") }
        sut.viewDidAppear()

        recogniseAndAwaitRecognition(Self.barcode)

        XCTAssertEqual(reportedScanSuccessHandles, ["8"])
        XCTAssertEqual(reportedScanSuccessSkuFlags, [true])
    }

    func test_scanning_barcode_matching_product_only_reports_success_without_sku_flag() {
        productService.onProductByBarcodeCalled = { _ in BarcodeMatch(productId: "8", variantId: nil) }
        sut.viewDidAppear()

        recogniseAndAwaitRecognition(Self.barcode)

        XCTAssertEqual(reportedScanSuccessHandles, ["8"])
        XCTAssertEqual(reportedScanSuccessSkuFlags, [false])
    }

    /// A code that opens nothing is a failure, and must not also appear as a success — the two are
    /// read as a pair.
    func test_scanning_barcode_matching_nothing_reports_no_success() {
        sut.viewDidAppear()

        recogniseAndAwaitLookup([Self.barcode])

        XCTAssertTrue(reportedScanSuccessHandles.isEmpty)
    }

    // MARK: - Closing

    func test_tapping_close_dismisses_without_opening_anything() {
        sut.viewDidAppear()

        sut.didTapClose()

        XCTAssertEqual(closeCount, 1)
        XCTAssertTrue(openedLinks.isEmpty)
    }

    // MARK: - Helpers

    private func makeSUT(
        canAskForCameraAccess: Bool = false,
        openScannedLink: ((URL) -> Void)? = nil,
        close: (() -> Void)? = nil
    ) -> ScannerViewModel {
        scanService.canAskForCameraAccess = canAskForCameraAccess
        let scanService = self.scanService!
        return ScannerViewModel(
            dependencies: .init(
                deepLinkService: deepLinkService,
                productService: productService,
                makeScanService: { scanService },
                analytics: mockAnalytics.eraseToAnyAnalyticsTracker(),
                haptics: mockHaptics,
                schedule: { [scheduler] in scheduler?.schedule(after: $0, $1) },
                log: MockLogger()
            ),
            source: .searchBar,
            openScannedLink: openScannedLink ?? { [weak self] in self?.openedLinks.append($0) },
            openAppSettings: { [weak self] in self?.openSettingsCount += 1 },
            close: close ?? { [weak self] in self?.closeCount += 1 }
        )
    }

    private func url(_ string: String) throws -> URL {
        try XCTUnwrap(URL(string: string))
    }

    private func holdLookups(
        started: XCTestExpectation? = nil,
        cancelled: XCTestExpectation? = nil,
        answer: BarcodeMatch? = nil
    ) {
        let gate = lookupGate!
        productService.onProductByBarcodeCalled = { [weak self] barcode in
            self?.lookedUpBarcodes?.append(barcode)
            started?.fulfill()
            await withTaskCancellationHandler {
                await gate.wait()
            } onCancel: {
                cancelled?.fulfill()
            }
            return answer
        }
    }

    private func releaseLookups() {
        Task { [lookupGate] in await lookupGate?.open() }
    }

    private func url(_ payload: ScannedPayload) throws -> URL {
        try url(payload.value)
    }

    @discardableResult
    private func recogniseAndAwaitLookup(
        _ payloads: [ScannedPayload]
    ) -> ViewState<ScannerViewStateModel, ScannerViewErrorType>? {
        XCTAssertEmitsValue(
            from: sut.$state,
            where: { $0.value?.isLookingUp == false },
            afterTrigger: { self.scanService.recognise(payloads) }
        )
    }

    private func recogniseAndAwaitRecognition(_ payload: ScannedPayload) {
        XCTAssertEmitsValue(
            from: sut.$state,
            where: { $0.value?.isRecognised == true },
            afterTrigger: { self.scanService.recognise(payload) }
        )
    }

    private func finishRecognitionFeedback() {
        scheduler.advance(by: 0.3)
    }

    /// The `reason` carried by each `scan_failed` event, in order.
    private var reportedScanFailures: [String] {
        mockAnalytics.trackedValues(of: .reason, for: .scanFailed)
    }

    /// The `source` carried by each `scan_started` event, in order.
    private var reportedScanStarts: [String] {
        mockAnalytics.trackedValues(of: .source, for: .scanStarted)
    }

    /// The `handle` carried by each `scan_succeeded` event, in order.
    private var reportedScanSuccessHandles: [String] {
        mockAnalytics.trackedValues(of: .handle, for: .scanSucceeded)
    }

    /// The `has_sku` flag carried by each `scan_succeeded` event, in order. Read off the events
    /// directly rather than through `trackedValues(of:for:)`, which only reads String parameters.
    private var reportedScanSuccessSkuFlags: [Bool] {
        mockAnalytics.trackedEvents.compactMap { event in
            guard case .action(.scanSucceeded, let parameters) = event else { return nil }
            return parameters?[.hasSku] as? Bool
        }
    }
}

private final class TestScheduler {
    private var now: TimeInterval = 0
    private var pending: [(due: TimeInterval, work: () -> Void)] = []

    func schedule(after delay: TimeInterval, _ work: @escaping () -> Void) {
        pending.append((now + delay, work))
    }

    func advance(by interval: TimeInterval) {
        let target = now + interval
        while let index = pending.indices.filter({ pending[$0].due <= target }).min(by: { pending[$0].due < pending[$1].due }) {
            let item = pending.remove(at: index)
            now = item.due
            item.work()
        }
        now = target
    }
}

private actor LookupGate {
    private var continuation: CheckedContinuation<Void, Never>?
    private var isOpen = false

    func wait() async {
        guard !isOpen else { return }
        await withCheckedContinuation { continuation = $0 }
    }

    func open() {
        isOpen = true
        continuation?.resume()
        continuation = nil
    }
}
