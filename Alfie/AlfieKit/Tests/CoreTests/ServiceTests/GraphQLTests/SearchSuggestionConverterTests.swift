import XCTest
import ApolloTestSupport
import BFFGraphApi
import BFFGraphMocks

final class SearchSuggestionConverterTests: XCTestCase {
    func test_search_suggestion_valid() {
        let mockBrand1: Mock<SuggestionBrand> = .init(results: 11, slug: "slug-1", value: "Brand 1")
        let mockBrand2: Mock<SuggestionBrand> = .init(results: 22, slug: "slug-2", value: "Brand 2")

        let mockKeyword1: Mock<SuggestionKeyword> = .init(results: 33, value: "Keyword 1")
        let mockKeyword2: Mock<SuggestionKeyword> = .init(results: 44, value: "Keyword 2")

        let mockPrice: Mock<Price> = .mock(amount: .mock(currencyCode: "AUD",
                                                         amount: 10,
                                                         amountFormatted: "$10.00"),
                                           was: .mock(currencyCode: "AUD",
                                                      amount: 20,
                                                      amountFormatted: "$20.00"))
        let mockMedia: Mock<Image> = .mock(alt: "alt",
                                           url: "http://some.url")
        let mockProduct: Mock<SuggestionProduct> = .init(brandName: "Product Brand",
                                                         id: "55",
                                                         media: [mockMedia],
                                                         name: "Product Name",
                                                         price: mockPrice,
                                                         slug: "Product Slug")

        let mockSearchSuggestion: Mock<Suggestion> = .init(brands: [mockBrand1, mockBrand2],
                                                           keywords: [mockKeyword1, mockKeyword2],
                                                           products: [mockProduct])

        let response = BFFGraphApi.GetSuggestionsQuery.Data.Suggestion.from(mockSearchSuggestion)
        let searchSuggestion = response.convertToSearchSuggestion()

        XCTAssertEqual(searchSuggestion.brands.count, 2)
        XCTAssertEqual(searchSuggestion.brands[0].name, "Brand 1")
        XCTAssertEqual(searchSuggestion.brands[0].slug, "slug-1")
        XCTAssertEqual(searchSuggestion.brands[0].resultCount, 11)
        XCTAssertEqual(searchSuggestion.brands[1].name, "Brand 2")
        XCTAssertEqual(searchSuggestion.brands[1].slug, "slug-2")
        XCTAssertEqual(searchSuggestion.brands[1].resultCount, 22)

        XCTAssertEqual(searchSuggestion.keywords.count, 2)
        XCTAssertEqual(searchSuggestion.keywords[0].term, "Keyword 1")
        XCTAssertEqual(searchSuggestion.keywords[0].resultCount, 33)
        XCTAssertEqual(searchSuggestion.keywords[1].term, "Keyword 2")
        XCTAssertEqual(searchSuggestion.keywords[1].resultCount, 44)

        XCTAssertEqual(searchSuggestion.products.count, 1)
        XCTAssertEqual(searchSuggestion.products[0].id, "55")
        XCTAssertEqual(searchSuggestion.products[0].brandName, "Product Brand")
        XCTAssertEqual(searchSuggestion.products[0].name, "Product Name")
        XCTAssertEqual(searchSuggestion.products[0].slug, "Product Slug")
        XCTAssertEqual(searchSuggestion.products[0].price.amount.currencyCode, "AUD")
        XCTAssertEqual(searchSuggestion.products[0].price.amount.amount, 10)
        XCTAssertEqual(searchSuggestion.products[0].price.amount.amountFormatted, "$10.00")
        XCTAssertEqual(searchSuggestion.products[0].price.was?.currencyCode, "AUD")
        XCTAssertEqual(searchSuggestion.products[0].price.was?.amount, 20)
        XCTAssertEqual(searchSuggestion.products[0].price.was?.amountFormatted, "$20.00")
        XCTAssertEqual(searchSuggestion.products[0].media.count, 1)
        XCTAssertEqual(searchSuggestion.products[0].media[0].asImage?.alt, "alt")
        XCTAssertEqual(searchSuggestion.products[0].media[0].asImage?.url.absoluteString, "http://some.url")
    }
}
