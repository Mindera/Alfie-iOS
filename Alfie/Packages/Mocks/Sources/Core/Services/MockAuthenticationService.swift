import Models

public class MockAuthenticationService: AuthenticationServiceProtocol {
    public var isUserSignedIn = false
    
    public init() { }
}
