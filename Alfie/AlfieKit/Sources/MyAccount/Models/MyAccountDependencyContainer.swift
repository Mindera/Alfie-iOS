import Model
import SwiftUI

public final class MyAccountDependencyContainer {
    let configurationService: ConfigurationServiceProtocol
    let sessionService: SessionServiceProtocol
    /// Builds the Settings screen at the composition root. `present` shows/dismisses the caller's cover.
    let makeSettingsView: (@escaping (AnyView?) -> Void) -> AnyView

    public init(
        configurationService: ConfigurationServiceProtocol,
        sessionService: SessionServiceProtocol,
        makeSettingsView: @escaping (@escaping (AnyView?) -> Void) -> AnyView
    ) {
        self.configurationService = configurationService
        self.sessionService = sessionService
        self.makeSettingsView = makeSettingsView
    }
}
