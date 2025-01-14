import Foundation

// MARK: - SortByItemProtocol

public protocol SortByItemProtocol {
    var value: SortByType { get }
    var title: LocalizedStringResource { get }
    var icon: Icon? { get }
}

// MARK: - SortByItem

public struct SortByItem: SortByItemProtocol {
    public var value: SortByType
    public var title: LocalizedStringResource
    public var icon: Icon?

    public init(value: SortByType, title: LocalizedStringResource, icon: Icon? = nil) {
        self.value = value
        self.title = title
        self.icon = icon
    }
}
