import Core
import DeepLink
import Mocks
import Model
import SharedUI
import XCTest
@testable import Scanner

/// The scanner's behaviour, driven through the ``CameraScanServiceProtocol`` seam rather than a camera.
///
/// The deep-link service under test is the **real** one, wired with the parser chain the app
/// installs, so a test payload here is the same string the printed Alfie code carries and the
/// assertion is on the deep link the app would actually route. Substituting a stubbed parse would
/// leave the one thing this feature depends on — that an Alfie code resolves to a product link —
/// asserted nowhere.
final class ScannerViewModelTests: XCTestCase {
    private var scanService: MockCameraScanService!
    private var deepLinkService: DeepLinkService!
    private var handledDeepLinks: [DeepLink]!
    private var closeCount: Int!
    private var openSettingsCount: Int!
    private var mockAnalytics: MockAnalyticsTracker!
    private var sut: ScannerViewModel!

    /// The format the generator prints — see `Tools/AlfieCodeGen` and ADR-0001.
    private static let alfieCode = "https://localhost:4000/product/slim-indigo-jean"
    private static let alfieCodeWithSku = "https://localhost:4000/product/slim-indigo-jean?sku=SKU-42"
    private static let multiSegmentAlfieCode = "https://localhost:4000/product/mens/jeans/slim-indigo"

    override func setUpWithError() throws {
        try super.setUpWithError()

        handledDeepLinks = []
        closeCount = 0
        openSettingsCount = 0
        mockAnalytics = MockAnalyticsTracker()
        scanService = MockCameraScanService()

        let handler = MockDeepLinkHandler()
        handler.onCanHandleDeepLinkCalled = { _ in true }
        handler.onHandleDeepLinkCalled = { [weak self] in self?.handledDeepLinks.append($0) }

        deepLinkService = DeepLinkService(configuration: LinkConfiguration(), log: MockLogger())
        deepLinkService.update(handlers: [handler])

        let scanService = try XCTUnwrap(scanService)
        sut = ScannerViewModel(
            dependencies: .init(
                deepLinkService: deepLinkService,
                makeScanService: { scanService },
                analytics: mockAnalytics.eraseToAnyAnalyticsTracker(),
                log: MockLogger()
            ),
            // The flow's closures, standing in for HomeFlowViewModel: the first hands the scanned
            // link to the real deep-link service, so these tests still assert on the link the app
            // routes.
            openScannedLink: { [weak self] url in self?.deepLinkService.openUrls([url]) },
            openAppSettings: { [weak self] in self?.openSettingsCount += 1 },
            close: { [weak self] in self?.closeCount += 1 }
        )
    }

    override func tearDownWithError() throws {
        sut = nil
        deepLinkService = nil
        scanService = nil
        handledDeepLinks = nil
        closeCount = nil
        openSettingsCount = nil
        mockAnalytics = nil
        try super.tearDownWithError()
    }

    // MARK: - Scanning an Alfie code

    func test_scanningAnAlfieCodeOpensItsProductAndClosesTheScanner() throws {
        sut.viewDidAppear()

        scanService.recognise(Self.alfieCode)

        XCTAssertEqual(try handledHandle(), "slim-indigo-jean")
        XCTAssertEqual(closeCount, 1)
    }

    /// The scanner is dismissed before the product opens, not left behind it: the deep-link path
    /// pushes onto a tab that the scanner is covering.
    func test_theScannerIsClosedBeforeTheProductIsOpened() {
        var eventsInOrder: [String] = []
        let handler = MockDeepLinkHandler()
        handler.onCanHandleDeepLinkCalled = { _ in true }
        handler.onHandleDeepLinkCalled = { _ in eventsInOrder.append("open") }
        deepLinkService.update(handlers: [handler])

        let scanService = MockCameraScanService()
        let sut = ScannerViewModel(
            dependencies: .init(
                deepLinkService: deepLinkService,
                makeScanService: { scanService },
                analytics: mockAnalytics.eraseToAnyAnalyticsTracker(),
                log: MockLogger()
            ),
            openScannedLink: { [weak self] url in self?.deepLinkService.openUrls([url]) },
            openAppSettings: { },
            close: { eventsInOrder.append("close") }
        )
        sut.viewDidAppear()

        scanService.recognise(Self.alfieCode)

        XCTAssertEqual(eventsInOrder, ["close", "open"])
    }

    /// The Handle is a route path on BigCommerce, so it routinely carries separators. All of it has
    /// to reach the Product Details page.
    func test_aMultiSegmentHandleReachesTheProductIntact() throws {
        sut.viewDidAppear()

        scanService.recognise(Self.multiSegmentAlfieCode)

        XCTAssertEqual(try handledHandle(), "mens/jeans/slim-indigo")
    }

