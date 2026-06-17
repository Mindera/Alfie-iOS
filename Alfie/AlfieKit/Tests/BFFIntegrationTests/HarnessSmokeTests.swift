import XCTest

/// Canary: confirms the harness reached a live GraphQL endpoint and built the service. If the BFF is
/// down this skips in `setUp` (never fails); if it's up, reaching here proves the readiness probe
/// passed and the URL contract is correct.
final class HarnessSmokeTests: IntegrationTestCase {
    func test_harness_reachesBFFAndBuildsService() throws {
        XCTAssertNotNil(sut, "BFFClientService should be constructed once the BFF is reachable")
    }
}
