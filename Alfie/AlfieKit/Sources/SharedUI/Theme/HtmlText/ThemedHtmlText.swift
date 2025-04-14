import SwiftUI

// MARK: - ThemedHtmlText

public struct ThemedHtmlText: View {
    private var html: String

    public init(_ html: String) {
        self.html = html
    }

    public var body: some View {
        if
            let nsAttributedString = try? NSAttributedString(
                data: Data(html.utf8),
                options: [.documentType: NSAttributedString.DocumentType.html],
                documentAttributes: nil
            ),
            let attributedString = try? AttributedString(nsAttributedString, including: \.uiKit) {
            Text(attributedString)
                .fixedSize(horizontal: false, vertical: true)
        } else {
            Text(html)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    ThemedHtmlText("<h1>Hello</h1>")
}
