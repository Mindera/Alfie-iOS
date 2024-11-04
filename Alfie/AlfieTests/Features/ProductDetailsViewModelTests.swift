import Combine
import Mocks
import Models
import XCTest
@testable import Alfie

final class ProductDetailsViewModelTests: XCTestCase {
    private var sut: ProductDetailsViewModel!
    private var mockProductService: MockProductService!
    private var mockWebUrlProvider: MockWebUrlProvider!
    private var mockDependencies: MockProductDetailsDependencyContainer!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockProductService = MockProductService()
        mockWebUrlProvider = MockWebUrlProvider()
        mockDependencies = MockProductDetailsDependencyContainer(productService: mockProductService,
                                                                 webUrlProvider: mockWebUrlProvider)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockDependencies = nil
        mockProductService = nil
        mockWebUrlProvider = nil
        try super.tearDownWithError()
    }

    // MARK: - Init

    func test_no_placeholder_information_available_when_no_base_product_is_passed_on_init() {
        initViewModel()
        XCTAssertTrue(sut.productName.isEmpty)
        XCTAssertTrue(sut.productTitle.isEmpty)
        let colorSelectionConfiguration = sut.colorSelectionConfiguration
        let sizingSelectionConfiguration = sut.sizingSelectionConfiguration
        XCTAssertTrue(colorSelectionConfiguration.items.isEmpty)
        XCTAssertTrue(sizingSelectionConfiguration.items.isEmpty)
    }

    func test_placeholder_information_is_available_when_a_base_product_is_passed_on_init() {
        let color = Product.Colour.fixture(id: "1", name: "Color 1")
        let size = Product.ProductSize.fixture(id: "12", value: "UK 6")
        let variant = Product.Variant.fixture(size: size, colour: color)
        let product = Product.fixture(name: "Product Name",
                                      brand: .fixture(name: "Product Brand"),
                                      defaultVariant: variant,
                                      variants: [variant])
        initViewModel(product: product)
        XCTAssertEqual(sut.productName, product.name)
        XCTAssertEqual(sut.productTitle, product.brand.name)
        let colorSelectionConfiguration = sut.colorSelectionConfiguration
        XCTAssertEqual(colorSelectionConfiguration.items.count, 1)
        XCTAssertEqual(colorSelectionConfiguration.items.first?.id, color.id)
        XCTAssertEqual(colorSelectionConfiguration.items.first?.name, color.name)
        let sizingSelectionConfiguration = sut.sizingSelectionConfiguration
        XCTAssertEqual(sizingSelectionConfiguration.items.count, 1)
        XCTAssertEqual(sizingSelectionConfiguration.items.first?.id, size.id)
        XCTAssertEqual(sizingSelectionConfiguration.items.first?.name, size.value)
    }
    
    func test_sizing_selection_configuration_is_unavailable_when_there_is_no_selected_variant_on_init() {
        let color = Product.Colour.fixture(id: "1", name: "Color 1")
        let size = Product.ProductSize.fixture(id: "12", value: "UK 6")
        let variant = Product.Variant.fixture(size: size, colour: color)
        let product = Product.fixture(name: "Product Name",
                                      brand: .fixture(name: "Product Brand"),
                                      variants: [variant])
        initViewModel(product: product)
        XCTAssertEqual(sut.sizingSelectionConfiguration.items.count, 0)
    }

    // MARK: - Properties

    func test_product_id_is_the_expected_value_after_init() {
        initViewModel()
        XCTAssertTrue(sut.productId.isEmpty)

        let productId = "1"
        initViewModel(productId: productId)
        XCTAssertEqual(sut.productId, productId)
    }

    func test_product_title_is_empty_if_no_product_was_fetched() {
        initViewModel()
        XCTAssertTrue(sut.productTitle.isEmpty)
    }

    func test_product_title_is_available_after_fetching_product() {
        let product = Product.fixture(brand: .fixture(name: "Product Brand"))
        initViewModel(product: product)

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { $0.isLoading }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        XCTAssertEqual(sut.productTitle, product.brand.name)
    }

    func test_product_name_is_empty_if_no_product_was_fetched() {
        initViewModel()
        XCTAssertTrue(sut.productName.isEmpty)
    }

    func test_product_name_is_available_after_fetching_product() {
        let product = Product.fixture(name: "Product Name")
        initViewModel(product: product)

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { $0.isLoading }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        XCTAssertEqual(sut.productName, product.name)
    }

    func test_product_images_are_empty_if_no_product_was_fetched() {
        initViewModel()
        XCTAssertTrue(sut.productImageUrls.isEmpty)
    }

    func test_product_images_are_available_after_fetching_product() {
        let color = Product.Colour.fixture(media: [
            .image(.fixture(url: URL(string: "http://some.media.url.1")!)),
            .image(.fixture(url: URL(string: "http://some.media.url.2")!)),
        ])
        let variant = Product.Variant.fixture(colour: color)
        let product = Product.fixture(name: "Product Name",
                                      defaultVariant: variant,
                                      variants: [variant])
        initViewModel(product: product)

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { $0.isLoading }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        XCTAssertEqual(sut.productImageUrls.count, variant.media.count)
        XCTAssertEqual(sut.productImageUrls[0].absoluteString, variant.media[0].asImage?.url.absoluteString)
        XCTAssertEqual(sut.productImageUrls[1].absoluteString, variant.media[1].asImage?.url.absoluteString)
    }

    func test_complementary_info_options_to_display_are_available() {
        initViewModel()

        let options = sut.complementaryInfoToShow
        XCTAssertEqual(options.count, 2)
        XCTAssertEqual(options[0], .paymentOptions)
        XCTAssertEqual(options[1], .returns)
    }

    func test_product_description_is_empty_if_no_product_was_fetched() {
        initViewModel()
        XCTAssertTrue(sut.productDescription.isEmpty)
    }

    func test_product_description_is_available_after_fetching_product() {
        let product = Product.fixture(longDescription: "Product Description")
        initViewModel(product: product)

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { $0.isLoading }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        XCTAssertEqual(sut.productDescription, product.longDescription)
    }

    // MARK: - Product fetch

    func test_product_is_fetched_when_view_appears() {
        let productId = "1"
        initViewModel(productId: productId)

        let expectation = expectation(description: "Wait for service call")
        mockProductService.onGetProductCalled = { id in
            XCTAssertEqual(id, productId)
            expectation.fulfill()
            return .fixture()
        }

        sut.viewDidAppear()
        wait(for: [expectation], timeout: defaultTimeout)
    }

    func test_product_is_not_fetched_when_view_appears_if_already_fetched() {
        let productId = "1"
        initViewModel(productId: productId)

        let firstExpectation = expectation(description: "Wait for service call")
        let secondExpectation = expectation(description: "Wait for success state")
        mockProductService.onGetProductCalled = { id in
            XCTAssertEqual(id, productId)
            firstExpectation.fulfill()
            return .fixture()
        }

        let cancellable = sut.$state.eraseToAnyPublisher()
            .sink { state in
                if state.isSuccess {
                    secondExpectation.fulfill()
                }
            }

        sut.viewDidAppear()
        wait(for: [firstExpectation, secondExpectation], timeout: defaultTimeout)

        let thirdExpectation = expectation(description: "Wait for no service call")
        thirdExpectation.isInverted = true
        mockProductService.onGetProductCalled = { _ in
            thirdExpectation.fulfill()
            return .fixture()
        }

        sut.viewDidAppear()
        wait(for: [thirdExpectation], timeout: defaultTimeout)
        cancellable.cancel()
    }

    func test_state_is_success_after_product_fetch_succeeds() {
        initViewModel()

        mockProductService.onGetProductCalled = { _ in
            .fixture()
        }

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { $0.isLoading }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        XCTAssertTrue(sut.state.isSuccess)
    }

    func test_state_is_failure_after_product_fetch_fails() {
        initViewModel()

        mockProductService.onGetProductCalled = { _ in
            throw BFFRequestError(type: .generic)
        }

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { $0.isLoading }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        XCTAssertTrue(sut.state.didFail)
        XCTAssertEqual(sut.state.failure, .generic)
    }

    func test_state_is_failure_if_product_is_not_found_after_fetch() {
        initViewModel()

        mockProductService.onGetProductCalled = { _ in
            throw BFFRequestError(type: .emptyResponse)
        }

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { $0.isLoading }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        XCTAssertTrue(sut.state.didFail)
        XCTAssertEqual(sut.state.failure, .notFound)
    }

    func test_state_has_default_variant_selected_after_fetch() {
        initViewModel()

        let color1 = Product.Colour.fixture(id: "1", name: "Color 1")
        let color2 = Product.Colour.fixture(id: "2", name: "Color 2")
        let size1 = Product.ProductSize.fixture(id: "12", value: "UK 6")
        let size2 = Product.ProductSize.fixture(id: "13", value: "UK 8")
        let variant1 = Product.Variant.fixture(size: size1, colour: color1, stock: 1)
        let variant2 = Product.Variant.fixture(size: size2, colour: color2, stock: 2)
        let product = Product.fixture(name: "Product Name",
                                      brand: .fixture(name: "Product Brand"),
                                      defaultVariant: variant1,
                                      variants: [variant1, variant2])
        mockProductService.onGetProductCalled = { _ in
            product
        }

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { $0.isLoading }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        let selectedVariant = sut.state.value?.selectedVariant
        XCTAssertNotNil(selectedVariant)
        XCTAssertEqual(selectedVariant?.colour?.id, variant1.colour?.id)
        XCTAssertEqual(selectedVariant?.colour?.name, variant1.colour?.name)
        XCTAssertEqual(selectedVariant?.size?.id, variant1.size?.id)
        XCTAssertEqual(selectedVariant?.size?.value, variant1.size?.value)
        XCTAssertEqual(selectedVariant?.stock, variant1.stock)
    }

    // MARK: - Loading state

    func test_state_is_loading_on_init() {
        initViewModel()
        XCTAssertTrue(sut.state.isLoading)
    }

    func test_state_is_loading_when_fetching_product() {
        initViewModel()

        let state = captureEvent(fromPublisher: sut.$state.eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        XCTAssertEqual(state?.isLoading, true)
    }

    func test_reports_title_section_loading_when_loading_and_no_placeholder_available() {
        initViewModel()

        let result = sut.shouldShowLoading(for: .titleHeader)
        XCTAssertTrue(result)
    }

    func test_does_not_report_title_section_loading_when_placeholder_available() {
        let product = Product.fixture(name: "Product Name")
        initViewModel(product: product)

        let result = sut.shouldShowLoading(for: .titleHeader)
        XCTAssertFalse(result)
    }

    func test_does_not_report_title_section_loading_when_not_loading() {
        initViewModel()

        mockProductService.onGetProductCalled = { _ in
            .fixture()
        }

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { $0.isLoading }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        let result = sut.shouldShowLoading(for: .titleHeader)
        XCTAssertFalse(result)
    }

    func test_reports_color_section_loading_when_loading() {
        initViewModel()

        let result = sut.shouldShowLoading(for: .colorSelector)
        XCTAssertTrue(result)
    }

    func test_does_not_report_color_section_loading_when_not_loading() {
        initViewModel()

        mockProductService.onGetProductCalled = { _ in
            .fixture()
        }

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { $0.isLoading }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        let result = sut.shouldShowLoading(for: .colorSelector)
        XCTAssertFalse(result)
    }
    
    func test_reports_size_section_loading_when_loading() {
        initViewModel()

        let result = sut.shouldShowLoading(for: .sizeSelector)
        XCTAssertTrue(result)
    }
    
    func test_does_not_report_size_section_loading_when_not_loading() {
        initViewModel()

        mockProductService.onGetProductCalled = { _ in
            .fixture()
        }

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { $0.isLoading }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        let result = sut.shouldShowLoading(for: .sizeSelector)
        XCTAssertFalse(result)
    }

    func test_reports_media_carousel_section_loading_when_loading() {
        initViewModel()

        let result = sut.shouldShowLoading(for: .mediaCarousel)
        XCTAssertTrue(result)
    }

    func test_does_not_report_media_carousel_section_loading_when_not_loading() {
        initViewModel()

        mockProductService.onGetProductCalled = { _ in
            .fixture()
        }

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { $0.isLoading }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        let result = sut.shouldShowLoading(for: .mediaCarousel)
        XCTAssertFalse(result)
    }

    func test_reports_complementary_info_section_loading_when_loading() {
        initViewModel()

        let result = sut.shouldShowLoading(for: .complementaryInfo)
        XCTAssertTrue(result)
    }

    func test_does_not_report_complementary_info_section_loading_when_not_loading() {
        initViewModel()

        mockProductService.onGetProductCalled = { _ in
            .fixture()
        }

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { $0.isLoading }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        let result = sut.shouldShowLoading(for: .complementaryInfo)
        XCTAssertFalse(result)
    }

    func test_does_not_report_description_section_loading_when_loading() {
        initViewModel()

        let result = sut.shouldShowLoading(for: .productDescription)
        XCTAssertFalse(result)
    }

    func test_does_not_report_description_section_loading_when_not_loading() {
        initViewModel()

        mockProductService.onGetProductCalled = { _ in
            .fixture()
        }

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { $0.isLoading }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        let result = sut.shouldShowLoading(for: .productDescription)
        XCTAssertFalse(result)
    }

    // MARK: - Color selection

    func test_color_selection_configuration_is_available_after_product_fetch() {
        initViewModel()

        let stringUrl = "http://www.some.image"
        let color = Product.Colour.fixture(id: "1", swatch: .fixture(url: URL(string: stringUrl)!), name: "Color 1")
        let product = Product.fixture(name: "Product Name",
                                      brand: .fixture(name: "Product Brand"),
                                      variants: [.fixture(colour: color)])
        mockProductService.onGetProductCalled = { _ in
            product
        }

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { $0.isLoading }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        let colorSelectionConfiguration = sut.colorSelectionConfiguration
        XCTAssertEqual(colorSelectionConfiguration.items.count, 1)
        XCTAssertEqual(colorSelectionConfiguration.items.first?.id, color.id)
        XCTAssertEqual(colorSelectionConfiguration.items.first?.name, color.name)
        switch colorSelectionConfiguration.items.first?.type {
            case .url(let url):
                XCTAssertEqual(url.absoluteString, stringUrl)
            default:
                XCTFail("Unexpected swatch type")
        }
    }

    func test_color_selection_swatch_is_black_by_default_for_invalid_swatch_urls() {
        initViewModel()

        let color = Product.Colour.fixture(id: "1", name: "Color 1")
        let product = Product.fixture(name: "Product Name",
                                      brand: .fixture(name: "Product Brand"),
                                      variants: [.fixture(colour: color)])
        mockProductService.onGetProductCalled = { _ in
            product
        }

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { $0.isLoading }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        let colorSelectionConfiguration = sut.colorSelectionConfiguration
        XCTAssertEqual(colorSelectionConfiguration.items.first?.type, .color(.black))
    }

    func test_state_has_selected_variant_when_color_is_selected() {
        initViewModel()

        let color1 = Product.Colour.fixture(id: "1", name: "Color 1")
        let color2 = Product.Colour.fixture(id: "2", name: "Color 2")
        let variant1 = Product.Variant.fixture(colour: color1, stock: 1)
        let variant2 = Product.Variant.fixture(colour: color2, stock: 2)
        let product = Product.fixture(name: "Product Name",
                                      brand: .fixture(name: "Product Brand"),
                                      defaultVariant: variant1,
                                      variants: [variant1, variant2])
        mockProductService.onGetProductCalled = { _ in
            product
        }

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { $0.isLoading }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        let colorSelectionConfiguration = sut.colorSelectionConfiguration
        _ = captureEvent(fromPublisher: sut.$state.drop(while: { $0.isLoading }).eraseToAnyPublisher(), afterTrigger: {
            colorSelectionConfiguration.selectedItem = colorSelectionConfiguration.items[1]
        })

        let selectedVariant = sut.state.value?.selectedVariant
        XCTAssertNotNil(selectedVariant)
        XCTAssertEqual(selectedVariant?.colour?.id, variant2.colour?.id)
        XCTAssertEqual(selectedVariant?.colour?.name, variant2.colour?.name)
        XCTAssertEqual(selectedVariant?.stock, variant2.stock)
    }

    func test_state_is_not_updated_if_nil_color_is_selected() {
        initViewModel()

        let color1 = Product.Colour.fixture(id: "1", name: "Color 1")
        let color2 = Product.Colour.fixture(id: "2", name: "Color 2")
        let variant1 = Product.Variant.fixture(colour: color1, stock: 1)
        let variant2 = Product.Variant.fixture(colour: color2, stock: 2)
        let product = Product.fixture(name: "Product Name",
                                      brand: .fixture(name: "Product Brand"),
                                      defaultVariant: variant1,
                                      variants: [variant1, variant2])
        mockProductService.onGetProductCalled = { _ in
            product
        }

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { $0.isLoading }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        let colorSelectionConfiguration = sut.colorSelectionConfiguration
        let result = assertNoEvent(from: sut.$state.eraseToAnyPublisher(), afterTrigger: { colorSelectionConfiguration.selectedItem = nil }, timeout: defaultTimeout)
        XCTAssertTrue(result)
    }

    func test_state_is_not_updated_if_unknown_color_is_selected() {
        initViewModel()

        let color1 = Product.Colour.fixture(id: "1", name: "Color 1")
        let color2 = Product.Colour.fixture(id: "2", name: "Color 2")
        let variant1 = Product.Variant.fixture(colour: color1, stock: 1)
        let variant2 = Product.Variant.fixture(colour: color2, stock: 2)
        let product = Product.fixture(name: "Product Name",
                                      brand: .fixture(name: "Product Brand"),
                                      defaultVariant: variant1,
                                      variants: [variant1, variant2])
        mockProductService.onGetProductCalled = { _ in
            product
        }

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { $0.isLoading }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        let colorSelectionConfiguration = sut.colorSelectionConfiguration
        let result = assertNoEvent(from: sut.$state.eraseToAnyPublisher(), afterTrigger: { colorSelectionConfiguration.selectedItem = ColorSwatch(id: "3", name: "Color 3", type: .color(.black)) }, timeout: defaultTimeout)
        XCTAssertTrue(result)
    }

    func test_product_images_are_updated_when_color_is_selected() {
        let color1 = Product.Colour.fixture(id: "1", name: "Color 1", media: [
            .image(.fixture(url: URL(string: "http://some.media.url.variant1.1")!)),
            .image(.fixture(url: URL(string: "http://some.media.url.variant1.2")!)),
        ])
        let variant1 = Product.Variant.fixture(colour: color1, stock: 1)
        let color2 = Product.Colour.fixture(id: "2", name: "Color 2", media: [
            .image(.fixture(url: URL(string: "http://some.media.url.variant2.1")!)),
            .image(.fixture(url: URL(string: "http://some.media.url.variant2.2")!)),
        ])
        let variant2 = Product.Variant.fixture(colour: color2, stock: 1)
        let product = Product.fixture(name: "Product Name",
                                      defaultVariant: variant1,
                                      variants: [variant1, variant2])
        initViewModel(product: product)

        mockProductService.onGetProductCalled = { _ in
            product
        }

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { $0.isLoading }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        let colorSelectionConfiguration = sut.colorSelectionConfiguration
        _ = captureEvent(fromPublisher: sut.$state.drop(while: { $0.isLoading }).eraseToAnyPublisher(), afterTrigger: {
            colorSelectionConfiguration.selectedItem = colorSelectionConfiguration.items[1]
        })

        XCTAssertEqual(sut.productImageUrls.count, variant2.media.count)
        XCTAssertEqual(sut.productImageUrls[0].absoluteString, variant2.media[0].asImage?.url.absoluteString)
        XCTAssertEqual(sut.productImageUrls[1].absoluteString, variant2.media[1].asImage?.url.absoluteString)
    }

    // MARK: - Complementary Info

    func test_complementary_info_webfeature_is_returned_for_available_options() throws {
        initViewModel()

        let returnedPaymentWebFeature = try XCTUnwrap(sut.complementaryInfoWebFeature(for: .paymentOptions))
        XCTAssertEqual(returnedPaymentWebFeature, WebFeature.paymentOptions)

        let returnedReturnsWebFeature = try XCTUnwrap(sut.complementaryInfoWebFeature(for: .returns))
        XCTAssertEqual(returnedReturnsWebFeature, WebFeature.returnOptions)
    }

    func test_complementary_info_webfeature_is_nil_for_unavailable_options() throws {
        initViewModel()

        XCTAssertNil(sut.complementaryInfoWebFeature(for: .delivery))
    }

    // MARK: - Section visibility

    func test_reports_title_header_section_as_visible() {
        initViewModel()

        XCTAssertTrue(sut.shouldShow(section: .titleHeader))
    }

    func test_reports_color_selection_section_as_visible() {
        initViewModel()

        XCTAssertTrue(sut.shouldShow(section: .colorSelector))
    }
    
    func test_reports_sizing_selection_section_as_visible() {
        initViewModel()

        XCTAssertTrue(sut.shouldShow(section: .sizeSelector))
    }

    func test_reports_complementary_info_section_as_visible() {
        initViewModel()

        XCTAssertTrue(sut.shouldShow(section: .complementaryInfo))
    }

    func test_reports_media_carousel_section_as_visible_if_loading() {
        initViewModel()

        XCTAssertTrue(sut.shouldShow(section: .mediaCarousel))
    }

    func test_reports_media_carousel_section_as_visible_if_media_available() {
        initViewModel()
        let color = Product.Colour.fixture(media: [
            .image(.fixture(url: URL(string: "http://some.media.url.1")!)),
            .image(.fixture(url: URL(string: "http://some.media.url.2")!)),
        ])
        let variant = Product.Variant.fixture(colour: color)
        let product = Product.fixture(name: "Product Name",
                                      defaultVariant: variant,
                                      variants: [variant])
        mockProductService.onGetProductCalled = { _ in
            product
        }

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { $0.isLoading }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        XCTAssertTrue(sut.shouldShow(section: .mediaCarousel))
    }

    func test_reports_media_carousel_section_as_not_visible_if_no_media_available() {
        initViewModel()
        let color = Product.Colour.fixture(media: [])
        let variant = Product.Variant.fixture(colour: color)
        let product = Product.fixture(name: "Product Name",
                                      defaultVariant: variant,
                                      variants: [variant])
        mockProductService.onGetProductCalled = { _ in
            product
        }

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { $0.isLoading }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        XCTAssertFalse(sut.shouldShow(section: .mediaCarousel))
    }

    func test_reports_product_description_section_as_visible_if_description_available() {
        initViewModel()

        let product = Product.fixture(longDescription: "Product Description")
        mockProductService.onGetProductCalled = { _ in
            product
        }

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { $0.isLoading }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        XCTAssertTrue(sut.shouldShow(section: .productDescription))
    }

    func test_reports_product_description_section_as_not_visible_if_no_description_available() {
        initViewModel()

        let product = Product.fixture()
        mockProductService.onGetProductCalled = { _ in
            product
        }

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { $0.isLoading }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        XCTAssertFalse(sut.shouldShow(section: .productDescription))
    }

    func test_reports_add_to_bag_section_as_visible_if_state_is_success() {
        initViewModel()

        let product = Product.fixture()
        mockProductService.onGetProductCalled = { _ in
            product
        }

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { $0.isLoading }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        XCTAssertTrue(sut.shouldShow(section: .addToBag))
    }

    func test_reports_add_to_bag_section_as_not_visible_if_state_is_failure() {
        initViewModel()

        mockProductService.onGetProductCalled = { _ in
            throw BFFRequestError(type: .generic)
        }

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { $0.isLoading }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        XCTAssertFalse(sut.shouldShow(section: .addToBag))
    }

    func test_reports_add_to_bag_section_as_not_visible_if_state_is_loading() {
        initViewModel()

        XCTAssertFalse(sut.shouldShow(section: .addToBag))
    }

    // MARK: - Share

    func test_share_configuration_is_unavailable_while_loading() {
        initViewModel()

        XCTAssertNil(sut.shareConfiguration)
    }

    func test_share_configuration_is_unavailable_if_fetch_fails() {
        initViewModel()

        mockProductService.onGetProductCalled = { _ in
            throw BFFRequestError(type: .generic)
        }

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { $0.isLoading }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        XCTAssertNil(sut.shareConfiguration)
    }

    func test_share_configuration_is_available_after_product_fetch() {
        initViewModel()

        let urlString = "http://some.url/some-product"
        let slug = "some-product-slug-12345"
        let variant = Product.Variant.fixture(price: .fixture(amount: .fixture(amountFormatted: "999$")))
        let product = Product.fixture(name: "Product Name",
                                      brand: .fixture(name: "Product Brand"),
                                      slug: slug,
                                      defaultVariant: variant,
                                      variants: [variant])
        mockProductService.onGetProductCalled = { _ in
            product
        }

        mockWebUrlProvider.onUrlCalled = { endpoint in
            XCTAssertTrue(endpoint.path.contains(slug))
            return URL(string: urlString)
        }

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { $0.isLoading }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        let shareConfiguration = sut.shareConfiguration
        XCTAssertNotNil(shareConfiguration)
        XCTAssertEqual(shareConfiguration?.url.absoluteString, urlString)
        XCTAssertEqual(shareConfiguration?.message, "\nProduct Brand\nProduct Name\n999$\n")
        XCTAssertEqual(shareConfiguration?.subject, "Product Name from Alfie")
    }

    func test_search_returns_correct_swatches() {
        let expectedMatchedColors = [Product.Colour.fixture(name: "color 1"), Product.Colour.fixture(name: "COLOR 2")]
        let expectedNonMatchedColors = [Product.Colour.fixture(name: "Clor"), Product.Colour.fixture(name: "Coror")]

        let product = Product.fixture(name: "Product Name",
                                      brand: .fixture(name: "Product Brand"),
                                      variants: (expectedMatchedColors + expectedNonMatchedColors).map { Product.Variant.fixture(colour: $0) })

        initViewModel(product: product)
        let allSwatches = sut.colorSelectionConfiguration.items
        let swatchesSearchResult = sut.colorSwatches(filteredBy: "Col")
        XCTAssertTrue(swatchesSearchResult.map(\.name).contains(expectedMatchedColors.map(\.name)))
        XCTAssertFalse(swatchesSearchResult.map(\.name).contains(expectedNonMatchedColors.map(\.name)))
    }

    // MARK: - Helper methods

    private func initViewModel(productId: String = "", product: Product? = nil) {
        sut = .init(productId: productId,
                    product: product,
                    dependencies: mockDependencies)
    }
}
