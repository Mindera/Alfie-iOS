import Model
import SharedUI
import SwiftUI

struct PlatformSelectionView: View {
    @StateObject private var viewModel: PlatformSelectionViewModel

    init(viewModel: PlatformSelectionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Primitives.Spacing.spacing20) {
            DemoHelper.demoSectionHeader(title: "Commerce Platform")

            RadioButtonList(
                values: viewModel.availablePlatforms,
                selectedValue: $viewModel.selectedPlatform,
                verticalSpacing: Primitives.Spacing.spacing24
            )

            Text.build(theme.font.body.small("Sent as the `platform` argument on the next BFF request — no restart needed."))
                .foregroundStyle(Primitives.Colours.neutrals700)

            Spacer()
        }
        .padding(.horizontal, Primitives.Spacing.spacing16)
    }
}

#if DEBUG
#Preview {
    PlatformSelectionView(viewModel: PlatformSelectionViewModel())
}
#endif
