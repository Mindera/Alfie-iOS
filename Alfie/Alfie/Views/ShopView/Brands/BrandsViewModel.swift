import Combine
import Core
import Foundation
import Models
import OrderedCollections

final class BrandsViewModel: BrandsViewModelProtocol {
    private enum Constants {
        static let placeholderTitleLowerBound: Int = 30
        static let placeholderTitleUpperBound: Int = 50
        static let placeholderItemCount: Int = 10
    }

    private let brandsService: BrandsServiceProtocol
    private lazy var placeholders: [Brand] = {
        (0..<Constants.placeholderItemCount).map { _ in
            .init(
                id: UUID().uuidString,
                name: String(
                    repeating: " ",
                    count: .random(in: Constants.placeholderTitleLowerBound...Constants.placeholderTitleUpperBound)
                ),
                slug: ""
            )
        }
    }()
    @Published private(set) var state: ViewState<OrderedDictionary<String, [Brand]>, BrandsViewErrorType> = .loading
    @Published public var searchText: String

    private var searchFocusStateSubject: PassthroughSubject<Bool, Never> = .init()
    private(set) lazy var indexVisibilityPublisher: AnyPublisher<Bool, Never> = searchFocusStateSubject
        .map { [weak self] isFocused in
            isFocused ? false : self?.searchText.isEmpty == true
        }
        .eraseToAnyPublisher()

    init(brandsService: BrandsServiceProtocol) {
        self.brandsService = brandsService
        searchText = ""
    }

    var sectionTitles: OrderedSet<String> {
        guard let brandsPerLetter = state.value else {
            return []
        }

        let filteredTitles: [String] = brandsPerLetter.keys.compactMap { letter in
            guard !brands(for: letter).isEmpty else {
                return nil
            }
            return letter
        }
        return OrderedSet(filteredTitles.sorted())
    }

    func viewDidAppear() {
        Task {
            await loadItemsIfNeeded()
        }
    }

    func brands(for section: String) -> [Brand] {
        if state.isLoading {
            return placeholders
        }

        guard let brands = state.value?[section] else {
            return []
        }

        return if searchText.isBlank {
            brands
        } else {
            brands.filter { $0.name.localizedStandardContains(searchText) }
        }
    }

    func searchFocusDidChange(isFocused: Bool) {
        searchFocusStateSubject.send(isFocused)
    }

    // MARK: - Private

    @MainActor
    private func loadItemsIfNeeded() async {
        guard !state.isSuccess else {
            return
        }

        if !state.isLoading {
            state = .loading
        }

        let brands: [Brand]

        do {
            brands = try await brandsService.getBrands()
        } catch {
            log.error("Error fetching brands for Brands screen: \(error)")
            state = .error(.generic)
            return
        }

        let validatedBrands = brands.filter(\.name.isNotBlank)

        guard !validatedBrands.isEmpty else {
            state = .error(.noResults)
            return
        }

        let sortedBrands = validatedBrands.sorted { $0.name < $1.name }

        let brandsPerLetterDictionary: [String: [Brand]] = {
            Dictionary(grouping: sortedBrands) {
                let normalizedName = $0.name
                    .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
                guard let character = normalizedName.first else {
                    return ""
                }
                return character.uppercased()
            }
        }()

        state = .success(OrderedDictionary(uniqueKeysWithValues: brandsPerLetterDictionary))
    }
}
