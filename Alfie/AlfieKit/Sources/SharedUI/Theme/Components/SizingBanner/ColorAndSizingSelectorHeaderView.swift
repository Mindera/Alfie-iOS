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
                    HStack(spacing: Primitives.Spacing.spacing4) {
                        Text.build(theme.font.body.medium(configuration.selectedTitle))
                            .foregroundStyle(Primitives.Colours.neutrals500)
                        Text.build(theme.font.body.medium(configuration.selectedItem?.name ?? ""))
                            .foregroundStyle(Primitives.Colours.neutrals800)

                        if isExpandable {
                            ThemedIcon(.chevronDown, size: .small, tint: Primitives.Colours.neutrals800)
                        }
                    }
                }
            )
            .allowsHitTesting(isExpandable)
            .tint(Primitives.Colours.neutrals800)
        }
    }
}
