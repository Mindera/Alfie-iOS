# Quick Reference

## Key Directories

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

## Common Commands

```bash
# Full verification (build + unit + integration) - ALWAYS RUN AFTER CODE CHANGES
./Alfie/scripts/verify.sh

# Fast unit-only run (no local BFF / Node needed)
./Alfie/scripts/verify.sh --skip-integration

# Integration tests only (boots a local BFF, runs them, tears it down)
./Alfie/scripts/run-integration-tests.sh

# Decrypt sensitive files (requires GPG keys)
git secret reveal

# Install dependencies
brew bundle install

# Generate GraphQL code
cd Alfie/scripts && ./run-apollo-codegen.sh

# Generate localization code (automatic on build, or manually)
swift package --allow-writing-to-package-directory generate-code-for-resources
```

## Key Dependencies

- **Apollo iOS**: GraphQL client (v1.19.0)
- **Firebase**: Analytics, Crashlytics, Remote Config (v11.11.0)
- **Braze**: Marketing automation (v11.9.0)
- **Nuke**: Image loading/caching (v12.8.0)
- **Alicerce**: Utilities, logging (v0.18.0)
- **SwiftGen**: Code generation for resources (v6.6.4-mindera fork)
- **Snapshot Testing**: UI testing (v1.18.3)

## Code Review Guidelines

### PR Review Checklist

- [ ] **Architecture**: MVVM pattern, DependencyContainer usage, FlowViewModel navigation
- [ ] **Localization**: All strings use L10n
- [ ] **State**: ViewState/PaginatedViewState used correctly
- [ ] **Tests**: ViewModels have unit tests, protocols exist for mocking
- [ ] **Accessibility IDs**: New UI elements use `AccessibilityID` from `AccessibilityIdentifiers` (see `Docs/Accessibility.md`)
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

## Additional Context

- **Minimum iOS**: 16.0
- **Swift Version**: 5.9+
- **Mock Server**: Separate Alfie-Mocks repo runs locally on localhost:4000
- **CI/CD**: Work in progress
- **Release Process**: Work in progress
