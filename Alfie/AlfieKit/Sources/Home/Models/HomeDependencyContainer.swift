import Model

public final class HomeDependencyContainer {
    let sessionService: SessionServiceProtocol

    public init(sessionService: SessionServiceProtocol) {
        self.sessionService = sessionService
    }
}
