import Core
import DeepLink
import Mocks
import Model
import XCTest
@testable import Scanner

/// The scanner's behaviour, driven through the ``ScanSourceProtocol`` seam rather than a camera.
///
/// The deep-link service under test is the **real** one, wired with the parser chain the app
/// installs, so a test payload here is the same string the printed Alfie code carries and the
/// assertion is on the deep link the app would actually route. Substituting a stubbed parse would
/// leave the one thing this feature depends on — that an Alfie code resolves to a product link —
/// asserted nowhere.
final class ScannerViewModelTests: XCTestCase {
    private var scanSource: MockScanSource!
    private var deepLinkService: DeepLinkService!
    private var handledDeepLinks: [DeepLink]!
    private var closeCount: Int!
    private var sut: ScannerViewModel!

    /// The format the generator prints — see `Tools/AlfieCodeGen` and ADR-0001.
    private static let alfieCode = "https://localhost:4000/product/slim-indigo-jean"
    private static let alfieCodeWithSku = "https://localhost:4000/product/slim-indigo-jean?sku=SKU-42"
    private static let multiSegmentAlfieCode = "https://localhost:4000/product/mens/jeans/slim-indigo"

    override func setUpWithError() throws {
        try super.setUpWithError()

        handledDeepLinks = []
        closeCount = 0
        scanSource = MockScanSource()

        let handler = MockDeepLinkHandler()
        handler.onCanHandleDeepLinkCalled = { _ in true }
        handler.onHandleDeepLinkCalled = { [weak self] in self?.handledDeepLinks.append($0) }

        deepLinkService = DeepLinkService(configuration: LinkConfiguration(), log: MockLogger())
        deepLinkService.update(handlers: [handler])

        let scanSource = try XCTUnwrap(scanSource)
        sut = ScannerViewModel(
            dependencies: .init(
                deepLinkService: deepLinkService,
                makeScanSource: { scanSource },
                log: MockLogger()
            ),
            close: { [weak self] in self?.closeCount += 1 }
        )
    }

    override func tearDownWithError() throws {
        sut = nil
        deepLinkService = nil
        scanSource = nil
        handledDeepLinks = nil
        closeCount = nil
        try super.tearDownWithError()
    }

    // MARK: - Scanning an Alfie code

    func test_scanningAnAlfieCodeOpensItsProductAndClosesTheScanner() throws {
        sut.viewDidAppear()

        scanSource.recognise(Self.alfieCode)

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

        let scanSource = MockScanSource()
        let sut = ScannerViewModel(
            dependencies: .init(
                deepLinkService: deepLinkService,
                makeScanSource: { scanSource },
                log: MockLogger()
            ),
            close: { eventsInOrder.append("close") }
        )
        sut.viewDidAppear()

        scanSource.recognise(Self.alfieCode)

        XCTAssertEqual(eventsInOrder, ["close", "open"])
    }

    /// The Handle is a route path on BigCommerce, so it routinely carries separators. All of it has
    /// to reach the Product Details page.
    func test_aMultiSegmentHandleReachesTheProductIntact() throws {
        sut.viewDidAppear()

        scanSource.recognise(Self.multiSegmentAlfieCode)

        XCTAssertEqual(try handledHandle(), "mens/jeans/slim-indigo")
    }

    /// The printed code carries a SKU so that reprinting is not needed when Variant preselection
    /// lands. Until then it must neither be honoured nor get in the way: the Product opens on its
    /// default Variant, which is what the Product Details page does when given a Handle alone.
    func test_aSkuInTheCodeIsCarriedButDoesNotSelectAVariant() throws {
        sut.viewDidAppear()

        scanSource.recognise(Self.alfieCodeWithSku)

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

        scanSource.recognise(Self.alfieCode)
        scanSource.recognise(Self.alfieCode)

        XCTAssertEqual(handledDeepLinks.count, 1)
        XCTAssertEqual(closeCount, 1)
    }

    func test_recognitionStopsOnceAProductIsOpened() {
        sut.viewDidAppear()
        XCTAssertTrue(scanSource.isScanning)

        scanSource.recognise(Self.alfieCode)

        XCTAssertFalse(scanSource.isScanning)
    }

    /// A scan that has already navigated must not be undone by the screen going away and coming
    /// back — which is exactly what happens as the Product Details page is pushed.
    func test_recognitionDoesNotResumeAfterAProductIsOpened() {
        sut.viewDidAppear()
        scanSource.recognise(Self.alfieCode)

        sut.viewDidDisappear()
        sut.viewDidAppear()

        XCTAssertFalse(scanSource.isScanning)
    }

    // MARK: - Codes that are not Alfie codes

    func test_aCodeThatIsNotAProductLinkOpensNothingAndKeepsScanning() {
        sut.viewDidAppear()

        scanSource.recognise("https://example.com/not-an-alfie-code")
        scanSource.recognise("5901234123457")
        scanSource.recognise("")

        XCTAssertTrue(handledDeepLinks.isEmpty)
        XCTAssertEqual(closeCount, 0)
        XCTAssertTrue(scanSource.isScanning)
    }

    // MARK: - When recognition runs

    func test_recognitionRunsOnlyWhileTheScreenIsOnScreen() {
        XCTAssertFalse(scanSource.isScanning)

        sut.viewDidAppear()
        XCTAssertTrue(scanSource.isScanning)

        sut.viewDidDisappear()
        XCTAssertFalse(scanSource.isScanning)
    }

    func test_backgroundingStopsRecognitionAndReturningResumesIt() {
        sut.viewDidAppear()

        sut.didChangeScenePhase(isActive: false)
        XCTAssertFalse(scanSource.isScanning)

        sut.didChangeScenePhase(isActive: true)
        XCTAssertTrue(scanSource.isScanning)
    }

    /// Coming back to the foreground while the scanner is *not* the visible screen must not switch
    /// the camera on behind it.
    func test_returningToTheForegroundDoesNotResumeAScreenThatHasGoneAway() {
        sut.viewDidAppear()
        sut.viewDidDisappear()

        sut.didChangeScenePhase(isActive: true)

        XCTAssertFalse(scanSource.isScanning)
    }

    /// Repeated appearances do not stack camera sessions.
    func test_startingAnAlreadyRunningScanIsNotRepeatedOnTheCamera() {
        sut.viewDidAppear()
        sut.viewDidAppear()
        sut.didChangeScenePhase(isActive: true)

        XCTAssertEqual(scanSource.startCount, 1)
    }

    // MARK: - Closing

    func test_closingDismissesWithoutOpeningAProduct() {
        sut.viewDidAppear()

        sut.didTapClose()

        XCTAssertEqual(closeCount, 1)
        XCTAssertTrue(handledDeepLinks.isEmpty)
    }

    // MARK: - Helpers

    private func handledHandle() throws -> String {
        let deepLink = try XCTUnwrap(handledDeepLinks.first)
        guard case .productDetail(let handle, _, _) = deepLink.type else {
            XCTFail("Expected a product deep link, got \(deepLink.type)")
            return ""
        }
        return handle
    }
}
