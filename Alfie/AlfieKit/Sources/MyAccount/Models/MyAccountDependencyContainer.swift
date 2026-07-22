import Model
import SwiftUI

/// Presents a screen (pass an `AnyView`) or dismisses it (pass `nil`) in the caller's modal cover.
public typealias PresentCover = (AnyView?) -> Void

public final class MyAccountDependencyContainer {
    let configurationService: ConfigurationServiceProtocol
    let sessionService: SessionServiceProtocol
    /// Builds the Settings screen at the composition root, wired to the caller's `PresentCover`.
    let makeSettingsView: (@escaping PresentCover) -> AnyView

    public init(
        configurationService: ConfigurationServiceProtocol,
        sessionService: SessionServiceProtocol,
        makeSettingsView: @escaping (@escaping PresentCover) -> AnyView
    ) {
        self.configurationService = configurationService
        self.sessionService = sessionService
        self.makeSettingsView = makeSettingsView
    }
}
