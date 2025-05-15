import Foundation
import Model

public protocol AppFeatureViewModelProtocol: ObservableObject {
    var currentScreen: AppStartupScreen { get }
    var rootTabViewModel: RootTabViewModel { get }
    var appUpdateInfoConfiguration: AppUpdateInfo? { get }

    func navigate(for deepLinkType: DeepLink.LinkType)
}
