import Models
import SwiftUI
#if DEBUG
import Mocks
#endif

struct SoftAppUpdateAlertMessageView: View {
    private let update: AppUpdateInfo?

    init(update: AppUpdateInfo?) {
        self.update = update
    }

    var body: some View {
        if let update {
            Text(update.message)
        }
    }
}

#if DEBUG
#Preview {
    SoftAppUpdateAlertMessageView(update: .fixture())
}
#endif
