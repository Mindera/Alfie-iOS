import Foundation

public struct WebViewConfiguration: Decodable {
    private enum CodingKeys: String, CodingKey {
        case shopping
        case account
    }

    private let configuration: [WebFeature: URL]

    public init(configuration: [WebFeature: URL]) {
        self.configuration = configuration
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var config = [WebFeature: URL]()

        let shoppingLinks = try container.decode(Dictionary<String, String>.self, forKey: .shopping)
        let accountLinks = try container.decode(Dictionary<String, String>.self, forKey: .account)

        WebFeature.allCases.forEach { feature in
            guard
                let value = shoppingLinks[feature.rawValue] ?? accountLinks[feature.rawValue],
                let url = URL(string: value)
            else {
                return
            }
            config[feature] = url
        }

        configuration = config
    }

    public func url(for feature: WebFeature) -> URL? {
        configuration[feature]
    }
}
