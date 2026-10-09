# Coding Standards

The index of every document that says how code is written in this repo, plus the security rules,
which have no guide of their own. A review checks a diff against all of them.

## Hard rules

`CLAUDE.md` §Critical Rules: the ✅ ALWAYS / ❌ NEVER lists. Any violation blocks merge.

## Guides

| Guide | Covers |
|---|---|
| `docs/Architecture.md` | MVVM, Flow navigation, dependency containers, module layout, where each piece of a feature goes |
| `docs/CodeStyle.md` | Naming, file organisation, previews, async/await |
| `docs/Testing.md` | How a unit test, mock or fixture is written |
| `docs/SnapshotTesting.md` | Snapshot device/OS pin, precision, record loop |
| `docs/GraphQL.md` | Queries, fragments, converters, codegen |
| `docs/Localization.md` | `L10n` keys and translations |
| `docs/Accessibility.md` | `AccessibilityID` for UI tests |
| `docs/DesignTokens.md` | Colour, spacing, radius and type values |
| `docs/Iconography.md` | Icons and their mapping |
| `docs/QuickReference.md` | §Code Review Guidelines (merge priorities), §Security & Sensitive Files (git-secret) |

Domain language comes from `GLOSSARY.md`; decisions that constrain the code are in `docs/adr/`.

## Security

Block merge:

- Credentials, API keys or secrets in code
- Sensitive data in UserDefaults rather than the Keychain
- An API call to a remote host over anything but HTTPS
- Sensitive data or PII in logs, Crashlytics or Braze events
- A sensitive file (`GoogleService-Info.plist`) committed outside git-secret

Fix before merge:

- User input or deep-link parameters used without validation
- A GraphQL operation built by string interpolation rather than variables
- A missing authorization check, or auth headers set outside the Apollo client
- Sensitive data in an error message
- Sign-out that leaves user data behind, or a session with no timeout
