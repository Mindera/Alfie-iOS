import Model
import SwiftUI

public struct ColorAndSizingSelectorHeaderView<Swatch: ColorAndSizingSwatchProtocol>: View {
    var action: (() -> Void)?

    @ObservedObject private var configuration: ColorAndSizingSelectorConfiguration<Swatch>
    private let isExpandable: Bool

    public init(configuration: ColorAndSizingSelectorConfiguration<Swatch>, isExpandable: Bool, action: (() -> Void)? = nil) {
        self.configuration = configuration
        self.isExpandable = isExpandable
        self.action = action
    }

    public var body: some View {
        HStack {
            Button(
                action: {
                    guard isExpandable else {
                        return
                    }
                    action?()
                },
                label: {
                    HStack(spacing: Spacing.space050) {
                        Text.build(theme.font.paragraph.normal(configuration.selectedTitle))
                            .foregroundStyle(Primitives.Colours.neutrals500)
                        Text.build(theme.font.paragraph.normal(configuration.selectedItem?.name ?? ""))
                            .foregroundStyle(Primitives.Colours.neutrals800)

                        if isExpandable {
                            Icon.chevronDown.image
                                .resizable()
                                .scaledToFit()
                                .frame(size: Constants.chevronSize)
                        }
                    }
                }
            )
            .allowsHitTesting(isExpandable)
            .tint(Primitives.Colours.neutrals800)
        }
    }
}

private enum Constants {
    static let chevronSize: CGFloat = 16
}
