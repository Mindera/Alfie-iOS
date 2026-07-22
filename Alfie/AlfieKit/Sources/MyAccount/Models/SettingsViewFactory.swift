import DebugMenu
import Model
import SharedUI
import SwiftUI

/// Builds the Settings (debug menu) screen. Lives at the composition seam so `AccountViewModel` never
/// constructs Views or depends on `ApiEndpointService`. `present` drives the caller's modal cover:
/// pass a view to show, or `nil` to dismiss. Temporary — the debug menu stands in until the real
/// settings screen exists.
public enum SettingsViewFactory {
    public static func make(
        configurationService: ConfigurationServiceProtocol,
        apiEndpointService: ApiEndpointServiceProtocol,
        present: @escaping (AnyView?) -> Void
    ) -> AnyView {
        AnyView(
            DebugMenuView(
                viewModel: DebugMenuViewModel(
                    configurationService: configurationService,
                    apiEndpointService: apiEndpointService,
                    closeMenuAction: { present(nil) },
                    openForceAppUpdate: {
                        if let configuration = configurationService.forceAppUpdateInfo {
                            present(AnyView(ForceAppUpdateView(configuration: configuration)))
                        }
                    },
                    closeEndpointSelection: { present(nil) }
                )
            )
        )
    }
}
