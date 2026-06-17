# Red-Team Review — ALFMOB-335 BFF Integration Tests

Adversarial review of the plan, grounded in the actual repo. Findings ordered by severity.
Status after review: **needs-rework → fixes folded into plan.md + phase files (see "Resolution" tags).**

---

### [BLOCKER] Harness passes `String` where `BFFClientService` requires `Foundation.URL`
Phase 1 constructed `BFFClientService(url: baseURL, ...)` with `baseURL` a `String`. Real init is
`init(url: Foundation.URL, sessionConfiguration:logRequests:dependencies:log:)`
(`BFFClientService.swift:20`). Won't compile. Production call site `ServiceProvider.swift:84` uses
`url:logRequests:dependencies:log:`.
**Fix:** `guard let url = URL(string: raw) else { throw XCTSkip(...) }`; call
`BFFClientService(url: url, logRequests: false, dependencies:..., log: Log.DummyLogger())`.
**Resolution:** folded into phase-1.

### [BLOCKER] Base-URL semantics: `/graphql` is appended internally — env default must NOT include it
`endpointURL = url.appending(path: "graphql")` (`BFFClientService.swift:48`). If
`ALFIE_BFF_BASE_URL=http://localhost:3000/graphql`, client POSTs to `…/graphql/graphql` → 404.
Base URL must be the **origin** `http://localhost:3000`; the service owns `/graphql`. Three places
(env default, in-test probe, script poll) must agree.
**Fix:** pin the invariant; probe/poll derive `/graphql` the same way the service does.
**Resolution:** folded into plan Approach + phase-1 + phase-3.

### [HIGH] `XCTSkip` from sync `setUp` won't await; need `setUp() async throws`
A `URLSession` probe is async; `setUpWithError()` is sync. Must use `override func setUp() async throws`.
(`XCTSkip` from async setUp IS honored.) Also: `swift test` can't run this package at all (iOS-only
deps), so the "swift test hard-fails" risk is moot — the real exposure is an xcodebuild full-scheme run,
handled by test-plan exclusion.
**Resolution:** phase-1 specifies `setUp() async throws`; risk-table wording corrected.

