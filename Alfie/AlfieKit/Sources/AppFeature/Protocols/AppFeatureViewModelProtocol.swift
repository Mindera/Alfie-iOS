import Foundation
import Model

public protocol AppFeatureViewModelProtocol: ObservableObject {
    associatedtype RootTabVM: RootTabViewModelProtocol

    var currentScreen: AppStartupScreen { get }
    var rootTabViewModel: RootTabVM { get }
    var appUpdateInfoConfiguration: AppUpdateInfo? { get }

    func navigate(for deepLinkType: DeepLink.LinkType)
}
