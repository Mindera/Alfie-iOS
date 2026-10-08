import Foundation
import Model

public class MockBFFApiKeyService: BFFApiKeyServiceProtocol {
    public var currentApiKey: String?
    public var storedApiKey: String?

    public var onUpdateApiKeyCalled: ((String?) -> Void)?
    public func updateApiKey(_ apiKey: String?) {
        storedApiKey = apiKey
        onUpdateApiKeyCalled?(apiKey)
    }

    public init(
        currentApiKey: String? = nil,
        storedApiKey: String? = nil,
        onUpdateApiKeyCalled: ((String?) -> Void)? = nil
    ) {
        self.currentApiKey = currentApiKey
        self.storedApiKey = storedApiKey
        self.onUpdateApiKeyCalled = onUpdateApiKeyCalled
    }
}
