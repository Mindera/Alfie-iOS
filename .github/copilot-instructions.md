# Alfie iOS - GitHub Copilot Instructions

This document provides project-specific context and guidelines for GitHub Copilot when working with the Alfie iOS e-commerce application.

---

## Project Overview

Alfie is a native iOS e-commerce application built with SwiftUI (iOS 16+) following MVVM architecture with a modular, feature-based package structure. The app fetches data from a GraphQL BFF API and includes features like product browsing, search, wishlist, and bag functionality.

---

## Architecture & Code Organization

### MVVM Pattern with Flow-Based Navigation

The codebase follows a strict MVVM architecture with feature modules. Each feature is a separate Swift Package module containing its own Views, ViewModels, DependencyContainers, and Navigation (Flow/Routes).

#### ViewModel
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

#### DependencyContainer
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

#### View
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

### State Management

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

### Navigation (Flow-Based Architecture)

The app uses a flow-based navigation architecture where each feature manages its own navigation stack.

#### FlowViewModel
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

#### FlowView
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

#### Route Enum
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

#### Tab-Based Navigation
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

---

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

---

## GraphQL & BFF Integration

### Adding a New Query

1. **Create query file**: `Alfie/AlfieKit/Sources/BFFGraph/CodeGen/Queries/<Feature>/Queries.graphql`
2. **Define fragments**: `Alfie/AlfieKit/Sources/BFFGraph/CodeGen/Queries/<Feature>/Fragments/<Model>Fragment.graphql`
3. **Extend schema**: Add `schema-<feature>.graphqls` in `Alfie/AlfieKit/Sources/BFFGraph/CodeGen/Schema/`
4. **Generate code**: Run `cd Alfie/scripts && ./run-apollo-codegen.sh`
5. **Create local models**: Add domain models in `Alfie/AlfieKit/Sources/Model/Models/`
6. **Add converters**: Create `<Model>+Converter.swift` in `Alfie/AlfieKit/Sources/Core/Services/BFFService/Converters/`
7. **Update BFFClientService**: Add fetch method in `Alfie/AlfieKit/Sources/Core/Services/BFFService/BFFClientService.swift`

**Query Pattern**:
```graphql
query GetProduct($productId: ID!) {
    product(id: $productId) {
        ...ProductFragment
    }
}
```

**Fragment Pattern**:
```graphql
fragment ProductFragment on Product {
    id
    name
    brand {
        ...BrandFragment
    }
    priceRange {
        ...PriceRangeFragment
    }
}
```

**Converter Pattern**:
```swift
extension BFFGraphAPI.ProductFragment {
    func convertToProduct() -> Product {
        Product(
            id: id,
            name: name,
            brand: brand.fragments.brandFragment.convertToBrand(),
            priceRange: priceRange?.fragments.priceRangeFragment.convertToPriceRange()
        )
    }
}
```

### Updating Existing Queries

1. Update the `.graphql` file
2. Run `cd Alfie/scripts && ./run-apollo-codegen.sh`
3. Update converters and local models as needed

---

## Localization

### String Catalog (L10n)

- **Location**: `Alfie/AlfieKit/Sources/SharedUI/Resources/Localization/L10n.xcstrings`
- **Generated code**: `Alfie/AlfieKit/Sources/SharedUI/Localization/L10n+Generated.swift` (auto-generated by SwiftGen)
- **Naming convention**: ReverseDomain + SnakeCase (e.g., `plp.error_view.title`, `home.search_bar.placeholder`)
- **Generation**: Run build or `swift package --allow-writing-to-package-directory generate-code-for-resources`

### Adding New Strings

1. **Open** `L10n.xcstrings` in Xcode
2. **Add entry** manually in base language and all supported languages
3. **Mark for Review** if not officially approved
4. **Build project** to auto-generate `L10n+Generated.swift`
5. **Use in code**: `Text(L10n.Feature.title)` or `Text(L10n.Feature.Subtitle.message("argument"))`

**Usage Pattern**:
```swift
// Simple string
Text(L10n.Home.title)

// String with arguments
Text(L10n.Home.LoggedIn.title(username))

// Pluralization (defined in String Catalog)
Text(L10n.Plp.NumberOfResults.message(count))
```

