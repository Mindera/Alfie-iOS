import SwiftUI

// MARK: - SegmentsDemoView

struct SegmentsDemoView: View {
    @State private var selectedSegmentSection1 = Segment(title: "Categories", CategoryPages.categories)
    @State private var segmentsSection1: [Segment] = []

    @State private var selectedSegmentSection2 = Segment(title: "Categories", CategoryPages.categories)
    @State private var segmentsSection2: [Segment] = []

    @State private var selectedSegmentSection3 = Segment(title: "Categories", CategoryPages.categories)
    @State private var segmentsSection3: [Segment] = []

    @State private var selectedSegmentSection4 = Segment(title: "Categories", CategoryPages.categories)
    @State private var segmentsSection4: [Segment] = []

    @State private var selectedSegmentSection5 = Segment(title: "Categories", icon: Icon.heart.image, CategoryPages.categories)
    @State private var segmentsSection5: [Segment] = []

    // MARK: - CategoryPages

    private enum CategoryPages {
        case categories
        case brands
        case services
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.space250) {
                // Section 1
                DemoHelper.demoSectionHeader(title: "3 segments with standard padding")

                ThemedSegmentedView(segmentsSection1, selection: $selectedSegmentSection1) { segment, animation, type in
                    ThemedSegmentView(segment, type: type, currectSelected: $selectedSegmentSection1, animation: animation)
                }

                segmentView(selectedSegmentSection1)

                // Section 2
                DemoHelper.demoSectionHeader(title: "2 segments with standard padding")

                ThemedSegmentedView(segmentsSection2, selection: $selectedSegmentSection2) { segment, animation, type in
                    ThemedSegmentView(segment, type: type, currectSelected: $selectedSegmentSection2, animation: animation)
                }

                segmentView(selectedSegmentSection2)

                // Section 3
                DemoHelper.demoSectionHeader(title: "3 segments with extended padding")

                ThemedSegmentedView(segmentsSection3, type: .extended, selection: $selectedSegmentSection3) { segment, animation, type in
                    ThemedSegmentView(segment, type: type, currectSelected: $selectedSegmentSection3, animation: animation)
                }

                segmentView(selectedSegmentSection3)

                // Section 4
                DemoHelper.demoSectionHeader(title: "2 segments with extended padding")

                ThemedSegmentedView(segmentsSection4, type: .extended, selection: $selectedSegmentSection4) { segment, animation, type in
                    ThemedSegmentView(segment, type: type, currectSelected: $selectedSegmentSection4, animation: animation)
                }

                segmentView(selectedSegmentSection4)

                // Section 5
                DemoHelper.demoSectionHeader(title: "2 icon segments with standard padding")

                ThemedSegmentedView(segmentsSection5, selection: $selectedSegmentSection5) { segment, animation, type in
                    ThemedSegmentView(segment, type: type, currectSelected: $selectedSegmentSection5, animation: animation)
                }

                segmentView(selectedSegmentSection5)

                Spacer()
            }
        }
        .onAppear {
            self.segmentsSection1 = [
                selectedSegmentSection1,
                Segment(title: "Brands", CategoryPages.brands),
                Segment(title: "Services", CategoryPages.services),
            ]

            self.segmentsSection2 = [
                selectedSegmentSection2,
                Segment(title: "Brands", CategoryPages.brands),
            ]

            self.segmentsSection3 = [
                selectedSegmentSection3,
                Segment(title: "Brands", CategoryPages.brands),
                Segment(title: "Services", CategoryPages.services),
            ]

            self.segmentsSection4 = [
                selectedSegmentSection4,
                Segment(title: "Brands", CategoryPages.brands),
            ]

            self.segmentsSection5 = [
                selectedSegmentSection5,
                Segment(title: "Brands", icon: Icon.heart.image, CategoryPages.brands),
            ]
        }
        .padding(.horizontal, Spacing.space200)
    }

    @ViewBuilder
    private func segmentView(_ segment: Segment) -> some View {
        switch segment.object as? CategoryPages {
            case .categories:
                segmentContentView(title: "Categories", color: Colors.secondary.green300)
            case .brands:
                segmentContentView(title: "Brands", color: Colors.secondary.blue300)
            case .services:
                segmentContentView(title: "Services", color: Colors.secondary.red300)
            case .none:
                EmptyView()
        }
    }

    private func segmentContentView(title: String, color: Color) -> some View {
        ZStack {
            Rectangle()
                .fill(color)
            Text.build(theme.font.paragraph.normal(title))
        }
        .frame(height: 150)
    }
}

#Preview {
    SegmentsDemoView()
}
