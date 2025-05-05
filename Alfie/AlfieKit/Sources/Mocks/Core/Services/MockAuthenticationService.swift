import Model

public class MockAuthenticationService: AuthenticationServiceProtocol {
    public var isUserSignedIn = false
    
    public init() { }
}
