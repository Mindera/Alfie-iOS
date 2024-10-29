import Models
import SwiftUI

public struct SizingSelectorHeaderView: View {
    var action: (() -> Void)?

    @ObservedObject private var configuration: SizingSelectorConfiguration
    private let isExpandable: Bool

    public init(configuration: SizingSelectorConfiguration, isExpandable: Bool, action: (() -> Void)? = nil) {
        self.configuration = configuration
        self.isExpandable = isExpandable
        self.action = action
    }

    public var body: some View {
        HStack {
            Button(action: {
                guard isExpandable else {
                    return
                }
                action?()
            }, label: {
                HStack(spacing: Spacing.space050) {
                    Text.build(theme.font.paragraph.normal(configuration.selectedTitle))
                        .foregroundStyle(Colors.primary.mono400)
                    Text.build(theme.font.paragraph.normal(configuration.selectedItem?.name ?? ""))
                        .foregroundStyle(Colors.primary.mono900)

                    if isExpandable {
                        Icon.chevronDown.image
                            .resizable()
                            .scaledToFit()
                            .frame(size: Constants.chevronSize)
                    }
                }
            })
            .allowsHitTesting(isExpandable)
            .tint(Colors.primary.mono900)
        }
    }
}

private enum Constants {
    static let chevronSize: CGFloat = 16
}
