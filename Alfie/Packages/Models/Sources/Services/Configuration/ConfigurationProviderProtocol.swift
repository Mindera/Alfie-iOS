import Combine
import Foundation

public protocol ConfigurationProviderProtocol {
    var isReady: Bool { get }
    var isReadyPublisher: AnyPublisher<Bool, Never> { get }

    func bool(for key: ConfigurationKey) -> Bool?
    func data(for key: ConfigurationKey) -> Data?
    func double(for key: ConfigurationKey) -> Double?
    func int(for key: ConfigurationKey) -> Int?
    func string(for key: ConfigurationKey) -> String?
}
