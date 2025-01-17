import XCTest
import Models

final class WebViewConfigurationTests: XCTestCase {
    private static let sampleJson = """
    {
      "shopping": {
        "bag": "https://bag.url",
        "checkout": "https://checkout.url",
        "returnOptions": "https://returns.url",
        "paymentOptions": "https://payment.url",
        "storeServices": "https://services.url",
      },
      "gift": {
        "ideas": "https://giftideas.url",
        "wrapping": "https://giftwrapping.url",
        "cards": "https://giftcards.url",
      },
      "account": {
        "profile": "https://profile.url",
        "orders": "https://orders.url",
        "benefits": "https://benefits.url",
        "wallet": "https://wallet.url",
        "addresses": "https://addresses.url",
        "preferences": "https://preferences.url",
      }
    }
    """

    func test_configuration_is_decoded_from_json() throws {
        let data = Self.sampleJson.data(using: .utf8)!
        let configuration = try JSONDecoder().decode(WebViewConfiguration.self, from: data)

        XCTAssertEqual(configuration.url(for: .bag)?.absoluteString, "https://bag.url")
        XCTAssertEqual(configuration.url(for: .checkout)?.absoluteString, "https://checkout.url")
        XCTAssertEqual(configuration.url(for: .returnOptions)?.absoluteString, "https://returns.url")
        XCTAssertEqual(configuration.url(for: .paymentOptions)?.absoluteString, "https://payment.url")
        XCTAssertEqual(configuration.url(for: .storeServices)?.absoluteString, "https://services.url")

        XCTAssertEqual(configuration.url(for: .profile)?.absoluteString, "https://profile.url")
        XCTAssertEqual(configuration.url(for: .orders)?.absoluteString, "https://orders.url")
        XCTAssertEqual(configuration.url(for: .benefits)?.absoluteString, "https://benefits.url")
        XCTAssertEqual(configuration.url(for: .wallet)?.absoluteString, "https://wallet.url")
        XCTAssertEqual(configuration.url(for: .addresses)?.absoluteString, "https://addresses.url")
        XCTAssertEqual(configuration.url(for: .preferences)?.absoluteString, "https://preferences.url")
    }
}
