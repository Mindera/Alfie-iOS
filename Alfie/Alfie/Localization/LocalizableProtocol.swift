import Foundation

protocol LocalizableKeyProtocol: RawRepresentable, CaseIterable { }

protocol LocalizableProtocol {
    associatedtype Keys: LocalizableKeyProtocol where Keys.RawValue == String

    static var tableName: String { get }
}

extension LocalizableProtocol {
    static var tableName: String {
        String(describing: Self.self)
    }
}
