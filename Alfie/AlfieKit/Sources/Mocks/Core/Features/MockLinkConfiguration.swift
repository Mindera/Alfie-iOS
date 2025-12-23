import Model

public struct MockLinkConfiguration: LinkConfigurationProtocol {
    public let schemes: [String]
    public let hosts: [String]

    public init(schemes: [String] = ["https", "http", "mock"],
         hosts: [String] = [
            "mock.com",
            "www.mock.com",
         ]) {
             self.schemes = schemes
             self.hosts = hosts
    }
}