    /// The printed code carries a SKU so that reprinting is not needed when Variant preselection
    /// lands. Until then it must neither be honoured nor get in the way.
    ///
    /// What this test can show is the first half: the SKU survives the scanner and reaches the deep
    /// link intact, rather than being stripped or making the code unrecognisable. The Product then
    /// opening on its *default* Variant is not this module's doing — the SKU is discarded downstream
    /// in `TabRoute`'s `case .productDetail(let handle, _, _)`, which is pre-existing routing already
    /// covered by `DeepLinkRoutingTests`. Naming that half here would claim an assertion this test
    /// does not make.
    func test_aSkuInTheCodeIsCarriedIntoTheDeepLink() throws {
        sut.viewDidAppear()

        scanService.recognise(Self.alfieCodeWithSku)

        let deepLink = try XCTUnwrap(handledDeepLinks.first)
        guard case .productDetail(let handle, _, let query) = deepLink.type else {
            return XCTFail("Expected a product deep link, got \(deepLink.type)")
        }
        XCTAssertEqual(handle, "slim-indigo-jean")
        XCTAssertEqual(query?["sku"], "SKU-42")
    }

    // MARK: - Scanning the same code twice

    func test_theSameCodeSeenTwiceOpensOneProduct() {
        sut.viewDidAppear()

        scanService.recognise(Self.alfieCode)
        scanService.recognise(Self.alfieCode)

        XCTAssertEqual(handledDeepLinks.count, 1)
        XCTAssertEqual(closeCount, 1)
    }

    func test_recognitionStopsOnceAProductIsOpened() {
        sut.viewDidAppear()
        XCTAssertTrue(scanService.isScanning)

        scanService.recognise(Self.alfieCode)

        XCTAssertFalse(scanService.isScanning)
    }

    /// A scan that has already navigated must not be undone by the screen going away and coming
    /// back — which is exactly what happens as the Product Details page is pushed.
    func test_recognitionDoesNotResumeAfterAProductIsOpened() {
        sut.viewDidAppear()
        scanService.recognise(Self.alfieCode)

        sut.viewDidDisappear()
        sut.viewDidAppear()

        XCTAssertFalse(scanService.isScanning)
    }

    // MARK: - Codes that are not Alfie codes

    func test_aCodeThatIsNotAProductLinkOpensNothingAndKeepsScanning() {
        sut.viewDidAppear()

        scanService.recognise("https://example.com/not-an-alfie-code")
        scanService.recognise("5901234123457")
        scanService.recognise("")

        XCTAssertTrue(handledDeepLinks.isEmpty)
        XCTAssertEqual(closeCount, 0)
        XCTAssertTrue(scanService.isScanning)
    }

    /// Silence would read as a broken scanner: the shopper is holding the camera over something and
    /// nothing is happening. Saying the code is not ours is what tells them to look for a different
    /// one — and it is said over the running camera, not instead of it.
    func test_aCodeThatIsNotAnAlfieCodeSaysSo() {
        sut.viewDidAppear()

        scanService.recognise("https://example.com/not-an-alfie-code")

        XCTAssertEqual(sut.state.value?.notice?.message, L10n.Scanner.Unrecognised.message)
    }

    /// The scanner has to still be *open* for the next code to reach it. Asserting only that the
    /// good code opened its Product would pass on a scanner that had closed and been reopened,
    /// which is not what the shopper standing at the rail experiences.
    func test_aValidAlfieCodeIsStillRecognisedAfterAnUnrecognisedOne() throws {
        sut.viewDidAppear()

        scanService.recognise("https://example.com/not-an-alfie-code")

        XCTAssertTrue(scanService.isScanning)
        XCTAssertEqual(closeCount, 0)

        scanService.recognise(Self.alfieCode)

        XCTAssertEqual(try handledHandle(), "slim-indigo-jean")
    }

    /// A second bad code in a row says exactly what the first one said. It still has to count as a
    /// new notice: the screen announces on change, so words alone would leave VoiceOver silent at
    /// the moment the shopper has just failed again. See ``ScannerNotice``.
    func test_theSameUnrecognisedCodeTwiceIsTwoDistinctNotices() throws {
        sut.viewDidAppear()

        scanService.recognise("https://example.com/not-an-alfie-code")
        let first = try XCTUnwrap(sut.state.value?.notice)

        scanService.recognise("https://example.com/not-an-alfie-code")
        let second = try XCTUnwrap(sut.state.value?.notice)

        XCTAssertEqual(first.message, second.message)
        XCTAssertNotEqual(first, second)
    }

    func test_dismissingTheNoticeLeavesTheGuidanceInPlace() {
        sut.viewDidAppear()
        scanService.recognise("https://example.com/not-an-alfie-code")

        sut.didDismissNotice()

        XCTAssertNil(sut.state.value?.notice)
        XCTAssertEqual(sut.state.value?.guidance, L10n.Scanner.Guidance.message)
    }

    // MARK: - When recognition runs

    func test_recognitionRunsOnlyWhileTheScreenIsOnScreen() {
        XCTAssertFalse(scanService.isScanning)

        sut.viewDidAppear()
        XCTAssertTrue(scanService.isScanning)

        sut.viewDidDisappear()
        XCTAssertFalse(scanService.isScanning)
    }

    func test_backgroundingStopsRecognitionAndReturningResumesIt() {
        sut.viewDidAppear()

        sut.didChangeScenePhase(isActive: false)
        XCTAssertFalse(scanService.isScanning)

        sut.didChangeScenePhase(isActive: true)
        XCTAssertTrue(scanService.isScanning)
    }

