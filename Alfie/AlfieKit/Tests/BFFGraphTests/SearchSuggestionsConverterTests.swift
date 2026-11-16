import ApolloTestSupport
@testable import BFFGraph
import Core
import Model
import XCTest

final class SearchSuggestionsConverterTests: XCTestCase {
    func test_suggestion_converts_its_three_kinds() {
        let suggestion = Mock<Suggestion>(
            brands: [Mock<SuggestionBrand>(key: "acme-key", value: "Acme")],
            keywords: [Mock<SuggestionKeyword>(value: "linen shirt")],
            products: [
                Mock<SuggestionProduct>(
                    brandName: "Acme",
                    id: "prod-1",
                    images: [
                        Mock<Image>(altText: "Front", url: "https://cdn.alfie.test/front.jpg"),
                        Mock<Image>(altText: "Back", url: "https://cdn.alfie.test/back.jpg")
                    ],
                    name: "Oxford Shirt",
                    price: Mock<BFFGraph.Money>(amount: 19.99, currencyCode: "GBP"),
                    slug: "oxford-shirt"
                )
            ]
        )

        let suggestions = convert(suggestion)

        XCTAssertEqual(suggestions.keywords, [KeywordSuggestion(value: "linen shirt")])
        XCTAssertEqual(suggestions.brands, [BrandSuggestion(key: "acme-key", name: "Acme")])
        XCTAssertEqual(suggestions.products.count, 1)
        let product = suggestions.products.first
        XCTAssertEqual(product?.id, "prod-1")
        XCTAssertEqual(product?.name, "Oxford Shirt")
        XCTAssertEqual(product?.brandName, "Acme")
        XCTAssertEqual(product?.handle, "oxford-shirt")
        XCTAssertEqual(product?.price?.amount, 1999)
        XCTAssertEqual(product?.price?.currencyCode, "GBP")
        XCTAssertEqual(product?.imageURL?.absoluteString, "https://cdn.alfie.test/front.jpg")
    }

    func test_product_suggestion_without_price_has_no_price() {
        let suggestions = convert(makeSuggestion(product: makeProduct(price: nil)))

        XCTAssertEqual(suggestions.products.count, 1)
        XCTAssertNil(suggestions.products.first?.price)
    }

    func test_product_suggestion_without_brand_has_no_brand_name() {
        let suggestions = convert(makeSuggestion(product: makeProduct(brandName: nil)))

        XCTAssertEqual(suggestions.products.count, 1)
        XCTAssertNil(suggestions.products.first?.brandName)
    }

    func test_product_suggestion_without_images_has_no_image() {
        let suggestions = convert(makeSuggestion(product: makeProduct(images: [])))

        XCTAssertEqual(suggestions.products.count, 1)
        XCTAssertNil(suggestions.products.first?.imageURL)
    }

    func test_suggestion_with_no_kinds_converts_to_empty_lists() {
        let suggestions = convert(Mock<Suggestion>(brands: [], keywords: [], products: []))

        XCTAssertEqual(suggestions, SearchSuggestions(keywords: [], brands: [], products: []))
    }

    // MARK: - Helpers

    private func convert(_ suggestion: Mock<Suggestion>) -> SearchSuggestions {
        BFFGraphAPI.SuggestionFragment.from(suggestion).convertToSearchSuggestions()
    }

    private func makeSuggestion(product: Mock<SuggestionProduct>) -> Mock<Suggestion> {
        Mock<Suggestion>(brands: [], keywords: [], products: [product])
    }

    private func makeProduct(
        brandName: String? = "Acme",
        images: [Mock<Image>] = [Mock<Image>(altText: nil, url: "https://cdn.alfie.test/front.jpg")],
        price: Mock<BFFGraph.Money>? = Mock<BFFGraph.Money>(amount: 19.99, currencyCode: "GBP")
    ) -> Mock<SuggestionProduct> {
        Mock<SuggestionProduct>(
            brandName: brandName,
            id: "prod-1",
            images: images,
            name: "Oxford Shirt",
            price: price,
            slug: "oxford-shirt"
        )
    }
}
