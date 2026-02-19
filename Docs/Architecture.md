# Architecture & Code Organization

## MVVM Pattern with Flow-Based Navigation

The codebase follows a strict MVVM architecture with feature modules. Each feature is a separate Swift Package module containing its own Views, ViewModels, DependencyContainers, and Navigation (Flow/Routes).

### ViewModel
- **Location**: `Alfie/AlfieKit/Sources/<Feature>/UI/<Feature>ViewModel.swift`
- **Protocol**: Define a protocol in `Alfie/AlfieKit/Sources/<Feature>/Protocols/` for mockability
- **Properties**: Use `@Published` for observable state
- **State Management**: Use `ViewState<Value, Error>` or `PaginatedViewState<Value, Error>` enums
- **Dependencies**: Inject via DependencyContainer, never access ServiceProvider directly
- **Navigation**: Receive navigation closures from FlowViewModel (e.g., `navigate: (Route) -> Void`)

**Example Pattern**:
```swift
public class FeatureViewModel: FeatureViewModelProtocol, ObservableObject {
    private let dependencies: FeatureDependencyContainer
    private let navigate: (FeatureRoute) -> Void
    @Published private(set) var state: ViewState<FeatureModel, FeatureError>
    
    init(
        dependencies: FeatureDependencyContainer,
        navigate: @escaping (FeatureRoute) -> Void
    ) {
        self.dependencies = dependencies
        self.navigate = navigate
        state = .loading
    }
    
    func didTapItem(_ item: Item) {
        navigate(.details(item))
    }
}
```

### DependencyContainer
- **Location**: `Alfie/AlfieKit/Sources/<Feature>/Models/<Feature>DependencyContainer.swift`
- **Flow Container**: `Alfie/AlfieKit/Sources/<Feature>/Models/<Feature>FlowDependencyContainer.swift`
- **Purpose**: Filter ServiceProvider dependencies so ViewModels only access what they need
- **Pattern**: Concrete class, no protocol required

**Example Pattern**:
```swift
public final class FeatureDependencyContainer {
    let someService: SomeServiceProtocol
    let configurationService: ConfigurationServiceProtocol
    
    public init(someService: SomeServiceProtocol, configurationService: ConfigurationServiceProtocol) {
        self.someService = someService
        self.configurationService = configurationService
    }
}

// Flow container aggregates all sub-feature containers
public final class FeatureFlowDependencyContainer {
    let featureDependencyContainer: FeatureDependencyContainer
    let subFeatureDependencyContainer: SubFeatureDependencyContainer
    
    public init(...) { ... }
}
```

### View
- **Location**: `Alfie/AlfieKit/Sources/<Feature>/UI/<Feature>View.swift`
- **Pattern**: Use `@StateObject` for ViewModel, generic over ViewModel protocol
- **State Handling**: Switch on `viewModel.state` to render appropriate UI

**Example Pattern**:
```swift
struct FeatureView<ViewModel: FeatureViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        switch viewModel.state {
        case .loading:
            LoaderView(circleDiameter: .defaultSmall)
        case .success(let data):
            ContentView(data: data)
        case .error(let error):
            ErrorView(error: error)
        }
    }
}
```

## State Management

**ViewState Enum** (for simple loading/success/error flows):
```swift
public enum ViewState<Value, StateError: Error> {
    case loading
    case success(Value)
    case error(StateError)
}
```

**PaginatedViewState Enum** (for paginated lists):
```swift
public enum PaginatedViewState<Value, StateError: Error> {
    case loadingFirstPage(Value)
    case loadingNextPage(Value)
    case success(Value)
    case error(StateError)
}
```

## Navigation (Flow-Based Architecture)

The app uses a flow-based navigation architecture where each feature manages its own navigation stack.

### FlowViewModel
- **Location**: `Alfie/AlfieKit/Sources/<Feature>/Navigation/<Feature>FlowViewModel.swift`
- **Protocol**: Conforms to `FlowViewModelProtocol` from `Model` module
- **Purpose**: Manages NavigationPath, creates ViewModels, handles navigation actions
- **Pattern**: Uses `@Published var path = NavigationPath()` for SwiftUI navigation

