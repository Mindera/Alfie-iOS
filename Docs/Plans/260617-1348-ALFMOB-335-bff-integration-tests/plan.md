---
title: BFF integration test suite against local BFF
ticket: ALFMOB-335
status: in-progress   # Phases 1-3 implemented; Phase 4 (CI+docs) deferred pending Open Q #1
complexity: HIGH
mode: auto
blockedBy: []   # ALFMOB-330 (port + setup) is Done
blocks: []
created: 2026-06-17
---

## Overview
Add a thin integration test layer that exercises the **real** `BFFClientService` over HTTP
against a locally-running BFF (`http://localhost:3000`). Covers `productList`, `getProduct`
(product details) and `searchProducts`. Adds a new SPM test target, a dedicated test plan
(kept out of the hermetic unit run), an orchestration script that boots/waits/tears-down the
BFF, a non-blocking CI job, and docs. **Unit tests and `MockBFFClientService` are untouched.**

## Acceptance Criteria
- [x] `BFFIntegrationTests` target exists, tests `productList`, `getProduct`, `searchProducts`
      against a running BFF. _(Phase 1-2; compiles via AlfieKit-Package build; live run needs a BFF.)_
- [x] A script boots the BFF locally, runs the integration tests, tears the BFF down —
      runnable on a developer machine. _(Phase 3: `Alfie/scripts/run-integration-tests.sh`; boot cmd TBD, Open Q #1.)_
- [ ] A CI job runs the integration script and reports results (opt-in / non-blocking initially). _(Phase 4 — deferred.)_
- [ ] README / Docs document the local integration loop. _(Phase 4 — deferred.)_

## Approach
**Reuse, don't reinvent.** The service endpoint is already injectable
(`BFFClientService(url:logRequests:dependencies:log:)`, [BFFClientService.swift:20](../../../Alfie/AlfieKit/Sources/Core/Services/BFFService/BFFClientService.swift);
production call shape at [ServiceProvider.swift:84](../../../Alfie/AlfieKit/Sources/Core/Services/ServiceProvider.swift)),
so the test just constructs the real service pointed at localhost — no production code change.

**URL contract (critical, from red-team).** `url:` must be a `Foundation.URL` and the **origin only**
(`http://localhost:3000`). The service appends `/graphql` internally
(`endpointURL = url.appending(path: "graphql")`, [BFFClientService.swift:48](../../../Alfie/AlfieKit/Sources/Core/Services/BFFService/BFFClientService.swift)).
`ALFIE_BFF_BASE_URL` therefore must NOT contain `/graphql`. The in-test readiness probe and the
script's readiness poll both derive `/graphql` the same way — three references, one invariant.
Required collaborators already exist and are reused: `MockReachabilityService` (defaults
reachable) and the real `NetworkClient` (REST client is unused by GraphQL ops but required by
the container). Logger = `Log.DummyLogger()`. ALFMOB-330 (Done) confirms the epic is
**guest-only with no client-supplied headers/commerce-platform selector**, so the stock
`BFFClientService` interceptor chain needs no auth setup for these tests.

**Keep the unit run hermetic.** The integration target is added to `Package.swift` but is
**NOT** added to `Alfie.xctestplan`, so the existing `unit-tests` job (fastlane `scan` →
`Alfie` test plan) never builds or runs it. Verified precedent: `HomeTests`, `MyAccountTests`,
`UtilsTests` already exist as SPM test targets absent from `Alfie.xctestplan` and are run by
neither fastlane nor `verify.sh`. A dedicated `AlfieIntegration.xctestplan` (only
`BFFIntegrationTests`) is **registered in the `Alfie` scheme** (Phase 1) and driven via
`xcodebuild ... -testPlan AlfieIntegration`. Note (red-team): `-testPlan` resolves by name among
the scheme's registered plans, and `-only-testing` selects only *within* the active plan — so a
target in no plan is unrunnable by either. The plan must exist and be scheme-registered before
the target can run; there is **no `-only-testing`-without-plan fallback**.

**Fail-soft when the BFF is absent.** Tests read base URL from env (`ALFIE_BFF_BASE_URL`,
default `http://localhost:3000`) and `XCTSkip` when the endpoint is unreachable, so an
accidental full-package run never hard-fails on a missing server. The script sets the env and
guarantees readiness before running.

**Assert on shape, not seed values.** Local BFF seed data is not contracted by this ticket,
so assertions check structural invariants (non-empty results, pagination cursor present after
first page, variants surface on details, sort/filter return well-formed pages) rather than
exact product values.

## Phases
1. **Foundation** — SPM target + **dedicated test plan + scheme registration** + test harness
   (fresh real service per test, `Foundation.URL` origin, `setUp() async throws` skip guard).
   _Test plan moved here (from Phase 3) so the target is runnable & Phase 1 is verifiable._
2. **Coverage** — the three operations: happy path, pagination, sort, filter, variants.
3. **Orchestration** — `run-integration-tests.sh` (boot in process-group, GraphQL-POST readiness,
   group-kill teardown). _Test plan/scheme already done in Phase 1._
4. **CI + Docs** — dispatch/label-gated `integration-tests` job (fails on 0 tests run) + docs.

## File Changes (Summary Table)
| File | Module | Type | Change | Owner |
|---|---|---|---|---|
| `Alfie/AlfieKit/Package.swift` | AlfieKit | Edit | Add `BFFIntegrationTests` `.testTarget` (deps: Core, Model, Mocks, TestUtils) | - |
| `Alfie/AlfieKit/Tests/BFFIntegrationTests/IntegrationTestCase.swift` | BFFIntegrationTests | New | Base case: builds real `BFFClientService`, env base URL, readiness/skip guard | - |
| `Alfie/AlfieKit/Tests/BFFIntegrationTests/ProductListIntegrationTests.swift` | BFFIntegrationTests | New | `productList` happy / pagination / sort / filter | - |
| `Alfie/AlfieKit/Tests/BFFIntegrationTests/ProductDetailsIntegrationTests.swift` | BFFIntegrationTests | New | `getProduct` happy / variants surface | - |
| `Alfie/AlfieKit/Tests/BFFIntegrationTests/SearchIntegrationTests.swift` | BFFIntegrationTests | New | `searchProducts` happy / pagination | - |
| `Alfie/Alfie/AlfieIntegration.xctestplan` | app | New | Test plan containing only `BFFIntegrationTests` | - |
| `Alfie/Alfie.xcodeproj/xcshareddata/xcschemes/Alfie.xcscheme` | app | Edit | Register `AlfieIntegration` test plan in TestAction (NOT pbxproj) | - |
| `Alfie/scripts/run-integration-tests.sh` | scripts | New | Boot BFF → wait `/graphql` → run plan → teardown on exit | - |
| `.github/workflows/alfie.yml` | CI | Edit | Add non-blocking `integration-tests` job | - |
| `Docs/Testing.md` | docs | Edit | Add "Integration suite" section | - |
| `README.md` | docs | Edit | Local integration loop (sibling BFF, run script, expected output) | - |

## Feature Flag
n/a (`feature_flags` exist but this is test infra — no app-runtime behavior changes).

## Testing Strategy
- **Unit / Snapshot**: unchanged.
- **Integration (new)**: real `BFFClientService` → localhost BFF; shape-based asserts; async
  `await` calls; `XCTSkip` when endpoint down. No accessibility ids (no UI surface).
- **Verification**: `./Alfie/scripts/verify.sh` must still pass (proves unit run unaffected —
  integration target not in `Alfie.xctestplan`). Integration run verified via the new script.

## Risks & Mitigations
| Risk | Likelihood | Mitigation |
|---|---|---|
| Integration target leaks into unit `unit-tests` job | Med | Do NOT add to `Alfie.xctestplan`; verify unit run count unchanged |
| BFF boot slow/flaky in CI | High | Job non-blocking (`continue-on-error`) + readiness poll w/ timeout; gate on label/dispatch |
| BFF repo unavailable in CI | High | Script reuses sibling-repo convention (`$ALFIE_BFF_PATH`/`../Alfie-BFF`); CI checks out BFF or skips |
| Seed data differs across runs | Med | Anchor on stable handle (`women`/`frontpage` from `getHeaderNav`); `XCTSkipUnless` non-empty |
| xcodebuild full-scheme run hits the suite with no server | Med | `XCTSkip` in `setUp() async throws` when `/graphql` unreachable (note: `swift test` can't run this package — iOS-only deps) |
| Apollo `InMemoryNormalizedCache` poisons cross-test asserts | Med | Build a fresh `BFFClientService` per test |

## Out of Scope
- Replacing unit tests / `MockBFFClientService` (stay mocked).
- Snapshot tests against integration data; perf/load testing; simulator UI E2E.

## Resolved (ALFMOB-330, Done)
- Base URL is `http://localhost:3000/graphql` (final). Epic is guest-only; no client headers/
  commerce-platform selector → stock `BFFClientService` is sufficient for these tests.

## Open Questions
1. **CI BFF provisioning (must-confirm before Phase 4)** — `sync-bff-schema.sh` only copies the SDL;
   nothing in this repo boots a Node BFF. Need from the BFF team: the real local-run command
   (`npm run start:dev`? `yarn`? docker?), required `npm ci`/`.env` prereqs, and whether CI can check
   out + run `Alfie-BFF` or the job stays `workflow_dispatch`-only initially.
2. **Detail method name** — protocol exposes `getProduct(handle:)`, not `productDetails`; tests
   target `getProduct` (resolves by `slug`). Confirm acceptable wording for AC.

## Resolved by red-team
- **Test plan vs scheme edit** → register `AlfieIntegration.xctestplan` in the shared `Alfie.xcscheme`
  (one-time churn accepted). No `-only-testing`-without-plan fallback (xcodebuild won't run it).
- **URL contract** → `Foundation.URL`, origin only; service appends `/graphql`.
- **Cache poisoning** → fresh `BFFClientService` per test.
- See [red-team.md](red-team.md) for the full findings + resolutions.
