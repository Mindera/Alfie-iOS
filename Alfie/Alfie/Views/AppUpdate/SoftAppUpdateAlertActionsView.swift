import Models
import SwiftUI
#if DEBUG
import Mocks
#endif

struct SoftAppUpdateAlertActionsView: View {
    private let update: AppUpdateInfo?

    init(update: AppUpdateInfo?) {
        self.update = update
    }

    var body: some View {
        if let update {
            Button(update.confirmActionText) {
                if let url = update.url {
                    UIApplication.shared.open(url)
                }
            }
            Button(update.cancelActionText ?? "", role: .cancel) { }
        }
    }
}

#if DEBUG
#Preview {
    SoftAppUpdateAlertActionsView(update: .fixture(
        confirmActionText: "Update now",
        cancelActionText: "Later"))
}
#endif
