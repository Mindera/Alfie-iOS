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
- Use `AccessibilityID` from the `AccessibilityIdentifiers` module for every UI test identifier
- Reach for existing `SharedUI` components before writing a new view
- Invoke `/swiftui-specialist` when writing or reviewing SwiftUI; gate its API suggestions on this project's deployment target (`@Observable` and `@Entry` don't qualify today) and let the MVVM rules here win on conflict
- Finish every code change on a passing `./Alfie/scripts/verify.sh` (cadence in §Verification)

### ❌ NEVER

| Never | Instead |
|---|---|
| Hand-edit generated code (`L10n+Generated.swift`, `BFFGraph/API/`, `BFFGraph/Mocks/`, `SharedUI/GeneratedTokens/`) | Change the source, then rerun `run-apollo-codegen.sh` / `generate-design-tokens.sh` |
| Call `fatalError` | Call `queuedFatalError` |
| Edit `Alfie.xcodeproj/project.pbxproj` (only a new file under `Alfie/Alfie/` needs it) | Ask the user to add the file through Xcode (`docs/Architecture.md` §Files That Need Xcode) |
| Commit sensitive files unencrypted | Follow `docs/QuickReference.md` §Adding Sensitive Files (`git secret`) |

---

## Verification

| Check | Run | When |
|---|---|---|
| Typecheck | `./Alfie/scripts/build-for-verification.sh` | While editing |
| A single test file | `./Alfie/scripts/verify.sh --skip-integration --filter <Target>[/<Class>]` | After each slice |
| The full test suite | `./Alfie/scripts/verify.sh` | Once, before calling the work done |

`verify.sh` runs build + unit tests (mocked BFF) + integration tests against a local BFF it boots
itself, which needs Node and the `Alfie-BFF` repo beside this one; from a worktree, point
`ALFIE_BFF_PATH` at it. `--skip-integration` drops the integration stage.

Done means the output ends **"✅ FULL VERIFICATION PASSED"**, or
**"✅ VERIFICATION PASSED (... integration skipped)"** when skipped.

Run one verification at a time: the scripts write to fixed `/tmp/alfie_*` paths, so parallel runs
(including from another worktree) clobber each other.

---

## Detailed Documentation

| Read | When |
|---|---|
| `docs/Architecture.md` | Adding a ViewModel, Flow, Route or feature module; deciding where a new file goes |
| `docs/GraphQL.md` | Touching `.graphql` files, or after a BFF schema change |
| `docs/Localization.md` | Adding or renaming an `L10n` key |
| `docs/Testing.md` | Writing or reviewing unit tests, mocks or fixtures; reading coverage from `/tmp/alfie_test.xcresult` |
| `docs/SnapshotTesting.md` | A view's rendered output changes, or a snapshot test fails |
| `docs/Accessibility.md` | Adding UI that a UI test will target |
| `docs/DesignTokens.md` | Picking a colour, spacing, radius or type value; refreshing tokens |
| `docs/Iconography.md` | Adding or re-mapping an icon |
| `docs/CodeStyle.md` | Naming a type or file; writing a `#Preview` or async call |
| `docs/QuickReference.md` | Adding a sensitive file; running codegen or setup commands |

---

## Agent skills

### Issue tracker

Jira (`ALFMOB`) owns what to build; specs and tickets are GitHub issues derived from it. See `docs/agents/issue-tracker.md`.

### Triage labels

The five default labels, applied on GitHub issues. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `GLOSSARY.md` at the root, ADRs in `docs/adr/`. See `docs/agents/domain.md`.

### Coding standards

Reviewing a diff: check it against `CODING_STANDARDS.md` at the root, the index of every guide plus the review and security rules.

### Prototypes

Before `/prototype` builds anything, read `docs/agents/prototype.md`: it replaces the skill's web artifacts with a Debug Menu screen or a Swift script.

### Research

A `/research` note lives on a pushed `research/<name>` branch with a pointer on the issue that asked for it, never on `main` (ADR-0005).
