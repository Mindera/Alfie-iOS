public protocol BFFApiKeyServiceProtocol {
    var currentApiKey: String? { get }
    var storedApiKey: String? { get }

    func updateApiKey(_ apiKey: String?)
}
