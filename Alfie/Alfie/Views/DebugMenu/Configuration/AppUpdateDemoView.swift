import Models
import StyleGuide
import SwiftUI
#if DEBUG
import Mocks
#endif

struct AppUpdateDemoView: View {
    @EnvironmentObject var coordinator: Coordinator
    private let configurationService: ConfigurationServiceProtocol
    private let softAppUpdateInfo: AppUpdateInfo?
    @State private var isShowingAppUpdateAlert = false

    init(configurationService: ConfigurationServiceProtocol) {
        self.configurationService = configurationService
        self.softAppUpdateInfo = configurationService.softAppUpdateInfo
    }

    var body: some View {
        VStack(alignment: .leading) {
            DemoHelper.demoSectionHeader(title: "Current App version: \(Bundle.main.appVersion)")
                .padding(.bottom, Spacing.space200)
            softAppUpdate
            forceAppUpdate
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.space200)
        .alert(softAppUpdateInfo?.title ?? "", isPresented: $isShowingAppUpdateAlert, actions: {
            SoftAppUpdateAlertActionsView(update: softAppUpdateInfo)
        }, message: {
            SoftAppUpdateAlertMessageView(update: softAppUpdateInfo)
        })
    }

    // MARK: - Private

    @ViewBuilder
    private var softAppUpdate: some View {
        DemoHelper.demoSectionHeader(title: "Soft Update")
            .padding(.top, Spacing.space200)

        if let softUpdate = configurationService.softAppUpdateInfo {
            ThemedButton(text: "Open", action: {
                isShowingAppUpdateAlert = true
            })
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, -Spacing.space700)

            appUpdateInfoView(softUpdate, isActive: configurationService.isSoftAppUpdateAvailable)
        } else {
            Text.build(theme.font.small.normal("Undefinied"))
        }
    }

    @ViewBuilder
    private var forceAppUpdate: some View {
        DemoHelper.demoSectionHeader(title: "Force Update")
            .padding(.top, Spacing.space400)

        if let forceUpdate = configurationService.forceAppUpdateInfo {
            ThemedButton(text: "Open", action: {
                coordinator.closeDebugMenu()
                // delay to perform the animated fullscreen dismiss
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    coordinator.openForceAppUpdate()
                }
            })
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, -Spacing.space700)

            appUpdateInfoView(forceUpdate, isActive: configurationService.isForceAppUpdateAvailable)
        } else {
            Text.build(theme.font.small.normal("Undefinied"))
        }
    }

    @ViewBuilder
    private func appUpdateInfoView(_ info: AppUpdateInfo, isActive: Bool) -> some View {
        VStack(alignment: .leading) {
            if isActive {
                Text.build(theme.font.small.bold("Prompt enabled"))
                    .foregroundStyle(Colors.secondary.red800)
                    .padding(.bottom, Spacing.space100)
            }

            let rows: [(label: String, value: String?)] = [
                ("Version", info.minimumAppVersion.stringValue),
                ("Title", info.title),
                ("Message", info.message),
                ("Background Image", info.backgroundImage?.absoluteString),
                ("Confirm Action", info.confirmActionText),
                ("Cancel Action", info.cancelActionText),
                ("URL", info.url?.absoluteString),
            ]

            ForEach(rows, id: \.label) {
                row(label: $0.label, value: $0.value)
            }
        }
    }

    private func row(label: String, value: String?) -> some View {
        VStack(alignment: .leading) {
            Text.build(theme.font.paragraph.normal(label))
                .foregroundStyle(Colors.primary.mono500)
            if let value {
                Text.build(theme.font.paragraph.bold(value))
                    .foregroundStyle(Colors.primary.mono900)
            } else {
                Text.build(theme.font.paragraph.normal("Undefinied"))
                    .foregroundStyle(Colors.primary.mono300)
            }
        }
        .padding(.bottom, Spacing.space025)
    }
}

#if DEBUG
#Preview {
    ScrollView {
        AppUpdateDemoView(configurationService: MockConfigurationService(
            forceAppUpdateInfo: .fixture(minimumAppVersion: .init("2.0.0")),
            softAppUpdateInfo: .fixture(minimumAppVersion: .init("2.5.0")))
        )
    }
}
#endif
