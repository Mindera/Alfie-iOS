# Quick Reference

## Key Directories

```
Alfie/
├── Alfie/                          # Main app target (minimal code)
│   ├── Views/                      # App-specific views (Info only)
│   ├── Service/                    # ServiceProvider
│   ├── Delegate/
│   └── Configuration/              # App config, URLs, sensitive files
├── AlfieKit/                       # Swift Package
│   ├── Sources/                    # One folder per module; feature modules are unlabelled below
│   │   ├── AccessibilityIdentifiers/
│   │   ├── AppFeature/             # App shell, tab bar, root navigation
│   │   ├── BFFGraph/               # GraphQL (queries, schema, codegen)
│   │   ├── Bag/
│   │   ├── CategorySelector/       # Shop tab
│   │   ├── Core/                   # Services layer
│   │   ├── DebugMenu/              # DEBUG only
│   │   ├── DeepLink/
│   │   ├── Home/
│   │   ├── Mocks/                  # Mocks and fixtures; a production target
│   │   ├── Model/                  # Domain models, protocols
│   │   ├── MyAccount/
│   │   ├── ProductDetails/
│   │   ├── ProductListing/
│   │   ├── Scanner/
│   │   ├── Search/
│   │   ├── SharedUI/               # Localization, theme, components
│   │   ├── TestUtils/
│   │   ├── Utils/
│   │   ├── Web/
│   │   └── Wishlist/
│   └── Tests/                      # Unit tests, one target per module
└── scripts/                        # verify/build/test, Apollo codegen, design-token pipeline

Tools/                              # Standalone SwiftPM tools, outside the AlfieKit graph
└── DesignTokenGen/                 # Design-token → Swift code generator
```

## Common Commands

Build and test commands are in `CLAUDE.md` §Verification.

```bash
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

# Refresh design tokens (pull upstream JSON, then regenerate the committed Swift)
./Alfie/scripts/pull-design-tokens.sh && ./Alfie/scripts/generate-design-tokens.sh
```

## Key Dependencies

`Alfie/AlfieKit/Package.resolved` is authoritative for versions. What each one is for:

- **Apollo iOS**: GraphQL client
- **Firebase**: Analytics, Crashlytics, Remote Config
- **Braze**: Marketing automation
- **Nuke**: Image loading/caching
- **Alicerce**: Utilities, logging
- **SwiftGen**: Code generation for resources (Mindera fork)
- **swift-snapshot-testing**: Snapshot tests

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

## Additional Context

- **Minimum iOS**: 16.0
- **Swift Version**: 5.9+
- **Backend**: the BFF (`Alfie-BFF` repo) on `localhost:3000`. The older Alfie-Mocks server on
  `localhost:4000` is legacy — reachable via the `dev` toggle in `ApiEndpointService`, not the default.
