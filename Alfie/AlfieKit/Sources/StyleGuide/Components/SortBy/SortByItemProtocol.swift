import Foundation

// MARK: - SortByItemProtocol

public protocol SortByItemProtocol {
    var value: SortByType { get }
    var title: String { get }
    var icon: Icon? { get }
}

// MARK: - SortByItem

public struct SortByItem: SortByItemProtocol {
    public var value: SortByType
    public var title: String
    public var icon: Icon?

    public init(value: SortByType, title: String, icon: Icon? = nil) {
        self.value = value
        self.title = title
        self.icon = icon
    }
}