### Testing Localization

- Add test in `Alfie/AlfieKit/Tests/SharedUITests/LocalizationTests.swift`
- Test all pluralization variations (one, other, etc.)
- Validate all supported languages have translations

**Important**: Never hardcode user-facing strings. Always use `L10n` generated enums.

---

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

---

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

---

## Code Style & Best Practices

### SwiftLint Rules

- **Configuration**: `Alfie/.swiftlint.yml`
- **Trailing commas**: Mandatory
- **Function body length**: Max 200 lines
- **Type body length**: Max 400 lines
- **Identifier names**: Min 2 characters, start with lowercase
- **Fatal errors**: Use `queuedFatalError` instead of `fatalError` (custom rule)

### Naming Conventions

- **ViewModels**: `<Feature>ViewModel.swift`
- **FlowViewModels**: `<Feature>FlowViewModel.swift`
- **Views**: `<Feature>View.swift`
- **FlowViews**: `<Feature>FlowView.swift`
- **DependencyContainers**: `<Feature>DependencyContainer.swift`
- **FlowDependencyContainers**: `<Feature>FlowDependencyContainer.swift`
- **Routes**: `<Feature>Route.swift`
- **Services**: `<Feature>Service.swift` with `<Feature>ServiceProtocol`
- **Models**: Descriptive names in `Model` module
- **Localization keys**: ReverseDomain + SnakeCase (e.g., `feature.section.item`)

### Code Organization (Feature Module)

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
│   └── <Feature>ViewModelProtocol.swift
└── UI/
    ├── <Feature>View.swift
    └── <Feature>ViewModel.swift
```

### Preview Pattern

```swift
#if DEBUG
#Preview("Success") {
    FeatureView(viewModel: MockFeatureViewModel(state: .success(mockData)))
}

#Preview("Loading") {
    FeatureView(viewModel: MockFeatureViewModel(state: .loading))
}
#endif
```

**Important**: Previews should be wrapped with `#if DEBUG` (SwiftLint custom rule enforces this).

### Async/Await Pattern

- Use `async/await` for asynchronous operations
- Wrap in `Task` when calling from synchronous context
- Services return `async throws` for error handling

```swift
func viewDidAppear() {
    Task {
        await loadData()
    }
}

private func loadData() async {
    state = .loading
    do {
        let data = try await dependencies.service.fetchData()
        state = .success(data)
    } catch {
        state = .error(.generic)
    }
}
```

---

## Testing

### Test Structure

- **Location**: `Alfie/AlfieKit/Tests/`
- Test directories mirror feature modules:
  - **AppFeatureTests**: App shell tests
  - **CoreTests**: Core services tests
  - **HomeTests**: Home feature tests
  - **ProductListingTests**: Product listing tests
  - **ProductDetailsTests**: Product details tests
  - **SearchTests**: Search tests
  - **CategorySelectorTests**: Category selector tests
  - **WishlistTests**: Wishlist tests
  - **BagTests**: Bag tests
  - **SharedUITests**: Localization and UI tests
  - **DeepLinkTests**: Deep link tests
  - **DebugMenuTests**: Debug menu tests
  - **WebTests**: Web view tests
  - **MyAccountTests**: Account tests
  - **BFFGraphTests**: GraphQL tests
  - **UtilsTests**: Utility tests

### Testing Pattern

```swift
final class FeatureServiceTests: XCTestCase {
    func testFetchDataSuccess() async throws {
        // Given
        let mockBFFClient = MockBFFClientService()
        let service = FeatureService(bffClient: mockBFFClient)
        
        // When
        let result = try await service.fetchData()
        
        // Then
        XCTAssertEqual(result.id, "expected-id")
    }
}
```

### Mocking

- **Mock ViewModels**: Located in `Alfie/AlfieKit/Sources/Mocks/Core/Features/`
- **Mock Services**: Located in `Alfie/AlfieKit/Sources/Mocks/Core/Services/`
- **BFF Mocks**: Located in `Alfie/AlfieKit/Sources/BFFGraph/Mocks/` (Apollo-generated)
- **Fixtures**: Located in `Alfie/AlfieKit/Sources/Mocks/Fixtures/`
- **Pattern**: Conform to same protocol as real implementation

