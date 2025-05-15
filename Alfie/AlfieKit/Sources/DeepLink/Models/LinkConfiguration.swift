import Model

public struct LinkConfiguration: LinkConfigurationProtocol {
    public let schemes: [String]
    public let hosts: [String]

    public init(
        schemes: [String] = ["https", "http", "alfie"],
        hosts: [String] = [
            ThemedURL.preferredHost,
            ThemedURL.internalHost,
        ]
    ) {
        self.schemes = schemes
        self.hosts = hosts
    }
}
