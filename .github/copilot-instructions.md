# Alfie iOS - GitHub Copilot Instructions

This document provides project-specific context and guidelines for GitHub Copilot when working with the Alfie iOS e-commerce application.

---

## ⚠️ CRITICAL: Build Execution Requirement

**🚨 EVERY IMPLEMENTATION MUST EXECUTE BUILD SCRIPT AND VERIFY SUCCESS 🚨**

Before considering ANY task complete, you **MUST**:

1. ✅ Execute the build verification script:
   ```bash
   ./Alfie/scripts/build-for-verification.sh
   ```

2. ✅ Wait for build to complete and capture output
3. ✅ Verify "✅ BUILD SUCCEEDED" message appears
4. ✅ If build fails, fix errors and re-run until success
5. ✅ Only then mark task as complete

**Pre-build code verification is NOT sufficient - you MUST run the actual build.**

See [Build Verification Section](#-build-verification---critical-requirement) for complete details.

---

## Project Overview

Alfie is a native iOS e-commerce application built with SwiftUI (iOS 16+) following MVVM architecture with a modular package structure. The app fetches data from a GraphQL BFF API and includes features like product browsing, search, wishlist, and bag functionality.

---

## Architecture & Code Organization

### MVVM Pattern

The codebase follows a strict MVVM architecture with the following components:

#### ViewModel
- **Location**: `Alfie/Alfie/Views/<Feature>/<Feature>ViewModel.swift`
- **Protocol**: Define a protocol in `Alfie/AlfieKit/Sources/Models/Features/` for mockability
- **Properties**: Use `@Published` for observable state
- **State Management**: Use `ViewState<Value, Error>` or `PaginatedViewState<Value, Error>` enums
- **Dependencies**: Inject via DependencyContainer, never access ServiceProvider directly

**Example Pattern**:
```swift
final class FeatureViewModel: FeatureViewModelProtocol {
    private let dependencies: FeatureDependencyContainer
    @Published private(set) var state: ViewState<FeatureModel, FeatureError>
    
    init(dependencies: FeatureDependencyContainer) {
        self.dependencies = dependencies
        state = .loading
    }
}
```

#### DependencyContainer
- **Location**: `Alfie/Alfie/Views/<Feature>/<Feature>DependencyContainer.swift`
- **Purpose**: Filter ServiceProvider dependencies so ViewModels only access what they need
- **Pattern**: Protocol not required, concrete class only

**Example Pattern**:
```swift
final class FeatureDependencyContainer {
    let someService: SomeServiceProtocol
    let analytics: AlfieAnalyticsTracker
    
    init(someService: SomeServiceProtocol, analytics: AlfieAnalyticsTracker) {
        self.someService = someService
        self.analytics = analytics
    }
}
```

#### View
- **Location**: `Alfie/Alfie/Views/<Feature>/<Feature>View.swift`
- **Pattern**: Use `@StateObject` for ViewModel, `@EnvironmentObject` for Coordinator
- **State Handling**: Switch on `viewModel.state` to render appropriate UI

**Example Pattern**:
```swift
struct FeatureView<ViewModel: FeatureViewModelProtocol>: View {
    @EnvironmentObject private var coordinator: Coordinator
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

### Navigation

The app uses a custom navigation framework with these components:

#### Coordinator
- **Location**: `Alfie/Alfie/Navigation/Coordinator.swift`
- **Purpose**: Handle all navigation logic, injected as `@EnvironmentObject`
- **Methods**: Named for user actions (e.g., `didTapBackButton()`, `openSearch()`, `didTap(_ product:)`)
- **Never**: Views should never call NavigationAdapter directly

#### Screen Enum
- **Location**: `Alfie/Alfie/Navigation/Screen.swift`
- **Purpose**: Define all possible navigation destinations
- **Pattern**: Enum conforming to `ScreenProtocol` with associated values for configuration

#### ViewFactory
- **Location**: `Alfie/Alfie/Navigation/ViewFactory.swift`
- **Purpose**: Instantiate Views with their ViewModels and DependencyContainers
- **Dependency**: Weakly holds ServiceProvider to avoid retain cycles

**Navigation Example**:
```swift
// In Coordinator
public func openProductDetails(productId: String) {
    navigationAdapter.push(.productDetails(configuration: .id(productId)))
}

// In View
Button("View Details") {
    coordinator.openProductDetails(productId: product.id)
}
```

---

## Module Structure (AlfieKit Package)

The project uses Swift Package Manager with a modular architecture in `Alfie/AlfieKit/`:

### Core Modules

- **BFFGraphAPI**: Apollo-generated GraphQL API types (auto-generated, don't edit manually)
- **BFFGraphMocks**: Apollo-generated test mocks for GraphQL (auto-generated, don't edit manually)
- **Common**: Shared utilities, networking, logging, extensions
- **Core**: Services layer (BFF client, authentication, analytics, deep linking, persistence, etc.)
- **Models**: Domain models, view protocols, analytics events (shared between app and packages)
- **Mocks**: Mock implementations for testing (excluded from SwiftLint)
- **Navigation**: Navigation framework protocols (CoordinatorProtocol, ScreenProtocol, etc.)
- **SharedUI**: Localization resources (L10n.xcstrings) and generated strings
- **StyleGuide**: Design system (colors, typography, spacing, reusable components)
- **TestUtils**: Testing utilities (snapshot testing helpers, test schedulers)

### Module Dependencies

- **App target** depends on all modules
- **Models** is the most foundational (minimal dependencies)
- **Core** depends on Models, Common, BFFGraphAPI
- **StyleGuide** depends on Core, Models, Navigation, Common

---

## GraphQL & BFF Integration

### Adding a New Query

1. **Create query file**: `Alfie/AlfieKit/Sources/BFFGraph/CodeGen/Queries/<Feature>/Queries.graphql`
2. **Define fragments**: `Alfie/AlfieKit/Sources/BFFGraph/CodeGen/Queries/<Feature>/Fragments/<Model>Fragment.graphql`
3. **Extend schema**: Add `schema-<feature>.graphqls` in `Alfie/AlfieKit/Sources/BFFGraph/CodeGen/Schema/`
4. **Generate code**: Run `cd Alfie/scripts && ./run-apollo-codegen.sh`
5. **Create local models**: Add domain models in `Alfie/AlfieKit/Sources/Models/Models/`
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

- **Colors**: Use `ThemedColors` from StyleGuide (e.g., `.foreground`, `.accent`, `.background`)
- **Typography**: Use `.themedFont()` modifier with predefined styles
- **Spacing**: Use `Spacing` enum values (`.spacing1` to `.spacing12`)
- **Shadows**: Use `Shadow` enum values (`.shadowLevel1` to `.shadowLevel4`)
- **Corner Radius**: Use `CornerRadius` enum values

**Example**:
```swift
Text("Hello")
    .themedFont(.body)
    .foregroundStyle(ThemedColors.foreground)
    .padding(.spacing4)
```

### Reusable Components

Located in `Alfie/AlfieKit/Sources/StyleGuide/Components/`:

- **Buttons**: `ThemedButton`, various button styles
- **Indicators**: `BadgeViewModifier`, `PaginatedControl`, `ThemedPageControl`
- **Product Cards**: `ProductCardLarge`, `ProductCardSmall`
- **Toolbars**: `Toolbar` with various configurations
- **Loaders**: `LoaderView` with configurable sizes
- **Chips**: `Chip` component
- **Snackbar**: `SnackbarView` with modifier

**Always use existing StyleGuide components** instead of creating custom UI from scratch.

---

## Services & Dependency Injection

### ServiceProvider

- **Location**: `Alfie/Alfie/Service/ServiceProvider.swift`
- **Purpose**: Central registry of all services
- **Access**: Only ViewFactory and top-level app code should access directly
- **Pattern**: Protocol-based services for testability

**Key Services**:
- `BFFClientServiceProtocol`: GraphQL API client
- `AuthenticationServiceProtocol`: User authentication
- `WishlistServiceProtocol`: Wishlist management
- `BagServiceProtocol`: Shopping bag
- `SearchServiceProtocol`: Search functionality
- `RecentsServiceProtocol`: Recent searches
- `DeepLinkServiceProtocol`: Deep linking
- `ConfigurationServiceProtocol`: Feature flags and remote config
- `AlfieAnalyticsTracker`: Analytics events
- `NavigationServiceProtocol`: Navigation state management

### Service Implementation Pattern

Services are located in `Alfie/AlfieKit/Sources/Core/Services/`:

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
- **Views**: `<Feature>View.swift`
- **DependencyContainers**: `<Feature>DependencyContainer.swift`
- **Services**: `<Feature>Service.swift` with `<Feature>ServiceProtocol`
- **Models**: Descriptive names in `Models` module
- **Localization keys**: ReverseDomain + SnakeCase (e.g., `feature.section.item`)

### Code Organization

```
Feature/
├── FeatureView.swift           # SwiftUI View
├── FeatureViewModel.swift      # ViewModel implementation
└── FeatureDependencyContainer.swift  # Dependencies
```

### Preview Pattern

```swift
#if DEBUG
#Preview("Success") {
    FeatureView(viewModel: MockFeatureViewModel(state: .success(mockData)))
        .environmentObject(Coordinator())
}

