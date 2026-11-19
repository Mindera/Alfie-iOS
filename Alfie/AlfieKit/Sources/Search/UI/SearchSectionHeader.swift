import SharedUI
import SwiftUI

struct SearchSectionHeader: View {
    private let title: String

    init(title: String) {
        self.title = title
    }

    var body: some View {
        Text.build(theme.font.heading.xSmall(title))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
#Preview {
    SearchSectionHeader(title: L10n.Search.Screen.SuggestionsTerms.Header.title)
}
#endif
