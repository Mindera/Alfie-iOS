import Combine
import Foundation
import OrderedCollections
import Model

public class MockBrandsViewModel: BrandsViewModelProtocol {
    public var state: ViewState<OrderedDictionary<String, [Brand]>, BrandsViewErrorType>
    public var sectionTitles: OrderedSet<String> = .init()
    public var searchText: String = ""
    public var indexVisibilitySubject: PassthroughSubject<Bool, Never> = .init()
    public lazy var indexVisibilityPublisher: AnyPublisher<Bool, Never> = indexVisibilitySubject.eraseToAnyPublisher()

    public init(state: ViewState<OrderedDictionary<String, [Brand]>, BrandsViewErrorType> = .loading,
                sectionTitles: OrderedSet<String> = .init()) {
        self.state = state
        self.sectionTitles = sectionTitles
    }

    public var onViewDidAppearCalled: (() -> Void)?
    public func viewDidAppear() {
        onViewDidAppearCalled?()
    }

    public var onBrandsCalled: ((String) -> [Brand])?
    public func brands(for section: String) -> [Brand] {
        onBrandsCalled?(section) ?? state.value?[section] ?? []
    }

    public var onSearchFocusDidChangeCalled: ((Bool) -> Void)?
    public func searchFocusDidChange(isFocused: Bool) {
        onSearchFocusDidChangeCalled?(isFocused)
    }
}