### [HIGH] `-only-testing:BFFIntegrationTests` fails when target is in no test plan
Scheme default plan is `Alfie.xctestplan` (13 targets, none is the new one). `-only-testing` selects
*within the active plan*; a target in no plan isn't selectable → runs nothing. So Phase 1's verification
command can't run until the Phase 3 plan exists. **Phases not independently verifiable as ordered.**
**Fix:** move dedicated test-plan creation + scheme registration into Phase 1; standardize on
`-testPlan AlfieIntegration` everywhere; drop the `-only-testing`-without-plan fallback (doesn't work).
**Resolution:** phases reordered (plan + phase-1 now own the test plan; phase-3 references it).

### [HIGH] No repo precedent boots a Node BFF; `sync-bff-schema.sh` only copies SDL
`sync-bff-schema.sh:39` git-checkouts the sibling repo and copies schema — never runs `npm`/`node`.
So `npm run start:dev` + installed deps are unverified assumptions.
**Fix:** confirm real boot command + prereqs with BFF team; add `npm ci`/`node_modules` detection +
clear error if Node missing; don't claim convention reuse that doesn't exist.
**Resolution:** phase-3 + Open Q #1 updated; flagged as must-confirm.

### [HIGH] `trap … kill $PID` orphans child Node procs; :3000 stays occupied
`npm run start:dev` spawns npm → shell → node; killing `$!` leaves the grandchild on :3000. Next run
fails readiness or tests a stale server.
**Fix:** run in own process group, kill the group: `npm run start:dev & BFF_PGID=$!;
trap 'kill -- -$BFF_PGID 2>/dev/null' EXIT`. Pre-flight: fail fast if :3000 already LISTEN.
**Resolution:** phase-3 teardown rewritten.

### [MEDIUM] Readiness poll `200/400` heuristic is fragile
GraphQL GET may return 200 (landing page), 404, or 405; 400 also matches strangers on the port.
**Fix:** probe with POST `{"query":"{__typename}"}`, require HTTP 200 + JSON body with `data`/`errors`.
Use the same probe in-test.
**Resolution:** phase-1 + phase-3 updated.

### [MEDIUM] Apollo `InMemoryNormalizedCache` poisoning across tests
Each `BFFClientService` builds its own cache (`BFFClientService.swift:37`); a shared SUT lets
`CacheReadInterceptor` serve stale page-1/details to later tests → false passes on pagination/sort/filter.
Phase 2's "reuse SUT (DRY)" pushed toward the dangerous shared instance.
**Fix:** build a **fresh** `BFFClientService` per test in `setUp() async throws`; vary query args.
**Resolution:** phase-1 + phase-2 updated.

### [MEDIUM] CI job structurally incapable of failing
`continue-on-error: true` + `XCTSkip` when BFF down + non-blocking → job can skip every test and stay
green, testing nothing.
**Fix:** `workflow_dispatch`/label-gated rather than continue-on-error on every PR; fail if 0 tests
executed (all-skipped = CI failure even if non-blocking for merge).
**Resolution:** phase-4 updated.

### [MEDIUM] `unknownHandle` asserts a non-deterministic error sub-type
Unknown handle may throw `.product(.noProduct)` (null path, `BFFClientService.swift:99`), `.generic`
(GraphQL errors), or `.serverError`/`.timeout` — depends on un-contracted BFF behavior.
**Fix:** assert only `error is BFFRequestError` (don't pin sub-type), or drop (it tests BFF, not client;
client null-handling already unit-tested).
**Resolution:** phase-2 updated.

### [MEDIUM] Shape assertions too weak / seed-dependent
"Non-empty" only holds with seed data the plan says isn't contracted; pagination test assumes ≥2 pages
+ `hasNextPage`.
**Fix:** anchor on a known-stable handle — code already hardcodes real Shopify handles in `getHeaderNav`
(`women`, `men`, `frontpage`, `womens-tops`, `BFFClientService.swift:65`). Use one as contract anchor;
`XCTSkipUnless(!products.isEmpty)`; skip pagination if page-1 `hasNextPage == false`.
**Resolution:** phase-2 updated.

### [LOW] Chaining uses `slug`, not "handle"
`Product` has `slug` (`Product.swift:19`), no `handle`; `getProduct(handle:)` resolves by slug
(commit f47b847). Pass `product.slug` as `handle:`.
**Resolution:** phase-2 wording fixed.

### [LOW] `variants` assertion over-strict
`variants: [Variant]` non-optional + `defaultVariant` always present, but `colours: [Colour]?` optional.
**Fix:** assert `!variants.isEmpty` + `defaultVariant` present; don't require colour+size on every variant.
**Resolution:** phase-2 updated.

### [LOW] Over-engineering: dual test-plan/`-only-testing` path
`-testPlan` resolves by name among the scheme's registered plans, so a plan not in the scheme isn't
runnable via `-testPlan` either. The two "fallback" paths are mutually exclusive.
**Fix:** register the plan in the scheme once (accept one-time churn); always drive via `-testPlan`;
drop the `-only-testing`-without-plan fallback. Note: `HomeTests`/`MyAccountTests`/`UtilsTests` already
prove an SPM test target absent from the plan is neither run by fastlane nor `verify.sh`.
**Resolution:** Open Q resolved to "edit scheme"; fallback removed.

### [LOW] Does a new `.testTarget` break `build-for-testing`?
`build-for-testing` builds the plan's targets, not all SPM targets (existing out-of-plan test targets
prove this). BUT xcodebuild still resolves all of Package.swift — a malformed entry/cycle/name-collision
breaks every job.
**Fix:** after editing Package.swift, run `verify.sh` AND confirm `grep BFFIntegrationTests` is empty in
the build-for-testing log (target not built).
**Resolution:** phase-1 verification updated.

---

## Top 3 must-fix before execute
1. **Phase ordering / `-only-testing` unrunnability** — test plan into Phase 1; standardize on `-testPlan`.
2. **Compile + URL semantics** — pass `Foundation.URL`; base URL = origin, `/graphql` appended by service only.
3. **BFF boot/teardown realism** — confirm real `start:dev` + `npm ci`; kill by process group; GraphQL POST readiness probe.

## Verdict
**Needs-rework → resolved.** Core architecture is sound and the isolation thesis is verifiable
(`HomeTests`/`MyAccountTests`/`UtilsTests` already prove out-of-plan SPM test targets don't leak into the
unit run). The blockers were harness-level (didn't typecheck, ambiguous URL contract), the HIGHs were
ordering + script realism. All folded into the plan; executable-with-fixes once Open Q #1 (CI BFF boot)
is confirmed with the BFF team.
