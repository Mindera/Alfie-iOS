import Model
import SwiftUI
#if DEBUG
import Mocks
#endif

public struct SoftAppUpdateAlertMessageView: View {
    private let update: AppUpdateInfo?

    public init(update: AppUpdateInfo?) {
        self.update = update
    }

    public var body: some View {
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
