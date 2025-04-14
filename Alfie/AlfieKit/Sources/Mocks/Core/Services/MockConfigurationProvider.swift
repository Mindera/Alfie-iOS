import Combine
import Foundation
import Model

public class MockConfigurationProvider: ConfigurationProviderProtocol {
    public let isReadySubject: CurrentValueSubject<Bool, Never> = .init(true)
    public var isReady: Bool { isReadySubject.value }
    public var isReadyPublisher: AnyPublisher<Bool, Never> { isReadySubject.eraseToAnyPublisher() }
    public let configurationUpdatedSubject: PassthroughSubject<Void, Never> = .init()
    public var configurationUpdatedPublisher: AnyPublisher<Void, Never> {
        configurationUpdatedSubject.eraseToAnyPublisher()
    }

    public var onBoolCalled: ((ConfigurationKey) -> Bool?)?
    public func bool(for key: ConfigurationKey) -> Bool? {
        onBoolCalled?(key)
    }

    public var onDataCalled: ((ConfigurationKey) -> Data?)?
    public func data(for key: ConfigurationKey) -> Data? {
        onDataCalled?(key)
    }

    public var onDoubleCalled: ((ConfigurationKey) -> Double?)?
    public func double(for key: ConfigurationKey) -> Double? {
        onDoubleCalled?(key)
    }

    public var onIntCalled: ((ConfigurationKey) -> Int?)?
    public func int(for key: ConfigurationKey) -> Int? {
        onIntCalled?(key)
    }

    public var onStringCalled: ((ConfigurationKey) -> String?)?
    public func string(for key: ConfigurationKey) -> String? {
        onStringCalled?(key)
    }

    public init() { }
}