### Snapshot Testing

- Uses `swift-snapshot-testing` library
- Record mode: Set `record = true` temporarily
- Verify mode: Default behavior

---

## Security & Sensitive Files

### git-secret

- **Encrypted files**: Listed in `.gitsecret/paths/mapping.cfg`
- **Decryption**: `git secret reveal` (requires GPG keys)
- **Ignored**: Decrypted files are in `.gitignore`

**Sensitive file locations**:
- `Alfie/Alfie/Configuration/Debug/GoogleService-Info.plist`
- `Alfie/Alfie/Configuration/Release/GoogleService-Info.plist`

### Adding Sensitive Files

```bash
git rm --cached path-to-sensitive-file
git secret add path-to-sensitive-file
git secret hide
```

**Never commit unencrypted sensitive files.**

---

## Feature Development Process

### Spec-Driven Approach ⭐

**ALWAYS follow a spec-driven development approach for new features:**

#### Phase 1: Write the Spec First

Create a comprehensive spec document in `Docs/Specs/Features/<FeatureName>.md`.

**Spec Location**: `Docs/Specs/Features/` - This directory is automatically indexed by all AI tools (GitHub Copilot, Cursor, Cline) and accessible to developers.

**Required Sections in Every Spec:**
- **Feature Overview** - High-level description and business goals
- **User Stories** - Who needs this and why
- **Acceptance Criteria** - Clear definition of "done"
- **Data Models** - Structures and relationships (Swift code blocks)
- **API Contracts** - GraphQL queries/mutations with expected response shapes
- **UI/UX Flows** - Screen transitions and user interactions
- **Navigation** - Entry points, exit points, Routes and FlowViewModel methods
- **Localization** - All user-facing strings with their keys
- **Analytics** - Events to track with parameters
- **Edge Cases** - Error scenarios, empty states, loading states
- **Dependencies** - Required services, APIs, other features
- **Testing Strategy** - What tests are needed and where

**See `Docs/Specs/TEMPLATE.md` for full example structure.**

#### Phase 2: Break Down Into Tasks

After the spec is complete:

1. **Extract Small Tasks** - Break the spec into the smallest possible, independent tasks
2. **Create Task List** - Each task should be completable in a short session
   - Example: "Add ProductListingQuery GraphQL query"
   - Example: "Implement ProductFragment converter"
   - Example: "Create ProductListingViewModel"

#### Phase 3: Implement Feature (One Task at a Time)

Tackle tasks **one by one**, following the implementation checklist below.

**Always refer back to the spec** for requirements. If requirements change during implementation, **update the spec first**, then update code.

**After implementation, EXECUTE the build command to verify - this is MANDATORY.**

### Feature Implementation Checklist

Use this checklist for systematic feature implementation:

1. ✅ **Create Spec Document** in `Docs/Specs/Features/<Feature>.md`
2. ✅ **Define Domain Models** in `Alfie/AlfieKit/Sources/Model/Models/<Feature>/`
3. ✅ **Create Service Protocol** in `Alfie/AlfieKit/Sources/Model/Services/<Feature>/`
4. ✅ **Add GraphQL Query** (if API needed):
   - Create `Queries.graphql` in `AlfieKit/Sources/BFFGraph/CodeGen/Queries/<Feature>/`
   - Create fragments in `Fragments/` subdirectory
   - Extend schema in `CodeGen/Schema/schema-<feature>.graphqls`
