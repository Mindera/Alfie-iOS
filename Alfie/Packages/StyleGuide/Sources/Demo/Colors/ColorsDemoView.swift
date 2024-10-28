import Foundation
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
                Colors.primary.black,
                Colors.primary.white,
            ])

            paletteView(with: "Mono", colors: [
                Colors.primary.mono900,
                Colors.primary.mono800,
                Colors.primary.mono700,
                Colors.primary.mono600,
                Colors.primary.mono500,
                Colors.primary.mono400,
                Colors.primary.mono300,
                Colors.primary.mono200,
                Colors.primary.mono100,
                Colors.primary.mono050,
            ])
        }
    }

    var secondaryColorView: some View {
        VStack {
            paletteView(with: "Green", colors: [
                Colors.secondary.green900,
                Colors.secondary.green800,
                Colors.secondary.green700,
                Colors.secondary.green600,
                Colors.secondary.green500,
                Colors.secondary.green400,
                Colors.secondary.green300,
                Colors.secondary.green200,
                Colors.secondary.green100,
                Colors.secondary.green050,
            ])

            paletteView(with: "Red", colors: [
                Colors.secondary.red900,
                Colors.secondary.red800,
                Colors.secondary.red700,
                Colors.secondary.red600,
                Colors.secondary.red500,
                Colors.secondary.red400,
                Colors.secondary.red300,
                Colors.secondary.red200,
                Colors.secondary.red100,
                Colors.secondary.red050,
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
                .foregroundStyle(colors.first ?? Colors.primary.black)
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
                .foregroundStyle(Colors.primary.mono400)
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
