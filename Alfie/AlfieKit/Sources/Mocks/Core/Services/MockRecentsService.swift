import Combine
import Model

public final class MockRecentsService: RecentsServiceProtocol {
    public var recentSearches: [RecentSearch] = []
    public var recentSearchesPublisher: AnyPublisher<[RecentSearch], Never> = Just([]).eraseToAnyPublisher()

    public init() {}

    public var onAdd: ((RecentSearch) -> Void)?
    public func add(_ recentSearch: Model.RecentSearch) {
        onAdd?(recentSearch)
    }
    
    public var onRemove: ((RecentSearch) -> Void)?
    public func remove(_ recentSearch: Model.RecentSearch) {
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
