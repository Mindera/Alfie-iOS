import Models

struct LinkConfiguration: LinkConfigurationProtocol {
    let schemes: [String]
    let hosts: [String]

    init(
        schemes: [String] = ["https", "http", "alfie"],
        hosts: [String] = [
            "localhost:4000",
            "alfie.target",
        ]
    ) {
        self.schemes = schemes
        self.hosts = hosts
    }
}