    /// Coming back to the foreground while the scanner is *not* the visible screen must not switch
    /// the camera on behind it.
    func test_returningToTheForegroundDoesNotResumeAScreenThatHasGoneAway() {
        sut.viewDidAppear()
        sut.viewDidDisappear()

        sut.didChangeScenePhase(isActive: true)

        XCTAssertFalse(scanService.isScanning)
    }

    /// Repeated appearances do not stack camera sessions.
    func test_startingAnAlreadyRunningScanIsNotRepeatedOnTheCamera() {
        sut.viewDidAppear()
        sut.viewDidAppear()
        sut.didChangeScenePhase(isActive: true)

        XCTAssertEqual(scanService.startCount, 1)
    }

    // MARK: - When there is no camera to look through

    func test_aRefusedCameraIsExplained() {
        sut.viewDidAppear()

        scanService.fail(with: .permissionDenied)

        XCTAssertEqual(sut.state.failure, .cameraPermissionDenied)
    }

    func test_aDeviceThatCannotScanIsExplained() {
        sut.viewDidAppear()

        scanService.fail(with: .deviceNotSupported)

        XCTAssertEqual(sut.state.failure, .deviceNotSupported)
    }

    func test_aCameraThatWillNotStartFallsBackToTheGenericExplanation() {
        sut.viewDidAppear()

        scanService.fail(with: .unavailable)

        XCTAssertEqual(sut.state.failure, .generic)
    }

    /// The explanation replaces the screen, so anything that was being said over the camera goes
    /// with it — a notice about the last code read is meaningless once there is no camera.
    func test_anExplanationReplacesTheNoticeAndTheGuidance() {
        sut.viewDidAppear()
        scanService.recognise("https://example.com/not-an-alfie-code")

        scanService.fail(with: .permissionDenied)

        XCTAssertNil(sut.state.value)
    }

    func test_aRefusedCameraOffersTheWayToSettings() {
        sut.viewDidAppear()
        scanService.fail(with: .permissionDenied)

        sut.didTapOpenSettings()

        XCTAssertEqual(openSettingsCount, 1)
    }

    /// Settings is reached by leaving the app, so the fix always arrives as a return to the
    /// foreground. The camera is asked again on the way back rather than leaving the shopper looking
    /// at an explanation of a permission they have just granted.
    func test_returningToTheForegroundAsksTheCameraAgainAfterAFailure() {
        sut.viewDidAppear()
        scanService.fail(with: .permissionDenied)

        sut.didChangeScenePhase(isActive: false)
        sut.didChangeScenePhase(isActive: true)

        XCTAssertNil(sut.state.failure)
        XCTAssertTrue(scanService.isScanning)
    }

    // MARK: - Reporting why a scan failed

    /// Every way a scan ends without a Product reports under one event, distinguished by reason —
    /// the reasons are read against each other, so each has to arrive under its own name.
    func test_anUnrecognisedCodeIsReportedAsUnrecognised() {
        sut.viewDidAppear()

        scanService.recognise("https://example.com/not-an-alfie-code")

        XCTAssertEqual(reportedScanFailures, ["unrecognised"])
    }

    func test_aRefusedCameraIsReportedAsPermissionDenied() {
        sut.viewDidAppear()

        scanService.fail(with: .permissionDenied)

        XCTAssertEqual(reportedScanFailures, ["permission_denied"])
    }

    func test_aDeviceThatCannotScanIsReportedAsUnsupported() {
        sut.viewDidAppear()

        scanService.fail(with: .deviceNotSupported)

        XCTAssertEqual(reportedScanFailures, ["unsupported"])
    }

    func test_aCameraThatWillNotStartIsReportedAsGeneric() {
        sut.viewDidAppear()

        scanService.fail(with: .unavailable)

        XCTAssertEqual(reportedScanFailures, ["generic"])
    }

    /// A scan that works is not a failure. Without this the event would count openings as well as
    /// failures and the breakdown would describe nothing.
    func test_aScanThatOpensAProductIsNotReported() {
        sut.viewDidAppear()

        scanService.recognise(Self.alfieCode)

        XCTAssertTrue(reportedScanFailures.isEmpty)
    }

    // MARK: - Closing

    func test_closingDismissesWithoutOpeningAProduct() {
        sut.viewDidAppear()

        sut.didTapClose()

        XCTAssertEqual(closeCount, 1)
        XCTAssertTrue(handledDeepLinks.isEmpty)
    }

    // MARK: - Helpers

    /// The `reason` carried by each `scan_failed` event, in order.
    private var reportedScanFailures: [String] {
        mockAnalytics.trackedValues(of: .reason, for: .scanFailed)
    }

    private func handledHandle() throws -> String {
        let deepLink = try XCTUnwrap(handledDeepLinks.first)
        guard case .productDetail(let handle, _, _) = deepLink.type else {
            XCTFail("Expected a product deep link, got \(deepLink.type)")
            return ""
        }
        return handle
    }
}