5. ✅ **Run Apollo Codegen**: `cd Alfie/scripts && ./run-apollo-codegen.sh`
6. ✅ **Create Converters** in `Core/Services/BFFService/Converters/<Feature>+Converter.swift`
7. ✅ **Implement Service** in `Core/Services/<Feature>/`
8. ✅ **Register Service** in `Alfie/Alfie/Service/ServiceProvider.swift`
9. ✅ **Create Feature Module** in `AlfieKit/Sources/<Feature>/`:
   - Create `<Feature>DependencyContainer.swift` in `Models/`
   - Create `<Feature>FlowDependencyContainer.swift` in `Models/`
   - Create `<Feature>ViewModelProtocol.swift` in `Protocols/`
   - Create `<Feature>FlowViewModelProtocol.swift` in `Protocols/`
   - Create `<Feature>Route.swift` in `Navigation/`
   - Create `<Feature>Route+Destination.swift` in `Navigation/`
   - Create `<Feature>FlowView.swift` in `Navigation/`
   - Create `<Feature>FlowViewModel.swift` in `Navigation/`
   - Create `<Feature>View.swift` in `UI/`
   - Create `<Feature>ViewModel.swift` in `UI/`
10. ✅ **Create Mock ViewModel** in `Mocks/Core/Features/Mock<Feature>ViewModel.swift`
11. ✅ **Add to Package.swift**: Add new target and product in `AlfieKit/Package.swift`
12. ✅ **Integrate with Navigation**: Add route to parent feature's Route enum
13. ✅ **Add Localization Strings** in `L10n.xcstrings` (all keys from spec)
14. ✅ **Verify** - Execute `./Alfie/scripts/verify.sh` (runs build + tests)
15. ✅ **Verify Against Spec** - Check all acceptance criteria met
16. ✅ **Update Spec Status** - Mark as "Implemented" with PR link and date

---

## 🏗️ Verification

**Every code change MUST be verified with build + tests.**

### Verify Command

```bash
# Recommended: Run full verification (build + tests)
./Alfie/scripts/verify.sh

# Build only (if you need to iterate on compilation)
./Alfie/scripts/build-for-verification.sh

# Tests only (after successful build)
./Alfie/scripts/test-for-verification.sh --skip-build
```

### Process

1. Execute `./Alfie/scripts/verify.sh` after completing implementation
2. Wait for "✅ FULL VERIFICATION PASSED" message
3. If build fails: fix errors, re-run
4. If tests fail: fix logic, re-run
5. Only mark task complete after full verification passes

**Why use the script?**
- Works on all developer machines (no hardcoded simulator IDs)
- Automatically finds available simulator
- Provides clear success/failure messages
- Saves build log for debugging

### Common Build Errors

| Error | Fix |
|-------|-----|
| Missing imports | Add `import Model`, `import SharedUI`, `import Core`, etc. |
| Unresolved symbols | Check L10n key typos, missing enum cases |
| Type mismatches | Verify protocol conformance |
| Missing files | Notify user to add files to Xcode project |

---

## 🚫 Xcode Project File Management

**CRITICAL**: Never edit `Alfie.xcodeproj/project.pbxproj` directly.

### Files Requiring Xcode Integration

When creating new `.swift` files in `Alfie/Alfie/` (app target), notify the user:

```
⚠️ ACTION REQUIRED: Please add this file to the Xcode project:
1. Open Alfie.xcodeproj in Xcode
2. Right-click the appropriate folder
3. Select "Add Files to Alfie..."
4. Select the file and ensure "Alfie" target is checked
5. Run: ./Alfie/scripts/verify.sh
```

### Files Auto-Discovered (No Action Needed)

- Files in `AlfieKit/Sources/` and `AlfieKit/Tests/` (Swift Package - auto-discovered)
- GraphQL `.graphql` files
- Documentation and scripts

**Note**: Most new feature code goes in AlfieKit modules and is auto-discovered.

---

## Things to AVOID

❌ Access `ServiceProvider` from ViewModels (use DependencyContainer)  
❌ Hardcode user-facing strings (use `L10n`)  
❌ Bypass FlowViewModel for navigation (pass navigation closures from FlowViewModel)  
❌ Edit auto-generated files (`L10n+Generated.swift`, `BFFGraph/API/`, `BFFGraph/Mocks/`)  
❌ Use `fatalError` (use `queuedFatalError`)  
❌ Commit sensitive files unencrypted  
❌ Create custom UI without checking SharedUI first  
❌ Create ViewModels without protocols  
❌ Edit `project.pbxproj` directly  
❌ Skip build verification

---

