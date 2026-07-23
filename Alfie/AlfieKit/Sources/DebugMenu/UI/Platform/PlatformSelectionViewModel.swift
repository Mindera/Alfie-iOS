import Foundation
import Model

public final class PlatformSelectionViewModel: ObservableObject {
    public let availablePlatforms = BFFPlatform.allCases
    @Published public var selectedPlatform: BFFPlatform? {
        didSet {
            guard let selectedPlatform, selectedPlatform != oldValue else { return }
            BFFPlatformDebugStore.selected = selectedPlatform
        }
    }

    public init() {
        // Assignment in init doesn't fire didSet, so this reads the persisted value without re-saving.
        selectedPlatform = BFFPlatformDebugStore.selected
    }
}
