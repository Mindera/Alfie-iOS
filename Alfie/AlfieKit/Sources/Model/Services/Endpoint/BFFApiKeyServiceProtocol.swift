public protocol BFFApiKeyServiceProtocol {
    var currentApiKey: String? { get }

    func updateApiKey(_ apiKey: String?)
}
