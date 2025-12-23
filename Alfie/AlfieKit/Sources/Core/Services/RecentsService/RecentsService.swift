import Combine
import Foundation
import Model

public final class RecentsService: RecentsServiceProtocol {
    private let autoSaveEnabled: Bool
    private let storageService: StorageServiceProtocol?
    private let recentSearchesSubject: CurrentValueSubject<[RecentSearch], Never>
    private let storageKey: String
    private var hasPendingChanges: Bool

    public let recentSearchesPublisher: AnyPublisher<[RecentSearch], Never>
    public var recentSearches: [RecentSearch] {
        recentSearchesSubject.value
    }

    public init(autoSaveEnabled: Bool, storageService: StorageServiceProtocol?, storageKey: String) {
        self.autoSaveEnabled = autoSaveEnabled
        self.hasPendingChanges = false
        self.storageKey = storageKey
        self.storageService = storageService
        self.recentSearchesSubject = .init(
            (try? storageService?.load(for: storageKey, as: [RecentSearch].self, expiry: .never)) ?? []
        )
        self.recentSearchesPublisher = recentSearchesSubject.eraseToAnyPublisher()
    }

    public func add(_ recentSearch: RecentSearch) {
        guard
            !recentSearches.contains(recentSearch),
            !recentSearch.value.isEmpty
        else {
            return
        }
        if recentSearches.count >= Constants.recentSearchesCountLimit {
            recentSearchesSubject.value.removeLast()
        }
        recentSearchesSubject.value.insert(recentSearch, at: 0)
        hasPendingChanges = true
        saveIfNeeded()
    }

    public func remove(_ recentSearch: RecentSearch) {
        guard
            !recentSearchesSubject.value.isEmpty,
            let indexToRemove = recentSearches.firstIndex(of: recentSearch)
        else {
            return
        }
        recentSearchesSubject.value.remove(at: indexToRemove)
        hasPendingChanges = true
        saveIfNeeded()
    }

    public func removeAll() {
        guard !recentSearchesSubject.value.isEmpty else {
            return
        }
        recentSearchesSubject.value.removeAll()
        hasPendingChanges = true
        saveIfNeeded()
    }

    public func save() {
        guard hasPendingChanges else {
            return
        }
        try? storageService?.save(object: recentSearches, for: storageKey)
    }

    private func saveIfNeeded() {
        if autoSaveEnabled {
            try? storageService?.save(object: recentSearches, for: storageKey)
            hasPendingChanges = false
        }
    }
}

extension RecentsService {
    private enum Constants {
        static let recentSearchesCountLimit: Int = 5
    }
}