#Preview("Loading") {
    FeatureView(viewModel: MockFeatureViewModel(state: .loading))
        .environmentObject(Coordinator())
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
- **CoreTests**: Test services and business logic
- **SharedUITests**: Test localization and UI utilities
- **NavigationTests**: Test navigation framework
- **StyleGuideTests**: Test theme and components

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
- **BFF Mocks**: Auto-generated by Apollo in `BFFGraphMocks`
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
- **Navigation** - Entry points, exit points, Coordinator methods
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
2. ✅ **Define Domain Models** in `Alfie/AlfieKit/Sources/Models/Models/<Feature>/`
3. ✅ **Create Service Protocol** in `Alfie/AlfieKit/Sources/Core/Services/<Feature>/`
4. ✅ **Add GraphQL Query** (if API needed):
   - Create `Queries.graphql` in `AlfieKit/Sources/BFFGraph/CodeGen/Queries/<Feature>/`
   - Create fragments in `Fragments/` subdirectory
   - Extend schema in `CodeGen/Schema/schema-<feature>.graphqls`
5. ✅ **Run Apollo Codegen**: `cd Alfie/scripts && ./run-apollo-codegen.sh`
6. ✅ **Create Converters** in `Core/Services/BFFService/Converters/<Feature>+Converter.swift`
7. ✅ **Implement Service** in `Core/Services/<Feature>/`
8. ✅ **Register Service** in `ServiceProvider.swift`
9. ✅ **Create ViewModel Protocol** in `Models/Features/<Feature>ViewModelProtocol.swift`
10. ✅ **Create Mock ViewModel** in `Mocks/Core/Features/Mock<Feature>ViewModel.swift`
11. ✅ **Create DependencyContainer** in `Views/<Feature>/<Feature>DependencyContainer.swift`
12. ✅ **Create ViewModel** in `Views/<Feature>/<Feature>ViewModel.swift`
13. ✅ **Create View** in `Views/<Feature>/<Feature>View.swift`
14. ✅ **NOTIFY USER** to add new files (steps 11-13) to Xcode project (see [Xcode Project File Management](#-xcode-project-file-management))
15. ✅ **Add Screen Case** in `Navigation/Screen.swift`
16. ✅ **Add ViewFactory Case** in `Navigation/ViewFactory.swift`
17. ✅ **Add Coordinator Methods** in `Navigation/Coordinator.swift`
18. ✅ **Add Localization Strings** in `L10n.xcstrings` (all keys from spec)
19. ✅ **Verify** - Execute `./Alfie/scripts/verify.sh` (runs build + tests)
20. ✅ **Verify Against Spec** - Check all acceptance criteria met
21. ✅ **Update Spec Status** - Mark as "Implemented" with PR link and date

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
| Missing imports | Add `import Models`, `import StyleGuide`, etc. |
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

- Files in `AlfieKit/Sources/` and `AlfieKit/Tests/` (Swift Package)
- GraphQL `.graphql` files
- Documentation and scripts

---

## Things to AVOID

❌ Access `ServiceProvider` from ViewModels (use DependencyContainer)  
❌ Hardcode user-facing strings (use `L10n`)  
❌ Bypass Coordinator for navigation  
❌ Edit auto-generated files (`L10n+Generated.swift`, `BFFGraphAPI`, `BFFGraphMocks`)  
❌ Use `fatalError` (use `queuedFatalError`)  
❌ Commit sensitive files unencrypted  
❌ Create custom UI without checking StyleGuide first  
❌ Create ViewModels without protocols  
❌ Edit `project.pbxproj` directly  
❌ Skip build verification

---

## Quick Reference

### Key Directories

```
Alfie/
├── Alfie/                          # Main app target
│   ├── Views/                      # ViewModels, Views, DependencyContainers
│   ├── Navigation/                 # Coordinator, Screen, ViewFactory
│   ├── Service/                    # ServiceProvider
│   └── Configuration/              # App config, URLs, sensitive files
├── AlfieKit/                       # Swift Package
│   ├── Sources/
│   │   ├── BFFGraph/               # GraphQL (queries, schema, codegen)
│   │   ├── Common/                 # Shared utilities
│   │   ├── Core/                   # Services layer
│   │   ├── Models/                 # Domain models
│   │   ├── Mocks/                  # Test mocks
│   │   ├── Navigation/             # Navigation protocols
│   │   ├── SharedUI/               # Localization
│   │   ├── StyleGuide/             # Design system
│   │   └── TestUtils/              # Test helpers
│   └── Tests/                      # Unit tests
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

- [ ] **Architecture**: MVVM pattern, DependencyContainer usage, Coordinator navigation
- [ ] **Localization**: All strings use L10n
- [ ] **State**: ViewState/PaginatedViewState used correctly
- [ ] **Tests**: ViewModels have unit tests, protocols exist for mocking
- [ ] **Security**: No credentials, Keychain for sensitive data, HTTPS only
- [ ] **GraphQL**: Fragments used, codegen run, no edits to generated files
- [ ] **SwiftLint**: No violations

### 🔴 Critical (Block Merge)

- ViewModels accessing `ServiceProvider` directly
- Hardcoded user-facing strings
- Navigation bypassing Coordinator
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
