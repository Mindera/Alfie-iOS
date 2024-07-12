import SwiftUI

struct SearchBarDemoView: View {
    @State private var searchText: String = ""
    @State private var scrollOffset: CGPoint = .zero
    @State private var searchBarTheme = ThemedSearchBarView.Theme.light
    private let placeholder = "Search Alfie"
    private let placeholderOnFocus = "What are you looking for?"

    init() {}

    var body: some View {
        VStack {
            DemoHelper.demoSectionHeader(title: "Search Bar")
                .padding(.horizontal, Spacing.space200)

            // swiftlint:disable:next trailing_closure
            ScrollViewWithOffsetReader(offset: $scrollOffset) {
                LazyVGrid(columns: [
                    GridItem(.flexible(minimum: 200)),
                    GridItem(.flexible(minimum: 200)),
                ], spacing: Spacing.space200) {
                    ForEach(0..<10) { index in
                        VStack {
                            Image("DemoProductImage", bundle: .module)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(8)
                            Text("Product \(index)")
                                .font(.headline)
                                .padding(.top, 5)
                            Text("Description \(index)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 10)
                        }
                        .background(Colors.primary.white)
                        .cornerRadius(10)
                    }
                }
            }
            .searchable(
                placeholder: placeholder,
                placeholderOnFocus: placeholderOnFocus,
                searchText: $searchText,
                pullToSearchConfig: .enabled(scrollOffset: $scrollOffset),
                theme: searchBarTheme,
                dismissConfiguration: .init(type: .back),
                resultsView: {
                    VStack(spacing: Spacing.space200) {
                        if searchText.isEmpty {
                            Text.build(theme.font.paragraph.normal("Type something to start searching"))
                        } else {
                            Text.build(theme.font.paragraph.normal("Searching for:"))
                            Text.build(theme.font.small.bold(searchText))
                                .padding(.horizontal, Spacing.space250)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Colors.primary.white)
                }
            )
            .animation(.standard, value: searchBarTheme)

            VStack(alignment: .leading) {
                Text.build(theme.font.small.bold("Search Bar Theme:"))
                Picker(selection: $searchBarTheme) {
                    ForEach(ThemedSearchBarView.Theme.allCases, id: \.self) { searchBarTheme in
                        Text.build(theme.font.small.normal(searchBarTheme.name))
                            .tag(searchBarTheme)
                    }
                } label: {
                }
                .pickerStyle(.segmented)
            }
            .padding(Spacing.space150)
        }
    }
}

private extension ThemedSearchBarView.Theme {
    var name: String {
        switch self {
        case .softLarge:
            "Soft Large"
        default:
            "\(self)".capitalized
        }
    }
}

#Preview {
    SearchBarDemoView()
}
