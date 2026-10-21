# Code Style & Best Practices

## SwiftLint Rules

- **Configuration**: `Alfie/.swiftlint.yml`
- **Trailing commas**: Mandatory
- **Function body length**: Max 200 lines
- **Type body length**: Max 400 lines
- **Identifier names**: Min 2 characters, start with lowercase
- **Fatal errors**: Use `queuedFatalError` instead of `fatalError` (custom rule)
- **TODOs**: Don't leave `TODO` comments; open a GitHub issue instead (the `todo` rule flags them)

### Running SwiftLint

`Alfie/scripts/lint.sh` is the lint command the pre-commit hook and CI share. It always runs strict
(a warning fails) with the committed binary `Alfie/Tools/swiftlint` (pinned at 0.54.0, never one on
`PATH`), and exits non-zero if that binary is missing or not executable.

```bash
# Once per clone: point git at the versioned hooks in .githooks/ (safe to rerun)
./Alfie/scripts/install-git-hooks.sh

# Whole repo, scoped by the config's included/excluded
./Alfie/scripts/lint.sh

# Staged Swift files only, as the pre-commit hook runs it
./Alfie/scripts/lint.sh --staged

# Autocorrect, then report what's left
./Alfie/scripts/lint.sh --fix
```

The pre-commit hook lints the staged content of staged Swift files inside the config's scope. It
only reports: it never modifies files. When it blocks a commit, run `--fix`, fix the rest by hand
from the printed `file:line:col: error: … (rule_id)` list, restage and commit again.
`git commit --no-verify` skips the hook, because CI is the real gate: the `lint` job
(`.github/workflows/lint.yml`) runs this script on the whole repo for every PR, merge queue entry
and push to `main`, with no override. Until #194 removes it, the Xcode build phase also runs
SwiftLint, non-strict and outside this script.

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

See [Architecture.md](Architecture.md#feature-module-structure).

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

**Important**: Previews should be wrapped with `#if DEBUG`. The `debug_Mocks` custom rule only
catches a bare `#Preview` line straight after a closing `}`, so check this in review.

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
