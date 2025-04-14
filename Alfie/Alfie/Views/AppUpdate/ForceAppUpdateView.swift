import Core
import Model
import SharedUI
import SwiftUI
#if DEBUG
import Mocks
#endif

struct ForceAppUpdateView: View {
    private let configuration: AppUpdateInfo

    private enum Constants {
        static let logoWidth: CGFloat = 30
    }

    init(configuration: AppUpdateInfo) {
        self.configuration = configuration
    }

    var body: some View {
        HStack {
            VStack(spacing: Spacing.space0) {
                ThemedImage.logoBackground.image
                    .resizable(resizingMode: .tile)
            }
            .frame(width: Constants.logoWidth)

            VStack(spacing: Spacing.space400) {
                Text.build(theme.font.header.h1(configuration.title))
                Text.build(theme.font.paragraph.bold(configuration.message))
                    .multilineTextAlignment(.center)

                ThemedButton(
                    text: configuration.confirmActionText,
                    type: .big,
                    style: .primary
                ) {
                    if let url = configuration.url {
                        UIApplication.shared.open(url)
                    }
                }
                .padding(.top, Spacing.space200)
            }
            .padding(.horizontal, Spacing.space400)

            Spacer()
        }
        .background(backgroundView)
        .ignoresSafeArea()
    }

    @ViewBuilder var backgroundView: some View {
        RemoteImage(
            url: configuration.backgroundImage,
            transaction: Transaction(animation: .easeIn(duration: 1))
        ) { image in
            image.resizable()
                .scaledToFill()
        }
    }
}
#if DEBUG
#Preview {
    ForceAppUpdateView(configuration: .fixture())
}
#endif
