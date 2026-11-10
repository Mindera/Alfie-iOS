# Alfie iOS

Native iOS e-commerce app: SwiftUI (iOS 16+), MVVM with Flow-based navigation, SwiftPM modules in
`AlfieKit/`, a GraphQL BFF through Apollo iOS.

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
- Invoke `/swiftui-specialist` (`.claude/skills/`) when writing or reviewing SwiftUI; gate its API suggestions on this project's deployment target (`@Observable` and `@Entry` don't qualify today) and let the MVVM rules here win on conflict
- Finish every code change on §Verification's "Done"

### ❌ NEVER

| Never | Instead |
|---|---|
| Hand-edit generated code (`L10n+Generated.swift`, `BFFGraph/API/`, `BFFGraph/Mocks/`, `SharedUI/GeneratedTokens/`) | Change the source, then rerun `run-apollo-codegen.sh` / `generate-design-tokens.sh`, or build (`L10n`) |
| Call `fatalError` | Call `queuedFatalError` |
| Edit `Alfie.xcodeproj/project.pbxproj` | Ask the user to make the change in Xcode (new files need none: `docs/Architecture.md` §What Needs Xcode) |
| Commit sensitive files unencrypted | Follow `docs/QuickReference.md` §Adding Sensitive Files (`git secret`) |

---

## Verification

| Check | Run | When |
|---|---|---|
| Typecheck | `./Alfie/scripts/build-for-verification.sh` | While editing |
| A single test file | `./Alfie/scripts/verify.sh --only-unit --filter <Target>[/<Class>]` | After each slice |
| The full test suite | `./Alfie/scripts/verify.sh` | Once, before calling the work done |

`verify.sh` builds once, then runs unit tests (mocked BFF), then the `AlfieIntegration` and
`AlfieUI` test plans against the **Mock BFF**, which it installs, builds (yarn) and boots itself on
port 3000 with `PLATFORM=mock`, overriding the BFF's `.env`. It needs Node, yarn and the `Alfie-BFF`
repo beside this one; from a worktree, point `ALFIE_BFF_PATH` at it. `--only-unit` drops the
integration and UI stage. Integration tests pin only to `SeedAnchors` (`TestSeed` module).

Keep `Alfie-BFF` on an up-to-date `main`: `verify.sh` warns, without touching it, when the checkout
is behind `origin/main` or on another branch. A Live BFF is opt-in only, by overriding the start
command (`ALFIE_BFF_START_CMD`); the Mock-only skips then run, unless `ALFIE_BFF_PLATFORM=mock`.

Done means an unfiltered `verify.sh` prints **"✅ FULL VERIFICATION PASSED"**. Only when Node, yarn
or `Alfie-BFF` is unavailable: an unfiltered `--only-unit` run printing
**"✅ VERIFICATION PASSED (... integration and UI skipped)"**, reported as integration and UI skipped. A
`prototype/*` branch follows `docs/agents/prototype.md` §Done instead.

Run one verification at a time: the scripts write to fixed `/tmp/alfie_*` paths, so parallel runs
(including from another worktree) clobber each other.

---

## Detailed Documentation

| Read | When |
|---|---|
| `docs/Architecture.md` | Adding a ViewModel, Flow, Route or feature module; deciding where a new file goes |
| `docs/GraphQL.md` | Touching `.graphql` files, after a BFF schema change, or a physical iPhone can't reach the Mac's BFF |
| `docs/Localization.md` | Adding or renaming an `L10n` key |
| `docs/Testing.md` | Writing or reviewing unit tests, mocks or fixtures; reading coverage from `/tmp/alfie_test.xcresult` |
| `docs/SnapshotTesting.md` | A view's rendered output changes, or a snapshot test fails |
| `docs/Accessibility.md` | Adding UI that a UI test will target |
| `docs/DesignTokens.md` | Picking a colour, spacing, radius or type value; refreshing tokens |
| `docs/Iconography.md` | Adding or re-mapping an icon |
| `docs/CodeStyle.md` | Naming a type or file; writing a `#Preview` |
| `docs/QuickReference.md` | Setting up a checkout (`brew bundle`, `git secret reveal`) |

---

## Agent skills

The `mattpocock-skills` plugin is pinned in `.claude/settings.json`; install it once per checkout
(`docs/QuickReference.md` §Common Commands). Project skills live in `.claude/skills/`.

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

A `/research` note is `research/<name>.md` on a pushed `research/<name>` branch, with a pointer on the issue that asked for it, never on `main` (ADR-0005).
