import Models

struct LinkConfiguration: LinkConfigurationProtocol {
    let schemes: [String]
    let hosts: [String]

    init(
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
