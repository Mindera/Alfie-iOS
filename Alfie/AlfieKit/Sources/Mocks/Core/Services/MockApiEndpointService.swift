import Foundation
import Model

public class MockApiEndpointService: ApiEndpointServiceProtocol {
    public var currentApiEndpoint: ApiEndpointOption = .dev

    public var onUpdateApiEndpointAndRebootCalled: ((ApiEndpointOption) -> Void)?
    public func updateApiEndpointAndReboot(_ option: ApiEndpointOption) {
        onUpdateApiEndpointAndRebootCalled?(option)
    }
    
    public var onApiEndpointForOptionCalled: ((ApiEndpointOption) -> URL)?
    public func apiEndpoint(for option: ApiEndpointOption) -> URL {
        onApiEndpointForOptionCalled?(option) ?? URL(fileURLWithPath: "")
    }
    
    public init(currentApiEndpoint: ApiEndpointOption = .dev, 
                onUpdateApiEndpointAndRebootCalled: ((ApiEndpointOption) -> Void)? = nil,
                onApiEndpointForOptionCalled: ((ApiEndpointOption) -> URL)? = nil) {
        self.currentApiEndpoint = currentApiEndpoint
        self.onUpdateApiEndpointAndRebootCalled = onUpdateApiEndpointAndRebootCalled
        self.onApiEndpointForOptionCalled = onApiEndpointForOptionCalled
    }
}
