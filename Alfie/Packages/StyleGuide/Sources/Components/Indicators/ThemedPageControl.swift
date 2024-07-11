import SwiftUI

public struct ThemedPageControl<CustomControl: View, DataType: Any>: View {
    @Binding private var selectedIndex: Int
    private let data: [DataType]
    private let configuration: ThemedPageControlConfiguration
    private let customControl: (DataType, Bool) -> CustomControl

    public init(data: [DataType],
                selectedIndex: Binding<Int>,
                configuration: ThemedPageControlConfiguration,
                @ViewBuilder customControl: @escaping (DataType, Bool) -> CustomControl) {
        self.data = data
        self.configuration = configuration
        self._selectedIndex = selectedIndex
        self.customControl = customControl
    }

    public var body: some View {
        HStack(spacing: configuration.spacing) {
            ForEach(Array(data.enumerated()), id: \.0) { index, item in
                let isSelected = index == selectedIndex
                if CustomControl.self != EmptyView.self {
                    customControl(item, isSelected)
                } else {
                    Circle()
                        .fill(isSelected ? configuration.selectedColor : configuration.color)
                        .frame(width: configuration.size, height: configuration.size)
                        .animation(.linear(duration: configuration.animationDuration),
                                   value: isSelected)
                }
            }
        }
        .frame(height: configuration.size)
        .padding()
    }
}

extension ThemedPageControl where CustomControl == EmptyView {
    init(data: [DataType],
         selectedIndex: Binding<Int>,
         configuration: ThemedPageControlConfiguration) {
        self.init(data: data, selectedIndex: selectedIndex, configuration: configuration, customControl: { _, _ in EmptyView() })
    }
}
