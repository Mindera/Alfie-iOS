import AlicerceLogging
import Mocks
import Model
import SharedUI
import TestUtils
import XCTest
@testable import ProductDetails

final class ProductDetailsViewModelTests: XCTestCase {
    private var sut: ProductDetailsViewModel!
    private var mockProductService: MockProductService!
    private var mockWebUrlProvider: MockWebUrlProvider!
    private var mockCartService: MockCartService!
    private var mockAnalytics: MockAnalyticsTracker!
    private var mockDependencies: ProductDetailsDependencyContainer!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockProductService = MockProductService()
        mockWebUrlProvider = MockWebUrlProvider()
        mockCartService = MockCartService()
        mockAnalytics = MockAnalyticsTracker()
        mockDependencies = makeDependencies(wishlistService: MockWishlistService())
    }

    override func tearDownWithError() throws {
        sut = nil
        mockDependencies = nil
        mockProductService = nil
        mockWebUrlProvider = nil
        mockCartService = nil
        mockAnalytics = nil
        try super.tearDownWithError()
    }

    // MARK: - Init

    func test_no_placeholder_information_available_when_no_base_product_is_passed_on_init() {
        initViewModel()
        XCTAssertTrue(sut.productName.isEmpty)
        XCTAssertTrue(sut.productTitle.isEmpty)
        XCTAssertTrue(sut.variantSelection.colours.isEmpty)
        XCTAssertTrue(sut.variantSelection.sizes.isEmpty)
    }

    func test_placeholder_information_is_available_when_a_base_product_is_passed_on_init() {
        let color = Product.Colour.fixture(id: "1", name: "Color 1")
        let size = Product.ProductSize.fixture(id: "12", value: "UK 6")
        let variant = Product.Variant.fixture(size: size, colour: color)
        let product = Product.fixture(name: "Product Name",
                                      brand: .fixture(name: "Product Brand"),
                                      defaultVariant: variant,
                                      variants: [variant])
        initViewModel(configuration: .product(product))
        XCTAssertEqual(sut.productName, product.name)
        XCTAssertEqual(sut.productTitle, product.brand.name)
        let selection = sut.variantSelection
        XCTAssertEqual(selection.colours.count, 1)
        XCTAssertEqual(selection.colours.first?.id, color.id)
        XCTAssertEqual(selection.colours.first?.name, color.name)
        XCTAssertEqual(selection.sizes.count, 1)
        XCTAssertEqual(selection.sizes.first?.id, size.id)
        XCTAssertEqual(selection.sizes.first?.name, size.value)
    }
    
    func test_size_swatch_is_not_pre_selected_on_init_with_product() {
        let color = Product.Colour.fixture(id: "1", name: "Color 1")
        let product = Product.fixture(defaultVariant: twoSizeVariants(colour: color)[0],
                                      variants: twoSizeVariants(colour: color))
        initViewModel(configuration: .product(product))

        XCTAssertNil(sut.variantSelection.selectedSize)
        XCTAssertNotNil(sut.variantSelection.selectedColour)
    }

    func test_size_swatch_is_not_pre_selected_after_product_fetch() {
        initViewModel()
        let color = Product.Colour.fixture(id: "1", name: "Color 1")
        let product = Product.fixture(defaultVariant: twoSizeVariants(colour: color)[0],
                                      variants: twoSizeVariants(colour: color))
        mockProductService.onGetProductCalled = { _ in product }

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertNil(sut.variantSelection.selectedSize)
        XCTAssertNotNil(sut.variantSelection.selectedColour)
    }

    /// A lone size is implicit, so it is chosen rather than left for the shopper to tap. This is
    /// what removes the `canShowSizeSelector` special case from the add-to-bag gate.
    func test_sole_size_is_pre_selected_on_init_with_product() {
        let color = Product.Colour.fixture(id: "1", name: "Color 1")
        let size = Product.ProductSize.fixture(id: "12", value: "UK 6")
        let variant = Product.Variant.fixture(size: size, colour: color)
        let product = Product.fixture(defaultVariant: variant, variants: [variant])

        initViewModel(configuration: .product(product))

        XCTAssertEqual(sut.variantSelection.selectedSize?.id, size.id)
    }

    /// The seeding defect: the product's default variant carries no colour, so matching it against
    /// the built swatches used to leave the selection nil and the size grid empty. Colour is now
    /// seeded to the first colour whatever the default variant says.
    func test_sizes_are_offered_when_the_default_variant_matches_no_built_colour() {
        let color = Product.Colour.fixture(id: "1", name: "Color 1")
        let size = Product.ProductSize.fixture(id: "12", value: "UK 6")
        let variant = Product.Variant.fixture(size: size, colour: color)
        let product = Product.fixture(name: "Product Name",
                                      brand: .fixture(name: "Product Brand"),
                                      variants: [variant])

        initViewModel(configuration: .product(product))

        XCTAssertEqual(sut.variantSelection.selectedColour?.id, color.id)
        XCTAssertEqual(sut.variantSelection.sizes.map(\.id), [size.id])
    }

    // MARK: - Properties

    func test_product_id_is_the_expected_value_after_init() {
        initViewModel()
        XCTAssertTrue(sut.productId.isEmpty)

        let productId = "1"
        initViewModel(configuration: .id(productId))
        XCTAssertEqual(sut.productId, productId)
    }

    func test_product_title_is_empty_if_no_product_was_fetched() {
        initViewModel()
        XCTAssertTrue(sut.productTitle.isEmpty)
    }

    func test_product_title_is_available_after_fetching_product() {
        let product = Product.fixture(brand: .fixture(name: "Product Brand"))
        initViewModel(configuration: .product(product))

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertEqual(sut.productTitle, product.brand.name)
    }

    func test_product_name_is_empty_if_no_product_was_fetched() {
        initViewModel()
        XCTAssertTrue(sut.productName.isEmpty)
    }

    func test_product_name_is_available_after_fetching_product() {
        let product = Product.fixture(name: "Product Name")
        initViewModel(configuration: .product(product))

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

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
        initViewModel(configuration: .product(product))

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertEqual(sut.productImageUrls.count, variant.media.count)
        XCTAssertEqual(sut.productImageUrls[0].absoluteString, variant.media[0].asImage?.url.absoluteString)
        XCTAssertEqual(sut.productImageUrls[1].absoluteString, variant.media[1].asImage?.url.absoluteString)
    }

    // MARK: - Add to Bag gating

    func test_isAddToBagEnabled_isFalseOnInit_forMultiSizeProduct_evenWithStock() {
        let color = Product.Colour.fixture(id: "1", name: "Color 1")
        let small = Product.Variant.fixture(size: .fixture(id: "s", value: "S"), colour: color, stock: 5)
        let medium = Product.Variant.fixture(size: .fixture(id: "m", value: "M"), colour: color, stock: 5)
        let product = Product.fixture(defaultVariant: small, variants: [small, medium])
        initViewModel(configuration: .product(product))

        XCTAssertFalse(sut.isAddToBagEnabled)
    }

    func test_isAddToBagEnabled_becomesTrue_afterSizeIsSelected_onMultiSizeProduct() {
        let color = Product.Colour.fixture(id: "1", name: "Color 1")
        let small = Product.Variant.fixture(id: "v1", size: .fixture(id: "s", value: "S"), colour: color, stock: 5)
        let medium = Product.Variant.fixture(id: "v2", size: .fixture(id: "m", value: "M"), colour: color, stock: 5)
        let product = Product.fixture(defaultVariant: small, variants: [small, medium])
        initViewModel(configuration: .product(product))

        sut.didSelectSize(sut.variantSelection.sizes[0])

        XCTAssertTrue(sut.isAddToBagEnabled)
    }

    func test_isAddToBagEnabled_isFalse_whenSelectedVariantIsOutOfStock() {
        let color = Product.Colour.fixture(id: "1", name: "Color 1")
        let size = Product.ProductSize.fixture(id: "12", value: "UK 6")
        let variant = Product.Variant.fixture(size: size, colour: color, stock: 0)
        let product = Product.fixture(defaultVariant: variant, variants: [variant])
        initViewModel(configuration: .product(product))

        sut.didSelectSize(sut.variantSelection.sizes[0])

        XCTAssertFalse(sut.isAddToBagEnabled)
    }

    func test_isAddToBagEnabled_usesFreshStock_whenEnteringFromBagWithStaleVariant() {
        // Re-entering from Bag/Wishlist carries a persisted (stale) variant that was out of stock when
        // saved; after the re-fetch the gating must reflect the fresh product's stock, not the snapshot.
        let color = Product.Colour.fixture(id: "1", name: "Color 1")
        let staleVariant = Product.Variant.fixture(id: "v1", sku: "v1", colour: color, stock: 0)
        let staleProduct = Product.fixture(defaultVariant: staleVariant, variants: [staleVariant])
        let freshVariant = Product.Variant.fixture(id: "v1", sku: "v1", colour: color, stock: 5)
        let freshProduct = Product.fixture(defaultVariant: freshVariant, variants: [freshVariant])
        mockProductService.onGetProductCalled = { _ in freshProduct }

        initViewModel(
            configuration: .selectedProduct(SelectedProduct(product: staleProduct, selectedVariant: staleVariant))
        )
        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertTrue(sut.isAddToBagEnabled)
    }

    func test_isAddToBagEnabled_isTrueOnInit_forSingleSizeProduct_withStock() {
        // Product has sizes, but only one size variant exists (e.g. only available in M).
        // The View renders a non-interactive singleSizeView, so the user can't tap a swatch —
        // treat the size as implicitly selected.
        let color = Product.Colour.fixture(id: "1", name: "Color 1")
        let size = Product.ProductSize.fixture(id: "m", value: "M")
        let variant = Product.Variant.fixture(id: "v1", size: size, colour: color, stock: 5)
        let product = Product.fixture(defaultVariant: variant, variants: [variant])
        initViewModel(configuration: .product(product))

        XCTAssertTrue(sut.isAddToBagEnabled)
    }

    func test_isAddToBagEnabled_isTrueOnInit_forSizelessProduct_withStock() {
        // Product has no size dimension at all (e.g. a necklace).
        let color = Product.Colour.fixture(id: "1", name: "Color 1")
        let variant = Product.Variant.fixture(id: "v1", size: nil, colour: color, stock: 5)
        let product = Product.fixture(defaultVariant: variant, variants: [variant])
        initViewModel(configuration: .product(product))

        XCTAssertTrue(sut.isAddToBagEnabled)
    }

    func test_productHasAnyStock_isTrue_whenAtLeastOneVariantHasStock() {
        let color = Product.Colour.fixture(id: "1", name: "Color 1")
        let small = Product.Variant.fixture(size: .fixture(id: "s", value: "S"), colour: color, stock: 0)
        let medium = Product.Variant.fixture(size: .fixture(id: "m", value: "M"), colour: color, stock: 3)
        let product = Product.fixture(defaultVariant: small, variants: [small, medium])
        initViewModel(configuration: .product(product))

        XCTAssertTrue(sut.productHasAnyStock)
    }

    func test_productHasAnyStock_isFalse_whenEveryVariantIsOutOfStock() {
        let color = Product.Colour.fixture(id: "1", name: "Color 1")
        let small = Product.Variant.fixture(size: .fixture(id: "s", value: "S"), colour: color, stock: 0)
        let medium = Product.Variant.fixture(size: .fixture(id: "m", value: "M"), colour: color, stock: 0)
        let product = Product.fixture(defaultVariant: small, variants: [small, medium])
        initViewModel(configuration: .product(product))

        XCTAssertFalse(sut.productHasAnyStock)
    }

    func test_productHasAnyStock_isFalse_whenProductIsNotLoaded() {
        initViewModel()

        XCTAssertFalse(sut.productHasAnyStock)
    }

    func test_didTapAddToBag_isNoOp_whenSizeIsNotSelected_onMultiSizeProduct() {
        let color = Product.Colour.fixture(id: "1", name: "Color 1")
        let small = Product.Variant.fixture(id: "v1", size: .fixture(id: "s", value: "S"), colour: color, stock: 5)
        let medium = Product.Variant.fixture(id: "v2", size: .fixture(id: "m", value: "M"), colour: color, stock: 5)
        let product = Product.fixture(defaultVariant: small, variants: [small, medium])
        var addCallCount = 0
        mockCartService.onAddCalled = { _ in
            addCallCount += 1
            return .fixture()
        }
        initViewModel(configuration: .product(product))

        sut.didTapAddToBag()

        XCTAssertEqual(addCallCount, 0)
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
        initViewModel(configuration: .product(product))

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertEqual(sut.productDescription, product.longDescription)
    }

    func test_selected_colour_name_and_reference_come_from_the_selected_variant() {
        // "Cobalt Blue" deliberately differs from the colour fixture's "Black" default, so the
        // assertion fails if the value stops coming from this variant.
        let variant = Product.Variant.fixture(sku: "0273/393", colour: .fixture(name: "Cobalt Blue"))
        initViewModel(configuration: .product(.fixture(defaultVariant: variant, variants: [variant])))

        XCTAssertEqual(sut.selectedColourName, "Cobalt Blue")
        XCTAssertEqual(sut.productReference, "0273/393")
    }

    /// Single-option products carry a colour with an empty name purely to hold media, so the
    /// metadata line must drop the colour rather than render a blank segment.
    func test_selected_colour_name_is_nil_when_the_variant_colour_name_is_empty() {
        let variant = Product.Variant.fixture(sku: "0273/393", colour: .fixture(name: ""))
        initViewModel(configuration: .product(.fixture(defaultVariant: variant, variants: [variant])))

        XCTAssertNil(sut.selectedColourName)
        XCTAssertEqual(sut.productReference, "0273/393")
    }

    func test_selected_colour_name_and_reference_are_nil_if_no_product_was_fetched() {
        initViewModel()

        XCTAssertNil(sut.selectedColourName)
        XCTAssertNil(sut.productReference)
    }
    
    func test_price_type_is_nil_when_no_product_is_missing() {
        initViewModel()
        XCTAssertNil(sut.priceType)
    }
    
    func test_price_type_is_not_nil_with_sale_product() {
        initViewModel(configuration: .product(Product.blazer))
        guard case .sale(let fullPrice, let finalPrice) = sut.priceType else {
            XCTFail("Unexpected price type")
            return
        }
        XCTAssertEqual(fullPrice, "$495.00")
        XCTAssertEqual(finalPrice, "$299.00")
    }
    
    func test_price_type_is_not_nil_with_range_price_product() {
        initViewModel(configuration: .product(Product.hat))
        guard case .range(let lowerBound, let upperBound, let separator) = sut.priceType else {
            XCTFail("Unexpected price type")
            return
        }
        XCTAssertEqual(lowerBound, "$750.00")
        XCTAssertEqual(upperBound, "$850.00")
        XCTAssertEqual(separator, "-")
    }
    
    func test_price_type_is_not_nil_with_default_price_product() {
        initViewModel(configuration: .product(Product.necklace))
        guard case .default(let price) = sut.priceType else {
            XCTFail("Unexpected price type")
            return
        }
        XCTAssertEqual(price, "$279.00")
    }

    // MARK: - Product fetch

    func test_product_is_fetched_when_view_appears() {
        let productId = "1"
        initViewModel(configuration: .id(productId))

        let expectation = expectation(description: "Wait for service call")
        mockProductService.onGetProductCalled = { handle in
            XCTAssertEqual(handle, productId)
            expectation.fulfill()
            return .fixture()
        }

        sut.viewDidAppear()
        wait(for: [expectation], timeout: .default)
    }

    func test_product_entry_fetches_using_slug_as_handle() {
        let product = Product.fixture(slug: "nice-shirt-26146503")
        initViewModel(configuration: .product(product))

        let expectation = expectation(description: "Wait for service call")
        mockProductService.onGetProductCalled = { handle in
            XCTAssertEqual(handle, "nice-shirt-26146503")
            expectation.fulfill()
            return .fixture()
        }

        sut.viewDidAppear()
        wait(for: [expectation], timeout: .default)
    }

    func test_deep_link_entry_fetches_using_slug_handle() {
        initViewModel(configuration: .deepLink(handle: "nice-shirt-26146503"))

        let expectation = expectation(description: "Wait for service call")
        mockProductService.onGetProductCalled = { handle in
            XCTAssertEqual(handle, "nice-shirt-26146503")
            expectation.fulfill()
            return .fixture()
        }

        sut.viewDidAppear()
        wait(for: [expectation], timeout: .default)
    }

    func test_product_is_not_fetched_when_view_appears_if_already_fetched() {
        let productId = "1"
        initViewModel(configuration: .id(productId))

        let firstExpectation = expectation(description: "Wait for service call")
        let secondExpectation = expectation(description: "Wait for success state")
        mockProductService.onGetProductCalled = { handle in
            XCTAssertEqual(handle, productId)
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
        wait(for: [firstExpectation, secondExpectation], timeout: .default)

        let thirdExpectation = expectation(description: "Wait for no service call")
        thirdExpectation.isInverted = true
        mockProductService.onGetProductCalled = { _ in
            thirdExpectation.fulfill()
            return .fixture()
        }

        sut.viewDidAppear()
        wait(for: [thirdExpectation], timeout: .inverted)
        cancellable.cancel()
    }

    func test_state_is_success_after_product_fetch_succeeds() {
        initViewModel()

        mockProductService.onGetProductCalled = { _ in
            .fixture()
        }

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertTrue(sut.state.isSuccess)
    }

    func test_state_is_failure_after_product_fetch_fails() {
        initViewModel()

        mockProductService.onGetProductCalled = { _ in
            throw BFFRequestError(type: .generic)
        }

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertTrue(sut.state.didFail)
        XCTAssertEqual(sut.state.failure, .generic)
    }

    func test_state_is_failure_if_product_is_not_found_after_fetch() {
        initViewModel()

        mockProductService.onGetProductCalled = { _ in
            throw BFFRequestError(type: .emptyResponse)
        }

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

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

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertEqual(sut.variantSelection.selectedColour?.id, variant1.colour?.id)
        XCTAssertEqual(sut.variantSelection.selectedColour?.name, variant1.colour?.name)
        XCTAssertEqual(sut.variantSelection.selectedSize?.id, variant1.size?.id)
        XCTAssertEqual(sut.selectedColourName, variant1.colour?.name)
        XCTAssertEqual(sut.productReference, variant1.sku)
    }

    // MARK: - Loading state

    func test_state_is_loading_on_init() {
        initViewModel()
        XCTAssertTrue(sut.state.isLoading)
    }

    func test_state_is_loading_when_fetching_product() {
        initViewModel()

        let state = XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertEqual(state?.isLoading, true)
    }

    func test_reports_title_section_loading_when_loading_and_no_placeholder_available() {
        initViewModel()

        let result = sut.shouldShowLoading(for: .titleHeader)
        XCTAssertTrue(result)
    }

    func test_does_not_report_title_section_loading_when_placeholder_available() {
        let product = Product.fixture(name: "Product Name")
        initViewModel(configuration: .product(product))

        let result = sut.shouldShowLoading(for: .titleHeader)
        XCTAssertFalse(result)
    }

    func test_does_not_report_title_section_loading_when_not_loading() {
        initViewModel()

        mockProductService.onGetProductCalled = { _ in
            .fixture()
        }

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

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

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

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

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

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

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

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

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

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

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

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

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

        let colours = sut.variantSelection.colours
        XCTAssertEqual(colours.count, 1)
        XCTAssertEqual(colours.first?.id, color.id)
        XCTAssertEqual(colours.first?.name, color.name)
        switch colours.first?.type {
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

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertEqual(sut.variantSelection.colours.first?.type, .color(Theme.surfaceBackgroundInvertedPrimary))
    }

    /// `isDisabled` is the flag both colour surfaces key off — the card grid and the sheet row each
    /// refuse selection on it — so the stock-to-flag mapping is worth pinning on its own.
    func test_color_swatch_is_disabled_when_no_variant_in_that_colour_has_stock() {
        initViewModel()

        let inStock = Product.Colour.fixture(id: "1", name: "In Stock")
        let soldOut = Product.Colour.fixture(id: "2", name: "Sold Out")
        let product = Product.fixture(
            name: "Product Name",
            brand: .fixture(name: "Product Brand"),
            defaultVariant: .fixture(colour: inStock, stock: 3),
            variants: [
                .fixture(colour: inStock, stock: 3),
                .fixture(colour: soldOut, stock: 0),
            ]
        )
        mockProductService.onGetProductCalled = { _ in
            product
        }

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

        let items = sut.variantSelection.colours
        XCTAssertEqual(items.first { $0.id == inStock.id }?.isDisabled, false)
        XCTAssertEqual(items.first { $0.id == soldOut.id }?.isDisabled, true)
    }

    /// One colour out of stock in one size is still buyable in another, so the colour stays enabled.
    func test_color_swatch_stays_enabled_when_only_some_of_its_variants_are_out_of_stock() {
        initViewModel()

        let colour = Product.Colour.fixture(id: "1", name: "Colour 1")
        let product = Product.fixture(
            name: "Product Name",
            brand: .fixture(name: "Product Brand"),
            defaultVariant: .fixture(colour: colour, stock: 0),
            variants: [
                .fixture(colour: colour, stock: 0),
                .fixture(colour: colour, stock: 2),
            ]
        )
        mockProductService.onGetProductCalled = { _ in
            product
        }

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertEqual(sut.variantSelection.colours.first?.isDisabled, false)
    }

    func test_selection_follows_the_tapped_colour() {
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

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

        sut.didSelectColour(sut.variantSelection.colours[1])

        XCTAssertEqual(sut.variantSelection.selectedColour?.id, variant2.colour?.id)
        XCTAssertEqual(sut.selectedColourName, variant2.colour?.name)
        XCTAssertEqual(sut.productReference, variant2.sku)
    }

    func test_reselecting_the_current_colour_does_not_republish_the_selection() throws {
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

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

        let selected = try XCTUnwrap(sut.variantSelection.selectedColour)

        // `@Published` publishes on every set, so without the equality guard this redraws the whole
        // page for a tap that changed nothing.
        XCTAssertNoEmit(from: sut.$variantSelection, afterTrigger: {
            self.sut.didSelectColour(selected)
        })
    }

    /// Entering by `.product` seeds the grid from a stale snapshot, so the refetch behind it has to
    /// reach the swatches — otherwise a colour that sold out while the shopper was away stays drawn
    /// as available.
    func test_a_refetch_that_only_changes_stock_still_reaches_the_swatches() {
        let color1 = Product.Colour.fixture(id: "1", name: "Color 1")
        let color2 = Product.Colour.fixture(id: "2", name: "Color 2")
        let stale = Product.fixture(
            defaultVariant: .fixture(colour: color1, stock: 1),
            variants: [.fixture(colour: color1, stock: 1), .fixture(colour: color2, stock: 5)]
        )
        let fresh = Product.fixture(
            defaultVariant: .fixture(colour: color1, stock: 1),
            variants: [.fixture(colour: color1, stock: 1), .fixture(colour: color2, stock: 0)]
        )

        initViewModel(configuration: .product(stale))
        XCTAssertEqual(sut.variantSelection.colours.first { $0.id == color2.id }?.isDisabled, false)

        mockProductService.onGetProductCalled = { _ in fresh }
        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertEqual(sut.variantSelection.colours.first { $0.id == color2.id }?.isDisabled, true)
    }

    func test_selection_is_unchanged_if_an_unknown_colour_is_tapped() {
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

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

        sut.didSelectColour(ColorSwatch(id: "3", name: "Color 3", type: .color(.black)))

        XCTAssertEqual(sut.variantSelection.selectedColour?.id, color1.id)
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
        initViewModel(configuration: .product(product))

        mockProductService.onGetProductCalled = { _ in
            product
        }

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

        sut.didSelectColour(sut.variantSelection.colours[1])

        XCTAssertEqual(sut.productImageUrls.count, variant2.media.count)
        XCTAssertEqual(sut.productImageUrls[0].absoluteString, variant2.media[0].asImage?.url.absoluteString)
        XCTAssertEqual(sut.productImageUrls[1].absoluteString, variant2.media[1].asImage?.url.absoluteString)
    }

    func test_selected_colour_name_and_reference_are_updated_when_color_is_selected() {
        let variant1 = Product.Variant.fixture(sku: "SKU-1", colour: .fixture(id: "1", name: "Color 1"), stock: 1)
        let variant2 = Product.Variant.fixture(sku: "SKU-2", colour: .fixture(id: "2", name: "Color 2"), stock: 1)
        let product = Product.fixture(defaultVariant: variant1, variants: [variant1, variant2])
        initViewModel(configuration: .product(product))

        mockProductService.onGetProductCalled = { _ in
            product
        }

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertEqual(sut.selectedColourName, "Color 1")
        XCTAssertEqual(sut.productReference, "SKU-1")

        sut.didSelectColour(sut.variantSelection.colours[1])

        XCTAssertEqual(sut.selectedColourName, "Color 2")
        XCTAssertEqual(sut.productReference, "SKU-2")
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

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

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

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertFalse(sut.shouldShow(section: .mediaCarousel))
    }

    func test_reports_product_description_section_as_visible_if_description_available() {
        initViewModel()

        let product = Product.fixture(longDescription: "Product Description")
        mockProductService.onGetProductCalled = { _ in
            product
        }

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertTrue(sut.shouldShow(section: .productDescription))
    }

    func test_reports_product_description_section_as_not_visible_if_no_description_available() {
        initViewModel()

        let product = Product.fixture()
        mockProductService.onGetProductCalled = { _ in
            product
        }

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertFalse(sut.shouldShow(section: .productDescription))
    }

    func test_reports_add_to_bag_section_as_visible_if_state_is_success() {
        initViewModel()

        let product = Product.fixture()
        mockProductService.onGetProductCalled = { _ in
            product
        }

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertTrue(sut.shouldShow(section: .addToBag))
    }

    func test_reports_add_to_bag_section_as_not_visible_if_state_is_failure() {
        initViewModel()

        mockProductService.onGetProductCalled = { _ in
            throw BFFRequestError(type: .generic)
        }

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertFalse(sut.shouldShow(section: .addToBag))
    }

    func test_reports_add_to_bag_section_as_not_visible_if_state_is_loading() {
        initViewModel()

        XCTAssertFalse(sut.shouldShow(section: .addToBag))
    }

    // MARK: - Add to bag

    func test_didTapAddToBag_writesTheSelectedVariantToTheCart() {
        var written: CartLineInput?
        mockCartService.onAddCalled = { line in
            written = line
            return .fixture()
        }
        initViewModel(configuration: .product(addableProduct()))

        XCTAssertEmitsValue(from: sut.$addToBagFeedback.compactMap { $0 }, afterTrigger: { self.sut.didTapAddToBag() })

        XCTAssertEqual(written?.productId, "product-1")
        XCTAssertEqual(written?.variantId, "variant-1")
        XCTAssertEqual(written?.quantity, 1)
    }

    func test_didTapAddToBag_isInFlightForTheDurationOfTheWrite() {
        mockCartService.onAddCalled = { _ in .fixture() }
        initViewModel(configuration: .product(addableProduct()))

        sut.didTapAddToBag()

        // Set on the tap itself, not once the request lands — otherwise the CTA sits idle for the
        // whole round trip, which is the feedback gap this ticket exists to close.
        XCTAssertTrue(sut.isAddingToBag)
        XCTAssertEmitsValueEqualTo(from: sut.$isAddingToBag, expectedValue: false)
    }

    func test_didTapAddToBag_twiceInARow_producesOneRequest() {
        var addCallCount = 0
        mockCartService.onAddCalled = { _ in
            addCallCount += 1
            return .fixture()
        }
        initViewModel(configuration: .product(addableProduct()))

        sut.didTapAddToBag()
        sut.didTapAddToBag()
        XCTAssertEmitsValueEqualTo(from: sut.$isAddingToBag, expectedValue: false)

        XCTAssertEqual(addCallCount, 1)
    }

    func test_didTapAddToBag_thatSucceeds_reportsSuccessAndTracksTheEvent() {
        mockCartService.onAddCalled = { _ in .fixture() }
        initViewModel(configuration: .product(addableProduct()))

        XCTAssertEmitsValue(from: sut.$addToBagFeedback.compactMap { $0 }, afterTrigger: { self.sut.didTapAddToBag() })

        XCTAssertEqual(sut.addToBagFeedback, .success)
        XCTAssertEqual(mockAnalytics.trackedActions, [.addToBag])
    }

    func test_didTapAddToBag_thatFails_reportsFailureAndTracksNothing() {
        // Writes can fail now, so firing on intent would inflate add-to-bag against real carts.
        mockCartService.onAddCalled = { _ in throw BFFRequestError(type: .generic) }
        initViewModel(configuration: .product(addableProduct()))

        XCTAssertEmitsValue(from: sut.$addToBagFeedback.compactMap { $0 }, afterTrigger: { self.sut.didTapAddToBag() })

        XCTAssertEqual(sut.addToBagFeedback, .failure)
        XCTAssertTrue(mockAnalytics.trackedActions.isEmpty)
    }

    func test_didTapAddToBag_doesNotNavigateAway_onSuccessOrFailure() {
        mockCartService.onAddCalled = { _ in .fixture() }
        var didGoBack = false
        sut = .init(
            configuration: .product(addableProduct()),
            dependencies: mockDependencies,
            goBackAction: { didGoBack = true },
            openWebfeatureAction: { _ in },
            openProductAction: { _ in }
        )

        XCTAssertEmitsValue(from: sut.$addToBagFeedback.compactMap { $0 }, afterTrigger: { self.sut.didTapAddToBag() })

        XCTAssertFalse(didGoBack)
    }

    func test_didDismissAddToBagFeedback_clearsIt_soAnIdenticalOutcomeRepresents() {
        mockCartService.onAddCalled = { _ in .fixture() }
        initViewModel(configuration: .product(addableProduct()))
        XCTAssertEmitsValue(from: sut.$addToBagFeedback.compactMap { $0 }, afterTrigger: { self.sut.didTapAddToBag() })

        sut.didDismissAddToBagFeedback()

        XCTAssertNil(sut.addToBagFeedback)
    }

    func test_didTapAddToBag_clearsThePreviousOutcomeBeforeWriting_soASecondIdenticalOneReRegisters() {
        // The View presents on a *change* of feedback, so a second success with the first still
        // showing would present nothing without this.
        mockCartService.onAddCalled = { _ in .fixture() }
        initViewModel(configuration: .product(addableProduct()))
        XCTAssertEmitsValue(from: sut.$addToBagFeedback.compactMap { $0 }, afterTrigger: { self.sut.didTapAddToBag() })
        XCTAssertEqual(sut.addToBagFeedback, .success)

        var emitted: [AddToBagFeedback?] = []
        let cancellable = sut.$addToBagFeedback.sink { emitted.append($0) }
        defer { cancellable.cancel() }
        XCTAssertEmitsValue(from: sut.$isAddingToBag.filter { !$0 }, afterTrigger: { self.sut.didTapAddToBag() })

        // .success -> nil -> .success, so the View sees a change rather than a repeat.
        XCTAssertEqual(emitted, [.success, nil, .success])
    }

    func test_isAddToBagEnabled_isFalse_whenTheVariantHasNoServerId() {
        // A variant synthesised locally has no server counterpart, so there is nothing to add.
        let variant = Product.Variant.fixture(id: nil, colour: .fixture(id: "1"), stock: 5)
        let product = Product.fixture(defaultVariant: variant, variants: [variant])
        initViewModel(configuration: .product(product))

        XCTAssertFalse(sut.isAddToBagEnabled)
    }

    func test_didTapAddToBag_makesNoRequest_whenTheVariantHasNoServerId() {
        var addCallCount = 0
        mockCartService.onAddCalled = { _ in
            addCallCount += 1
            return .fixture()
        }
        let variant = Product.Variant.fixture(id: nil, colour: .fixture(id: "1"), stock: 5)
        let product = Product.fixture(defaultVariant: variant, variants: [variant])
        initViewModel(configuration: .product(product))

        sut.didTapAddToBag()

        XCTAssertEqual(addCallCount, 0)
        XCTAssertFalse(sut.isAddingToBag)
    }

    /// A single-size, in-stock product whose variant carries a server id — the shape for which
    /// add-to-bag is enabled on entry, with no swatch tapping needed first.
    private func addableProduct() -> Product {
        let variant = Product.Variant.fixture(
            id: "variant-1",
            size: .fixture(id: "s", value: "S"),
            colour: .fixture(id: "1", name: "Color 1"),
            stock: 5
        )
        return Product.fixture(id: "product-1", defaultVariant: variant, variants: [variant])
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

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

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

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

        let shareConfiguration = sut.shareConfiguration
        XCTAssertNotNil(shareConfiguration)
        XCTAssertEqual(shareConfiguration?.url.absoluteString, urlString)
        XCTAssertEqual(shareConfiguration?.message, "\nProduct Brand\nProduct Name\n999$\n")
        XCTAssertEqual(shareConfiguration?.subject, "Product Name from Alfie")
    }

    // MARK: - Related products

    func test_view_did_appear_requests_related_products_for_product_handle_with_one_extra_slot() {
        initViewModel(configuration: .product(.fixture(slug: "nice-shirt")))
        mockProductService.onGetProductCalled = { _ in .fixture() }
        var capturedRequests: [(handle: String, limit: Int)] = []
        let requested = expectation(description: "Related products are requested")
        mockProductService.onRelatedProductsCalled = { handle, limit in
            capturedRequests.append((handle, limit))
            requested.fulfill()
            return []
        }

        sut.viewDidAppear()
        wait(for: [requested], timeout: .default)

        XCTAssertEqual(capturedRequests.map { $0.handle }, ["nice-shirt"])
        XCTAssertEqual(capturedRequests.map { $0.limit }, [7])
    }

    func test_view_did_appear_requests_related_products_when_product_fetch_fails() {
        initViewModel(configuration: .deepLink(handle: "nice-shirt"))
        mockProductService.onGetProductCalled = { _ in throw BFFRequestError(type: .generic) }
        let requested = expectation(description: "Related products are requested")
        mockProductService.onRelatedProductsCalled = { _, _ in
            requested.fulfill()
            return []
        }

        sut.viewDidAppear()

        wait(for: [requested], timeout: .default)
    }

    func test_related_products_exclude_current_product_and_keep_the_first_six() {
        initViewModel(configuration: .product(.fixture(id: "current", slug: "current-slug")))
        mockProductService.onGetProductCalled = { _ in .fixture(id: "current", slug: "current-slug") }
        mockProductService.onRelatedProductsCalled = { _, _ in
            [.fixture(id: "current", slug: "current-slug")] + (1...7).map { .fixture(id: "\($0)", slug: "slug-\($0)") }
        }

        appearAndWaitForBothRequests()

        XCTAssertEqual(sut.relatedProducts.map(\.id), ["1", "2", "3", "4", "5", "6"])
    }

    func test_related_products_exclude_current_product_when_only_its_id_matches() {
        initViewModel(configuration: .product(.fixture(id: "current", slug: "current-slug")))
        mockProductService.onGetProductCalled = { _ in .fixture(id: "current", slug: "current-slug") }
        mockProductService.onRelatedProductsCalled = { _, _ in
            [.fixture(id: "current", slug: "other-slug"), .fixture(id: "1", slug: "slug-1")]
        }

        appearAndWaitForBothRequests()

        XCTAssertEqual(sut.relatedProducts.map(\.id), ["1"])
    }

    func test_related_products_skeleton_is_hidden_while_product_is_loading() {
        initViewModel()

        let showsSkeleton = sut.shouldShowLoading(for: .relatedProducts)

        XCTAssertTrue(sut.state.isLoading)
        XCTAssertTrue(sut.relatedProductsState.isLoading)
        XCTAssertFalse(showsSkeleton)
    }

    func test_related_products_section_is_shown_without_skeleton_when_product_and_related_products_loaded() {
        initViewModel()
        mockProductService.onGetProductCalled = { _ in .fixture() }
        mockProductService.onRelatedProductsCalled = { _, _ in [.fixture(slug: "other")] }

        appearAndWaitForBothRequests()

        XCTAssertTrue(sut.shouldShow(section: .relatedProducts))
        XCTAssertFalse(sut.shouldShowLoading(for: .relatedProducts))
    }

    func test_related_products_skeleton_is_shown_when_product_loads_before_related_products() async {
        initViewModel()
        mockProductService.onGetProductCalled = { _ in .fixture() }
        let gate = RelatedProductsGate()
        let relatedRequested = expectation(description: "Related products are requested")
        mockProductService.onRelatedProductsCalled = { _, _ in
            await gate.hold(signal: relatedRequested)
            return []
        }

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })
        await fulfillment(of: [relatedRequested], timeout: .default)

        XCTAssertTrue(sut.relatedProductsState.isLoading)
        XCTAssertTrue(sut.shouldShow(section: .relatedProducts))
        XCTAssertTrue(sut.shouldShowLoading(for: .relatedProducts))
        await gate.open()
    }

    func test_related_products_section_is_hidden_when_product_fails_even_if_related_products_loaded() {
        initViewModel()
        mockProductService.onGetProductCalled = { _ in throw BFFRequestError(type: .generic) }
        mockProductService.onRelatedProductsCalled = { _, _ in [.fixture(slug: "other")] }

        appearAndWaitForBothRequests()

        XCTAssertTrue(sut.relatedProductsState.isSuccess)
        XCTAssertFalse(sut.shouldShow(section: .relatedProducts))
        XCTAssertFalse(sut.shouldShowLoading(for: .relatedProducts))
    }

    func test_related_products_section_is_hidden_when_related_products_are_empty() {
        initViewModel()
        mockProductService.onGetProductCalled = { _ in .fixture() }
        mockProductService.onRelatedProductsCalled = { _, _ in [] }

        appearAndWaitForBothRequests()

        XCTAssertFalse(sut.shouldShow(section: .relatedProducts))
    }

    func test_related_products_section_is_hidden_when_related_products_fail() {
        initViewModel()
        mockProductService.onGetProductCalled = { _ in .fixture() }
        mockProductService.onRelatedProductsCalled = { _, _ in throw BFFRequestError(type: .generic) }

        appearAndWaitForBothRequests()

        XCTAssertTrue(sut.relatedProductsState.didFail)
        XCTAssertTrue(sut.state.isSuccess)
        XCTAssertFalse(sut.shouldShow(section: .relatedProducts))
    }

    func test_view_reappearing_after_related_products_success_does_not_refetch_them() {
        arrangeAppearedScreen(relatedProductsResponse: { _, _ in [.fixture(slug: "other")] })
        let relatedRefetch = expectRelatedProductsNotRequested()

        sut.viewDidAppear()

        wait(for: [relatedRefetch], timeout: .inverted)
    }

    func test_view_reappearing_after_empty_related_products_does_not_refetch_them() {
        arrangeAppearedScreen(relatedProductsResponse: { _, _ in [] })
        let relatedRefetch = expectRelatedProductsNotRequested()

        sut.viewDidAppear()

        wait(for: [relatedRefetch], timeout: .inverted)
    }

    func test_view_reappearing_after_related_products_failure_does_not_refetch_them() {
        arrangeAppearedScreen(relatedProductsResponse: { _, _ in throw BFFRequestError(type: .generic) })
        let relatedRefetch = expectRelatedProductsNotRequested()

        sut.viewDidAppear()

        wait(for: [relatedRefetch], timeout: .inverted)
    }

    func test_view_reappearing_after_product_failure_refetches_only_the_product() {
        arrangeAppearedScreen(
            productResponse: { _ in throw BFFRequestError(type: .generic) },
            relatedProductsResponse: { _, _ in [.fixture(slug: "other")] }
        )
        let productRefetch = expectation(description: "Product is refetched")
        mockProductService.onGetProductCalled = { _ in
            productRefetch.fulfill()
            return .fixture()
        }
        let relatedRefetch = expectRelatedProductsNotRequested()

        sut.viewDidAppear()

        wait(for: [productRefetch], timeout: .default)
        wait(for: [relatedRefetch], timeout: .inverted)
    }

    func test_did_select_related_product_opens_that_product() {
        var openedProducts: [Product] = []
        initViewModel(openProductAction: { openedProducts.append($0) })

        sut.didSelectRelatedProduct(.fixture(id: "related"))

        XCTAssertEqual(openedProducts.map(\.id), ["related"])
    }

    func test_did_tap_wishlist_on_related_product_not_in_wishlist_adds_it() {
        initViewModel()
        let related = Product.fixture(id: "related")

        XCTAssertEmitsValue(
            from: sut.$wishlistContent,
            where: { $0.map(\.product.id) == ["related"] },
            afterTrigger: { self.sut.didTapWishlist(for: related, isFavorite: false) }
        )

        XCTAssertTrue(sut.isFavoriteState(for: related))
        XCTAssertEqual(mockAnalytics.trackedActions, [.addToWishlist])
    }

    func test_did_tap_wishlist_on_related_product_in_wishlist_removes_it() {
        let related = Product.fixture(id: "related")
        mockDependencies = makeDependencies(wishlistService: MockWishlistService(products: [SelectedProduct(product: related)]))
        initViewModel()
        XCTAssertEmitsValue(from: sut.$wishlistContent, where: { !$0.isEmpty }, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertEmitsValue(
            from: sut.$wishlistContent.dropFirst(),
            where: { $0.isEmpty },
            afterTrigger: { self.sut.didTapWishlist(for: related, isFavorite: true) }
        )

        XCTAssertFalse(sut.isFavoriteState(for: related))
        XCTAssertEqual(mockAnalytics.trackedActions, [.removeFromWishlist])
    }

    func test_view_did_appear_marks_related_products_already_in_wishlist_as_favourite() {
        let related = Product.fixture(id: "related")
        mockDependencies = makeDependencies(wishlistService: MockWishlistService(products: [SelectedProduct(product: related)]))
        initViewModel()

        XCTAssertEmitsValue(from: sut.$wishlistContent, where: { !$0.isEmpty }, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertTrue(sut.isFavoriteState(for: related))
    }

    // MARK: - Helper methods

    /// Two sizes in one colour: the shape where a size choice is genuinely open, so "no size is
    /// pre-selected" means something. A single size is auto-selected by design.
    private func twoSizeVariants(colour: Product.Colour, stock: Int = 5) -> [Product.Variant] {
        [
            .fixture(id: "v-s", sku: "v-s", size: .fixture(id: "s", value: "S"), colour: colour, stock: stock),
            .fixture(id: "v-m", sku: "v-m", size: .fixture(id: "m", value: "M"), colour: colour, stock: stock),
        ]
    }

    private func makeDependencies(wishlistService: MockWishlistService) -> ProductDetailsDependencyContainer {
        ProductDetailsDependencyContainer(
            productService: mockProductService,
            webUrlProvider: mockWebUrlProvider,
            cartService: mockCartService,
            wishlistService: wishlistService,
            configurationService: MockConfigurationService(),
            analytics: mockAnalytics.eraseToAnyAnalyticsTracker(),
            log: Log.DummyLogger()
        )
    }

    private func initViewModel(
        configuration: ProductDetailsConfiguration = .id(""),
        openProductAction: @escaping (Product) -> Void = { _ in }
    ) {
        sut = .init(
            configuration: configuration,
            dependencies: mockDependencies,
            goBackAction: {},
            openWebfeatureAction: { _ in },
            openProductAction: openProductAction
        )
    }

    private func appearAndWaitForBothRequests() {
        XCTAssertEmitsValue(
            from: sut.$state.combineLatest(sut.$relatedProductsState),
            where: { !$0.isLoading && !$1.isLoading },
            afterTrigger: { self.sut.viewDidAppear() }
        )
    }

    private func arrangeAppearedScreen(
        productResponse: @escaping (String) throws -> Product = { _ in .fixture() },
        relatedProductsResponse: @escaping (String, Int) async throws -> [Product]
    ) {
        initViewModel()
        mockProductService.onGetProductCalled = productResponse
        mockProductService.onRelatedProductsCalled = relatedProductsResponse
        appearAndWaitForBothRequests()
    }

    private func expectRelatedProductsNotRequested() -> XCTestExpectation {
        let relatedRequested = expectation(description: "Related products are not requested")
        relatedRequested.isInverted = true
        mockProductService.onRelatedProductsCalled = { _, _ in
            relatedRequested.fulfill()
            return []
        }
        return relatedRequested
    }
}

private actor RelatedProductsGate {
    private var continuation: CheckedContinuation<Void, Never>?
    private var opened = false

    func hold(signal: XCTestExpectation) async {
        signal.fulfill()
        guard !opened else { return }
        await withCheckedContinuation { continuation = $0 }
    }

    func open() {
        opened = true
        continuation?.resume()
        continuation = nil
    }
}