**FlowViewModelProtocol**:
```swift
public protocol FlowViewModelProtocol: ObservableObject {
    associatedtype Route: Hashable
    
    var path: NavigationPath { get set }
    var overlayViewPublisher: AnyPublisher<AnyView?, Never> { get }
    
    func navigate(_ route: Route)
    func popToRoot()
    func pop()
}
```

**Example FlowViewModel**:
```swift
public final class FeatureFlowViewModel: FeatureFlowViewModelProtocol {
    public typealias Route = FeatureRoute
    @Published public var path = NavigationPath()
    private let dependencies: FeatureFlowDependencyContainer
    
    public init(dependencies: FeatureFlowDependencyContainer) {
        self.dependencies = dependencies
    }
    
    public func makeFeatureViewModel() -> FeatureViewModel {
        FeatureViewModel(
            dependencies: dependencies.featureDependencyContainer,
            navigate: { [weak self] route in self?.navigate(route) }
        )
    }
    
    public func navigate(_ route: FeatureRoute) {
        path.append(route)
    }
}
```

### FlowView
- **Location**: `Alfie/AlfieKit/Sources/<Feature>/Navigation/<Feature>FlowView.swift`
- **Purpose**: Wraps NavigationStack and provides .navigationDestination routing

**Example FlowView**:
```swift
public struct FeatureFlowView<ViewModel: FeatureFlowViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel
    
    public init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack(path: $viewModel.path) {
            FeatureView(viewModel: viewModel.makeFeatureViewModel())
                .navigationDestination(for: FeatureRoute.self) { route in
                    route.destination(...)
                }
        }
    }
}
```

### Route Enum
- **Location**: `Alfie/AlfieKit/Sources/<Feature>/Navigation/<Feature>Route.swift`
- **Purpose**: Define all navigation destinations within a feature
- **Destination Extension**: `<Feature>Route+Destination.swift` maps routes to views

**Example Route**:
```swift
public enum FeatureRoute: Hashable {
    case details(DetailsConfiguration)
    case subFeature(SubFeatureRoute)
}
```

### Tab-Based Navigation
- **AppRoute**: Top-level routing (tabs)
- **TabRoute**: Routes to each tab's flow (`home`, `bag`, `shop`, `wishlist`)
- **Feature Flows**: Each tab has its own FlowView/FlowViewModel

**Navigation Hierarchy**:
```
AppFeatureView
├── RootTabView (tab bar)
│   ├── HomeFlowView (home tab)
│   │   ├── HomeView
│   │   ├── ProductListingView
│   │   ├── ProductDetailsView
│   │   └── ...
│   ├── CategorySelectorFlowView (shop tab)
│   ├── WishlistFlowView (wishlist tab)
│   └── BagFlowView (bag tab)
```

## Module Structure (AlfieKit Package)

The project uses Swift Package Manager with a modular, feature-based architecture in `Alfie/AlfieKit/`:

### Infrastructure Modules

- **BFFGraph**: Apollo GraphQL types, queries, schema, and generated mocks (auto-generated API layer)
- **Core**: Core services layer (BFF client, authentication, analytics, persistence, etc.)
- **Model**: Domain models, service protocols, navigation protocols, analytics events
- **Mocks**: Mock implementations for testing (services, features)
- **SharedUI**: Localization (L10n.xcstrings), theme, reusable UI components
- **Utils**: Shared utilities and extensions
- **TestUtils**: Testing utilities (snapshot testing helpers, test schedulers)
- **DeepLink**: Deep linking handling

### Feature Modules

Each feature is a self-contained module with its own navigation, views, and view models:

- **AppFeature**: App shell, tab bar, root navigation (RootTabView, AppFeatureView)
- **Home**: Home tab feature
- **ProductListing**: Product listing/search results
- **ProductDetails**: Product detail pages
- **Search**: Search functionality
- **CategorySelector**: Shop tab with category navigation
- **Wishlist**: Wishlist feature
- **Bag**: Shopping bag feature
- **MyAccount**: User account screens
- **Web**: WebView wrapper for web-based features
- **DebugMenu**: Debug/developer menu (DEBUG builds only)

