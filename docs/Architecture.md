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
- **Scanner**: Camera scanning of the Alfie code on a swing tag, opening the product it names
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

### Where Each Piece of a Feature Goes

Paths are relative to `Alfie/AlfieKit/Sources/` unless they start with `Alfie/`.

| Piece | Location |
|---|---|
| Domain models | `Model/Models/<Feature>/` |
| Service protocol | `Model/Services/<Feature>/` |
| GraphQL operations and fragments | `BFFGraph/CodeGen/Queries/<Feature>/Queries.graphql`, `Fragments/` beside it; then `run-apollo-codegen.sh` (see `GraphQL.md`) |
| Converters | `Core/Services/BFFService/Converters/<Feature>+Converter.swift` |
| Service implementation | `Core/Services/<Feature>/` |
| Service registration | `Alfie/Alfie/Service/ServiceProvider.swift` |
| Feature module | `<Feature>/`, laid out as above |
| Mock ViewModel | `Mocks/Core/Features/Mock<Feature>ViewModel.swift` |
| Target and product | `Alfie/AlfieKit/Package.swift` |
| Route | A case on the parent feature's `Route` enum |
| Strings | `L10n.xcstrings` (see `Localization.md`) |

### Files That Need Xcode

Everything under `AlfieKit/Sources/` and `AlfieKit/Tests/` is a Swift package and is picked up
automatically, as are `.graphql` files. A new `.swift` file under `Alfie/Alfie/` (the app target) is
not: `project.pbxproj` is never edited by hand, so ask the user to add it in Xcode (Add Files to
"Alfie"…, with the `Alfie` target ticked), then verify.

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
- **Access**: Reached only by app-level code and the `AppFeature` ViewModels that wire the app graph
- **Pattern**: Protocol-based services for testability

**Services**: `ServiceProviderProtocol` in `Model/Services/ServiceProviderProtocol.swift` declares the
full set. Two carry more than their name suggests — `ConfigurationServiceProtocol` gates force and soft
app updates as well as feature flags, and `RecentsServiceProtocol` stores recent *searches*, not
recently viewed products.

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

Reusable views live under `Alfie/AlfieKit/Sources/SharedUI/` — `Components/` for feature-level
composites (product cards, carousels, toolbars, snackbar) and `Theme/` for the themed primitives
(`ThemedButton`, `ThemedSearchBarView`, `ThemedIcon`, `LoaderView`). Browse the directory before
writing a new view.

For the design values those components consume — colour, spacing, radius, typography — see
[`DesignTokens.md`](DesignTokens.md); for icons, [`Iconography.md`](Iconography.md).
