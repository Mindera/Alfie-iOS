import Models
import SwiftUI

public struct SizingSwatchView: View {
    private let item: SizingSwatch
    private let isSelected: Bool

    public init(item: SizingSwatch, isSelected: Bool) {
        self.item = item
        self.isSelected = isSelected
    }

    public var body: some View {
        Text.build(theme.font.paragraph.normal(item.name))
            .frame(maxWidth: .infinity)
            .lineLimit(1)
            .padding(.vertical, Constants.insetVertical)
            .padding(.horizontal, Constants.insetHorizontal)
            .foregroundStyle(textColor)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: CornerRadius.xs)
                        .fill(isSelected ? Colors.primary.black : .clear)

                    RoundedRectangle(cornerRadius: CornerRadius.xs)
                        .inset(by: Constants.borderLineWidth)
                        .stroke(
                            item.state == .available ? Colors.primary.black : Constants.disabledStateColor,
                            lineWidth: Constants.borderLineWidth
                        )

                    outOfStockSlashView
                }
            )
    }

    private var textColor: Color {
        guard item.state == .available else {
            return Constants.disabledStateColor
        }
        return isSelected ? Colors.primary.white : Colors.primary.black
    }

    @ViewBuilder private var outOfStockSlashView: some View {
        if item.state == .outOfStock {
            theme.shape.unavailableCrossedOutShape()
                .stroke(Constants.disabledStateColor, style: StrokeStyle(lineWidth: Constants.borderLineWidth))
                .padding(Constants.borderLineWidth)
        }
    }
}

private enum Constants {
    static let disabledStateColor: Color = Colors.primary.mono400
    static let insetVertical: CGFloat = Spacing.space100
    static let insetHorizontal: CGFloat = Spacing.space300
    static let borderLineWidth: CGFloat = 1
}

@available(iOS 17, *)
#Preview(traits: .sizeThatFitsLayout) {
    VStack {
        SizingSwatchView(item: .init(name: "Default", state: .available), isSelected: false)

        SizingSwatchView(item: .init(name: "Selected", state: .available), isSelected: true)

        SizingSwatchView(item: .init(name: "Unavailable", state: .unavailable), isSelected: false)

        SizingSwatchView(item: .init(name: "Out of Stock", state: .outOfStock), isSelected: false)
    }
}
