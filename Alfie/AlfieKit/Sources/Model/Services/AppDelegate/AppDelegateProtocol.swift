import Foundation

public protocol AppDelegateProtocol: NSObject {
    func rebootApp()

    /// Persist the selected colour-theme id and soft-reboot so the whole UI re-renders in it.
    /// `id` is a design-token theme mode (e.g. `"selffridge-theme"`); unknown ids fall back to default.
    func applyTheme(id: String)
}
