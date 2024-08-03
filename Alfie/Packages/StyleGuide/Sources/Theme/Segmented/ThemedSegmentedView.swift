import Foundation
import SwiftUI

// MARK: - ThemedSegmentedView

public enum ThemedSegmentType {
    case compact
    case extended
}

public struct ThemedSegmentedView<Content: View>: View {
    private let list: [Segment]
    @Binding private var selection: Segment
    private let itemBuilder: (Segment, Namespace.ID, ThemedSegmentType) -> Content
    @Namespace var animation
    private var type: ThemedSegmentType

    public init(_ list: [Segment], type: ThemedSegmentType = .compact, selection: Binding<Segment>, itemBuilder: @escaping (Segment, Namespace.ID, ThemedSegmentType) -> Content) {
        self.list = list
        self.type = type
        _selection = selection
        self.itemBuilder = itemBuilder
    }

    public var body: some View {
        HStack(spacing: Spacing.space0) {
            ForEach(list, id: \.id) { segment in
                itemBuilder(segment, animation, type)
            }
        }
        .padding(type == .compact ? Spacing.space050 : Spacing.space100)
        .background {
            RoundedRectangle(cornerRadius: CornerRadius.s)
                .fill(Colors.primary.mono100)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AccessibilityId.segmentedControl)
    }
}

// MARK: - ThemedSegmentView

public struct ThemedSegmentView: View {
    private var segment: Segment
    private var animation: Namespace.ID
    @Binding private var currectSelected: Segment
    private var type: ThemedSegmentType

    public init(_ segment: Segment, type: ThemedSegmentType, currectSelected: Binding<Segment>, animation: Namespace.ID) {
        self.segment = segment
        self.type = type
        _currectSelected = currectSelected
        self.animation = animation
    }

    public var body: some View {
        ZStack {
            if currectSelected == segment {
                RoundedRectangle(cornerRadius: CornerRadius.xs)
                    .fill(Colors.primary.white)
                    .matchedGeometryEffect(id: "segmentBackground", in: animation, properties: .frame)
            } else {
                RoundedRectangle(cornerRadius: CornerRadius.xs)
                    .fill(.clear)
            }
            HStack(spacing: Spacing.space0) {
                Spacer()
                if let icon = segment.icon {
                    icon
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: Constants.iconWidth, height: Constants.iconHeight)
                        .padding(.trailing, type == .compact ? Spacing.space050 : Spacing.space100)
                        .foregroundStyle(currectSelected == segment ? Colors.primary.black : Colors.primary.mono500)
                }
                Text.build(theme.font.paragraph.normal(segment.title))
                    .foregroundStyle(currectSelected == segment ? Colors.primary.black : Colors.primary.mono500)
                    .padding(.vertical, type == .compact ? Spacing.space100 : Spacing.space200)
                    .lineLimit(1)
                Spacer()
            }
        }
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier(AccessibilityId.segmentedOption)
        .if(
            currectSelected == segment,
            whenTrue: { segment in segment.accessibilityAddTraits(.isSelected) },
            whenFalse: { segment in segment.accessibilityRemoveTraits(.isSelected) }
        )
        .contentShape(Rectangle())
        .animation(.emphasizedDecelerate, value: currectSelected)
        .onTapGesture {
            currectSelected = segment
        }
    }
}

// MARK: - Segment

public struct Segment: Identifiable, Equatable, Hashable {
    public let id: String
    public let title: String
    public let icon: Image?
    public let object: Any

    public init(id: String = UUID().uuidString, title: String, icon: Image? = nil, _ object: Any) {
        self.id = id
        self.title = title
        self.icon = icon
        self.object = object
    }

    public static func == (lhs: Segment, rhs: Segment) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

private enum Constants {
    static let iconWidth = 16.0
    static let iconHeight = 16.0
}

private enum AccessibilityId {
    static let segmentedControl = "segmented-control"
    static let segmentedOption = "segmented-option"
}

#Preview {
    @State var currentSelected = Segment(title: "Categories", "Categories")
    let segments: [Segment] = [
        currentSelected,
        Segment(title: "Brands", "Brands"),
        Segment(title: "Services", "Services"),
    ]
    return ThemedSegmentedView(segments, selection: $currentSelected) { segment, animation, type in
        ThemedSegmentView(segment, type: type, currectSelected: $currentSelected, animation: animation)
    }
}
