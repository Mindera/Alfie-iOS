import Navigation

public final class StyleGuideCoordinator: CoordinatorProtocol {
    public typealias Screen = StyleGuideScreen
    private let navigationAdapter: NavigationAdapter<StyleGuideScreen>

    public init(navigationAdapter: NavigationAdapter<StyleGuideScreen>) {
        self.navigationAdapter = navigationAdapter
    }
}
