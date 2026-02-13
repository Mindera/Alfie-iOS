# Code Style & Best Practices

## SwiftLint Rules

- **Configuration**: `Alfie/.swiftlint.yml`
- **Trailing commas**: Mandatory
- **Function body length**: Max 200 lines
- **Type body length**: Max 400 lines
- **Identifier names**: Min 2 characters, start with lowercase
- **Fatal errors**: Use `queuedFatalError` instead of `fatalError` (custom rule)

## Naming Conventions

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

## Code Organization (Feature Module)

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

## Preview Pattern

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

## Async/Await Pattern

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
