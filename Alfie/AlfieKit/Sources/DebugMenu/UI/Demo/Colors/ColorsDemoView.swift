import Foundation
import SharedUI
import SwiftUI

struct ColorsDemoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.space250) {
                DemoHelper.demoSectionHeader(title: "Color Palette - Primary")

                primaryColorView

                Spacer()
                    .padding(.vertical, 10)

                DemoHelper.demoSectionHeader(title: "Color Palette - Secondary")

                secondaryColorView
            }
            .padding(.horizontal, Spacing.space200)
        }
    }

    var primaryColorView: some View {
        VStack {
            paletteView(with: "B&W", colors: [
                Primitives.Colours.neutrals900,
                Primitives.Colours.neutrals0,
            ])

            paletteView(with: "Mono", colors: [
                Primitives.Colours.neutrals800,
                Primitives.Colours.neutrals700,
                Primitives.Colours.neutrals600,
                Primitives.Colours.neutrals600,
                Primitives.Colours.neutrals500,
                Primitives.Colours.neutrals500,
                Primitives.Colours.neutrals400,
                Primitives.Colours.neutrals200,
                Primitives.Colours.neutrals100,
                Primitives.Colours.neutrals100,
            ])
        }
    }

    var secondaryColorView: some View {
        VStack {
            paletteView(with: "Green", colors: [
                Primitives.Colours.semanticSuccess800,
                Primitives.Colours.semanticSuccess800,
                Primitives.Colours.semanticSuccess800,
                Primitives.Colours.semanticSuccess700,
                Primitives.Colours.semanticSuccess600,
                Primitives.Colours.semanticSuccess500,
                Primitives.Colours.semanticSuccess400,
                Primitives.Colours.semanticSuccess200,
                Primitives.Colours.semanticSuccess100,
                Primitives.Colours.semanticSuccess100,
            ])

            paletteView(with: "Red", colors: [
                Primitives.Colours.semanticError700,
                Primitives.Colours.semanticError700,
                Primitives.Colours.semanticError600,
                Primitives.Colours.semanticError500,
                Primitives.Colours.semanticError500,
                Primitives.Colours.semanticError400,
                Primitives.Colours.semanticError300,
                Primitives.Colours.semanticError200,
                Primitives.Colours.semanticError100,
                Primitives.Colours.semanticError100,
            ])

            paletteView(with: "Yellow", colors: [
                Colors.secondary.yellow500,
                Colors.secondary.yellow400,
                Colors.secondary.yellow300,
                Colors.secondary.yellow200,
                Colors.secondary.yellow100,
                Colors.secondary.yellow050,
            ])

            paletteView(with: "Blue", colors: [
                Colors.secondary.blue900,
                Colors.secondary.blue800,
                Colors.secondary.blue700,
                Colors.secondary.blue600,
                Colors.secondary.blue500,
                Colors.secondary.blue400,
                Colors.secondary.blue300,
                Colors.secondary.blue200,
                Colors.secondary.blue100,
                Colors.secondary.blue050,
            ])

            paletteView(with: "Orange", colors: [
                Colors.secondary.orange500,
                Colors.secondary.orange400,
                Colors.secondary.orange300,
                Colors.secondary.orange200,
                Colors.secondary.orange100,
                Colors.secondary.orange050,
            ])
        }
    }

    func paletteView(with name: String, colors: [Color]) -> some View {
        VStack(alignment: .leading) {
            Text.build(theme.font.small.bold(name))
                .foregroundStyle(colors.first ?? Primitives.Colours.neutrals900)
            ScrollView(.horizontal) {
                HStack(spacing: Spacing.space0) {
                    ForEach(colors, id: \.self) { color in
                        colorView(with: color)
                    }
                }
                .padding(.bottom, 16)
            }
        }
    }

    func colorView(with color: Color) -> some View {
        VStack {
            Rectangle()
                .fill(color)
                .frame(width: 64, height: 64)
            Text.build(theme.font.tiny.normal(color.name ?? "-"))
                .foregroundStyle(Primitives.Colours.neutrals500)
        }
    }
}

#Preview {
    ColorsDemoView()
}

private extension Color {
    var name: String? {
        let regexPattern: String = "\"(.*?)\""

        guard let regex = try? NSRegularExpression(pattern: regexPattern) else {
            return nil
        }

        let descriptionString = "\(self)"
        let results = regex.matches(
            in: descriptionString,
            range: NSRange(descriptionString.startIndex..., in: descriptionString)
        )

        let matches = results.map {
            guard let range = Range($0.range, in: descriptionString) else {
                return ""
            }
            return String(descriptionString[range])
        }

        guard let match = matches.first else {
            return nil
        }

        return match.replacingOccurrences(of: "\"", with: "")
    }
}
