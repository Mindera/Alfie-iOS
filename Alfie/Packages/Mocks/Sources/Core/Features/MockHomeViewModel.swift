import Models

public struct MockHomeViewModel: HomeViewModelProtocol {
    public init() { }
    
    public var onToolbarModifierViewModelCalled:  (() -> DefaultToolbarModifierViewModelProtocol)?
    public var toolbarModifierViewModel: DefaultToolbarModifierViewModelProtocol {
        onToolbarModifierViewModelCalled?() ?? MockDefaultToolbarModifierViewModel(isWishlistEnabled: false)
    }
}
