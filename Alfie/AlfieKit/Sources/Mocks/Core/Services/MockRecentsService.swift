import Combine
import Models

public final class MockRecentsService: RecentsServiceProtocol {
    public var recentSearches: [RecentSearch] = []
    public var recentSearchesPublisher: AnyPublisher<[RecentSearch], Never> = Just([]).eraseToAnyPublisher()

    public init() {}

    public var onAdd: ((RecentSearch) -> Void)?
    public func add(_ recentSearch: Models.RecentSearch) {
        onAdd?(recentSearch)
    }
    
    public var onRemove: ((RecentSearch) -> Void)?
    public func remove(_ recentSearch: Models.RecentSearch) {
        onRemove?(recentSearch)
    }

    public var onRemoveAll: (() -> Void)?
    public func removeAll() {
        onRemoveAll?()
    }

    public var onSave: (() -> Void)?
    public func save() {
        onSave?()
    }
}
