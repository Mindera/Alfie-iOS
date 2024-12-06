import Foundation

public protocol BagDependencyContainerProtocol {
    var bagService: BagServiceProtocol { get }
    var configurationService: ConfigurationServiceProtocol { get }
}
