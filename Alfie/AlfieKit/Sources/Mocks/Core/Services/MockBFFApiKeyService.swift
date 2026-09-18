import Foundation
import Model

public class MockBFFApiKeyService: BFFApiKeyServiceProtocol {
    public var currentApiKey: String?

    public var onUpdateApiKeyCalled: ((String?) -> Void)?
    public func updateApiKey(_ apiKey: String?) {
        currentApiKey = apiKey
        onUpdateApiKeyCalled?(apiKey)
    }

    public init(currentApiKey: String? = nil, onUpdateApiKeyCalled: ((String?) -> Void)? = nil) {
        self.currentApiKey = currentApiKey
        self.onUpdateApiKeyCalled = onUpdateApiKeyCalled
    }
}