### Feature Module Structure

Each feature module follows this structure:
```
<Feature>/
├── Models/
│   ├── <Feature>DependencyContainer.swift
│   └── <Feature>FlowDependencyContainer.swift
├── Navigation/
│   ├── <Feature>FlowView.swift
│   ├── <Feature>FlowViewModel.swift
│   ├── <Feature>Route.swift
│   └── <Feature>Route+Destination.swift
├── Protocols/
│   ├── <Feature>ViewModelProtocol.swift
│   └── <Feature>FlowViewModelProtocol.swift
├── UI/
│   ├── <Feature>View.swift
│   └── <Feature>ViewModel.swift
└── Toolbar/  (optional)
    └── <Feature>+Toolbar.swift
```

### Module Dependencies

- **App target** depends on AppFeature and Core modules
- **Model** is the most foundational (depends only on Utils)
- **Core** depends on Model, Utils, BFFGraph
- **SharedUI** depends on Core, Model, Mocks
- **Feature modules** depend on Model, SharedUI, Core, and other feature modules as needed

## Services & Dependency Injection

### ServiceProvider

- **Location**: `Alfie/Alfie/Service/ServiceProvider.swift`
- **Purpose**: Central registry of all services
- **Access**: Only ViewFactory and top-level app code should access directly
- **Pattern**: Protocol-based services for testability

**Key Services** (protocols defined in `Model/Services/`):
- `ProductServiceProtocol`: Product data fetching
- `BrandsServiceProtocol`: Brands data
- `AuthenticationServiceProtocol`: User authentication
- `WishlistServiceProtocol`: Wishlist management
- `BagServiceProtocol`: Shopping bag
- `SearchServiceProtocol`: Search functionality
- `RecentsServiceProtocol`: Recent searches
- `DeepLinkServiceProtocol`: Deep linking
- `ConfigurationServiceProtocol`: Feature flags and remote config
- `AlfieAnalyticsTracker`: Analytics events
- `NavigationServiceProtocol`: Navigation state management
- `SessionServiceProtocol`: User session management
- `ReachabilityServiceProtocol`: Network connectivity
- `WebURLProviderProtocol`: Web URL generation
- `WebViewConfigurationServiceProtocol`: WebView configuration

### Service Implementation Pattern

Service protocols are defined in `Alfie/AlfieKit/Sources/Model/Services/`:  
Service implementations are in `Alfie/AlfieKit/Sources/Core/Services/`:

```swift
public protocol FeatureServiceProtocol {
    func fetchData() async throws -> FeatureData
}

public final class FeatureService: FeatureServiceProtocol {
    private let bffClient: BFFClientServiceProtocol
    
    public init(bffClient: BFFClientServiceProtocol) {
        self.bffClient = bffClient
    }
    
    public func fetchData() async throws -> FeatureData {
        let result = try await bffClient.fetchFeature()
        return result.convertToFeatureData()
    }
}
```

## Style Guide & UI Components

### Theme System

- **Colors**: Use themed colors from SharedUI (e.g., `ThemedColor.primary`)
- **Typography**: Use `theme.font` with predefined styles (e.g., `theme.font.header.h3()`)
- **Spacing**: Use `Spacing` enum values (e.g., `Spacing.space200`)
- **Icons**: Use `Icon` enum (e.g., `Icon.home.image`)

**Example**:
```swift
Text.build(theme.font.header.h3("Title"))
Icon.home.image
    .resizable()
    .frame(width: 75)
ThemedButton(text: "Action") {
    viewModel.didTapButton()
}
.padding(.horizontal, Spacing.space200)
```

### Reusable Components

Located in `Alfie/AlfieKit/Sources/SharedUI/Components/`:

- **Buttons**: `ThemedButton`, various button styles
- **Search**: `ThemedSearchBarView` with themes (`.soft`, etc.)
- **Product Cards**: Product display components
- **Toolbars**: `toolbarView` modifier for consistent navigation bars
- **Loaders**: `LoaderView` with configurable sizes

**Always use existing SharedUI components** instead of creating custom UI from scratch.
