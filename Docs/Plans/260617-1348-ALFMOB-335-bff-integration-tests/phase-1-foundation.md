## Phase 1: Foundation — target + test plan + harness

### Goal
Stand up the `BFFIntegrationTests` SPM target, a dedicated **runnable** test plan, and a base test
case that constructs a **fresh** real `BFFClientService` per test against an env-configured origin
URL, skipping cleanly when the BFF is down.

> Red-team fix: the test plan + scheme registration live HERE (not Phase 3) — without them the target
> is unrunnable (`-only-testing`/`-testPlan` both require plan/scheme membership), so Phase 1 couldn't
> otherwise be verified.

### Steps
1. **Add the test target** (file: `Alfie/AlfieKit/Package.swift:399` — mirror `ProductListingTests` block)
   - `.testTarget(name: "BFFIntegrationTests", dependencies: ["Core", "Model", "Mocks", "TestUtils"])`.
   - `Core` → `BFFClientService`; `Mocks` → `MockReachabilityService` + `Log.DummyLogger()`;
     `Model` → `NetworkClient` + domain types. Why: per-module pattern (DRY).
2. **Dedicated test plan** (file: `Alfie/Alfie/AlfieIntegration.xctestplan` — new)
   - Copy the JSON shape of [Alfie.xctestplan](../../../Alfie/Alfie/Alfie.xctestplan) with a single
     `testTargets` entry: `containerPath: "container:AlfieKit"`, `identifier`/`name: "BFFIntegrationTests"`.
3. **Register plan in scheme** (file: `Alfie/Alfie.xcodeproj/xcshareddata/xcschemes/Alfie.xcscheme` — edit)
   - Add `AlfieIntegration.xctestplan` to `TestAction` `<TestPlans>`; keep `Alfie` as `default`.
   - Shared scheme XML — allowed. Do NOT edit `project.pbxproj`. (Xcode may reorder attrs on open — commit the plain edit.)
4. **Base case** (file: `Alfie/AlfieKit/Tests/BFFIntegrationTests/IntegrationTestCase.swift` — new)
   - **URL contract:** `let raw = ProcessInfo.processInfo.environment["ALFIE_BFF_BASE_URL"] ?? "http://localhost:3000"`
     — **origin only, no `/graphql`** (service appends it, [BFFClientService.swift:48](../../../Alfie/AlfieKit/Sources/Core/Services/BFFService/BFFClientService.swift)).
     `guard let baseURL = URL(string: raw) else { throw XCTSkip("bad ALFIE_BFF_BASE_URL") }`.
   - **Fresh SUT per test** in `override func setUp() async throws` (NOT a shared instance — avoids
     `InMemoryNormalizedCache` poisoning, [BFFClientService.swift:37](../../../Alfie/AlfieKit/Sources/Core/Services/BFFService/BFFClientService.swift)):
     ```swift
     sut = BFFClientService(
         url: baseURL,
         logRequests: false,                                 // keep test logs clean
         dependencies: BFFClientDependencyContainer(
             reachabilityService: MockReachabilityService(),  // isAvailable = true
             restNetworkClient: NetworkClient(...)            // real; REST unused by GraphQL ops
         ),
         log: Log.DummyLogger()
     )
     ```
     Match the production call shape at [ServiceProvider.swift:84](../../../Alfie/AlfieKit/Sources/Core/Services/ServiceProvider.swift).
     If `NetworkClient` is heavy to build, a 1-line local stub conforming to `NetworkClientProtocol`
     is fine (it is never called by the GraphQL paths).
   - **Readiness/skip guard** (also in `setUp() async throws`, before building SUT): POST
     `{"query":"{__typename}"}` to `baseURL.appending(path:"graphql")` (~2s timeout). Accept = HTTP 200
     with JSON body containing `data` or `errors`. Anything else → `throw XCTSkip("BFF not running at \(baseURL)")`.
     Why POST not GET: a GraphQL GET returns 200-landing/404/405 inconsistently — only a POST uniquely
     proves a live GraphQL endpoint.
5. **Canary** (in `IntegrationTestCase` or a tiny smoke file): `test_harness_reachesGraphQL()` asserts the
   readiness probe succeeded (the signal that the BFF is up and the URL contract is right).

### Verification
- Run `./Alfie/scripts/verify.sh` → unit set unchanged AND confirm the new target was **not built**:
  `grep -c BFFIntegrationTests /tmp/alfie_build.log` should be `0` (out-of-plan ⇒ not in `build-for-testing`).
- With BFF up: `xcodebuild test -project Alfie/Alfie.xcodeproj -scheme Alfie -testPlan AlfieIntegration
  -destination 'platform=iOS Simulator,name=Any iOS Simulator Device'` → canary passes.
  With BFF down → canary **skips**, does not fail.

### Estimated Effort
M
