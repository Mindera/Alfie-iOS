# Alfie iOS

**Alfie** is a native iOS e-commerce application built with:
- **SwiftUI** (iOS 16+)
- **MVVM Architecture** with Flow-based navigation
- **Swift Package Manager** modular structure (`AlfieKit/`)
- **GraphQL BFF API** (Apollo iOS client)

---

## Critical Rules

### ✅ ALWAYS

- Use `ViewState<Value, Error>` or `PaginatedViewState<Value, Error>` enums for state
- Inject dependencies via `DependencyContainer`; `ServiceProvider` is reached only by app-level code and the `AppFeature` ViewModels that wire the app graph
- Use `L10n` for every user-facing string (keys live in `L10n.xcstrings`)
- Define a protocol for every ViewModel, so it can be mocked
- Route all navigation through `FlowViewModel` closures passed into the `ViewModel`
- Use `AccessibilityID` from the `AccessibilityIdentifiers` module for every UI test identifier (see `Docs/Accessibility.md`)
- Reach for existing `SharedUI` components before writing a new view
- Run `./Alfie/scripts/verify.sh` after every code change, and finish on a pass

### ❌ NEVER

| Never | Instead |
|---|---|
| Hand-edit generated code (`L10n+Generated.swift`, `BFFGraph/API/`, `BFFGraph/Mocks/`, `SharedUI/GeneratedTokens/`) | Change the source, then rerun `run-apollo-codegen.sh` / `generate-design-tokens.sh` |
| Call `fatalError` | Call `queuedFatalError` |
| Edit `Alfie.xcodeproj/project.pbxproj` | Ask the user to add the file through Xcode |
| Commit sensitive files unencrypted | `git secret add` then `git secret hide` |

---

## Verification

```bash
./Alfie/scripts/verify.sh                     # build + unit + integration (boots a local BFF)
./Alfie/scripts/verify.sh --skip-integration  # build + unit only (fast, no BFF/Node needed)
```

By default this runs build + unit tests (mocked BFF) + integration tests against a real local BFF
(see `run-integration-tests.sh`, needs Node + the `Alfie-BFF` repo). Use `--skip-integration` for
the fast unit-only loop. Only mark work complete after **"✅ FULL VERIFICATION PASSED"** (or
**"✅ VERIFICATION PASSED (... integration skipped)"** when skipped).

An unfiltered run leaves a coverage bundle at `/tmp/alfie_test.xcresult`, with a sidecar recording
which commit it describes — see `Docs/Testing.md` §Code Coverage before reading it.

---

## Detailed Documentation

Read the guide when its trigger fires:

| Read | When |
|---|---|
| `Docs/Architecture.md` | Adding a ViewModel, Flow, Route or feature module |
| `Docs/Development.md` | Starting a feature from a spec |
| `Docs/GraphQL.md` | Touching `.graphql` files, or after a BFF schema change |
| `Docs/Localization.md` | Adding or renaming an `L10n` key |
| `Docs/Testing.md` | Writing unit tests, mocks or fixtures |
| `Docs/SnapshotTesting.md` | A view's rendered output changes, or a snapshot test fails |
| `Docs/Accessibility.md` | Adding UI that a UI test will target |
| `Docs/DesignTokens.md` | Picking a colour, spacing, radius or type value; refreshing tokens |
| `Docs/Iconography.md` | Adding or re-mapping an icon |
| `Docs/CodeStyle.md` | Naming and formatting questions |
| `Docs/QuickReference.md` | Commands, directory layout, dependency versions |
| `Docs/Specs/TEMPLATE.md` | Writing a new feature spec |

---

## Agent skills

| Topic | Guide |
|---|---|
| Jira (`ALFMOB`) for team tickets, GitHub Issues for agent-generated work | `Docs/agents/issue-tracker.md` |
| The five canonical triage labels, applied on GitHub Issues | `Docs/agents/triage-labels.md` |
| Domain vocabulary and ADRs (single-context repo; both created lazily) | `Docs/agents/domain.md` |

## Agent definitions

Role-scoped prompts live in `.ai/agents/<name>.agent.md` — `feature-orchestrator`, `spec-writer`,
`graphql-specialist`, `feature-developer`, `localization-specialist`, `testing-specialist`,
`security-specialist`. Read one when the user names it; they are not auto-loaded.