## Quick Reference

### Key Directories

```
Alfie/
├── Alfie/                          # Main app target (minimal code)
│   ├── Views/                      # App-specific views (Info only)
│   ├── Service/                    # ServiceProvider
│   ├── Delegate/                   # AppDelegate
│   └── Configuration/              # App config, URLs, sensitive files
├── AlfieKit/                       # Swift Package (feature modules)
│   ├── Sources/
│   │   ├── AppFeature/             # App shell, tab bar, root navigation
│   │   ├── BFFGraph/               # GraphQL (queries, schema, codegen)
│   │   ├── Bag/                    # Bag feature module
│   │   ├── CategorySelector/       # Shop tab feature module
│   │   ├── Core/                   # Core services layer
│   │   ├── DebugMenu/              # Debug menu (DEBUG only)
│   │   ├── DeepLink/               # Deep linking
│   │   ├── Home/                   # Home feature module
│   │   ├── Mocks/                  # Test mocks
│   │   ├── Model/                  # Domain models, protocols
│   │   ├── MyAccount/              # Account feature module
│   │   ├── ProductDetails/         # Product details feature module
│   │   ├── ProductListing/         # Product listing feature module
│   │   ├── Search/                 # Search feature module
│   │   ├── SharedUI/               # Localization, theme, components
│   │   ├── TestUtils/              # Test helpers
│   │   ├── Utils/                  # Utilities
│   │   ├── Web/                    # WebView feature module
│   │   └── Wishlist/               # Wishlist feature module
│   └── Tests/                      # Unit tests (per module)
└── scripts/                        # Build scripts (Apollo codegen)
```

### Common Commands

```bash
# Full verification (build + tests) - ALWAYS RUN AFTER CODE CHANGES
./Alfie/scripts/verify.sh

# Decrypt sensitive files (requires GPG keys)
git secret reveal

# Install dependencies
brew bundle install

# Generate GraphQL code
cd Alfie/scripts && ./run-apollo-codegen.sh

# Generate localization code (automatic on build, or manually)
swift package --allow-writing-to-package-directory generate-code-for-resources
```

### Key Dependencies

- **Apollo iOS**: GraphQL client (v1.19.0)
- **Firebase**: Analytics, Crashlytics, Remote Config (v11.11.0)
- **Braze**: Marketing automation (v11.9.0)
- **Nuke**: Image loading/caching (v12.8.0)
- **Alicerce**: Utilities, logging (v0.18.0)
- **SwiftGen**: Code generation for resources (v6.6.4-mindera fork)
- **Snapshot Testing**: UI testing (v1.18.3)

---

## Code Review Guidelines

### PR Review Checklist

- [ ] **Architecture**: MVVM pattern, DependencyContainer usage, FlowViewModel navigation
- [ ] **Localization**: All strings use L10n
- [ ] **State**: ViewState/PaginatedViewState used correctly
- [ ] **Tests**: ViewModels have unit tests, protocols exist for mocking
- [ ] **Security**: No credentials, Keychain for sensitive data, HTTPS only
- [ ] **GraphQL**: Fragments used, codegen run, no edits to generated files
- [ ] **SwiftLint**: No violations

### 🔴 Critical (Block Merge)

- ViewModels accessing `ServiceProvider` directly
- Hardcoded user-facing strings
- Navigation bypassing FlowViewModel
- Missing ViewModel protocols
- Credentials/secrets in code
- State not using `ViewState` enums

### 🟠 High Priority

- Missing tests for ViewModels
- GraphQL queries without fragments
- Missing localization translations
- Dependencies not via DependencyContainer

### Security Review Points

- No API keys, tokens, passwords in code
- Sensitive data uses Keychain, not UserDefaults
- No PII in logs
- git-secret for sensitive files
- Input validation on deep links

---

## Additional Context

- **Minimum iOS**: 16.0
- **Swift Version**: 5.9+
- **Mock Server**: Separate Alfie-Mocks repo runs locally on localhost:4000
- **CI/CD**: Work in progress
- **Release Process**: Work in progress

---

This document should be updated when major architectural decisions change or new patterns are introduced.
