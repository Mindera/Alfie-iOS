public protocol BffApiKeyServiceProtocol {
    var currentApiKey: String? { get }

    func updateApiKey(_ apiKey: String?)
}
