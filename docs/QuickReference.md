# Quick Reference

## Common Commands

Build and test commands are in `CLAUDE.md` §Verification; codegen commands are in `GraphQL.md`,
`Localization.md` and `DesignTokens.md`.

```bash
# Install dependencies
brew bundle install

# Decrypt sensitive files (requires GPG keys)
git secret reveal

# Integration tests only (boots a local BFF, runs them, tears it down)
./Alfie/scripts/run-integration-tests.sh
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
