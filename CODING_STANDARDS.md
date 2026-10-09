# Coding Standards

The index of every document that says how code is written in this repo, plus the review and
security rules, which have no guide of their own. A review checks a diff against all of them.

## Hard rules

`CLAUDE.md` §Critical Rules: the ✅ ALWAYS / ❌ NEVER lists. Any violation blocks merge.

## Fix before merge

- A ViewModel without tests
- A GraphQL query without fragments
- A string missing a translation

## Guides

- `docs/Architecture.md`
- `docs/CodeStyle.md`
- `docs/Testing.md`
- `docs/SnapshotTesting.md`
- `docs/GraphQL.md`
- `docs/Localization.md`
- `docs/Accessibility.md`
- `docs/DesignTokens.md`
- `docs/Iconography.md`

Domain language comes from `GLOSSARY.md`; decisions that constrain the code are in `docs/adr/`.

## Security

Block merge:

- Credentials, API keys or secrets in code
- Sensitive data in UserDefaults rather than the Keychain
- An API call to a remote host over anything but HTTPS
- Sensitive data or PII in logs, Crashlytics or Braze events
- A sensitive file (`GoogleService-Info.plist`) committed outside git-secret
  (`docs/QuickReference.md` §Adding Sensitive Files)

Fix before merge:

- User input or deep-link parameters used without validation
- A GraphQL operation built by string interpolation rather than variables
- Sensitive data in an error message
- Sign-out that leaves user data behind

Fix before merge, once authentication lands:

- A missing authorization check, or auth headers set outside the Apollo client
- A session with no timeout
