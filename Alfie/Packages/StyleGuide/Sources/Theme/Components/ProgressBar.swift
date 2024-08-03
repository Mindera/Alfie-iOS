import SwiftUI

public struct ProgressBar: View {
    @Binding private var progress: Double
    @Binding private var total: Double
    @State private var width: CGFloat = 0

    enum Constants {
        static let indicatorWidth: CGFloat = 31
        static let height: CGFloat = 4
    }

    public init(progress: Binding<Double>, total: Binding<Double>) {
        self._progress = progress
        self._total = total
    }

    public init(progress: Binding<Double>, total: Double) {
        self.init(progress: progress, total: .constant(total))
    }

    public var body: some View {
        HStack {
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Colors.primary.mono200)
                    .cornerRadius(CornerRadius.xl)
                    .frame(height: Constants.height)
                Rectangle()
                    .fill(Colors.primary.mono700)
                    .cornerRadius(CornerRadius.xl)
                    .frame(width: Constants.indicatorWidth, height: Constants.height)
                    .offset(x: xOffset(for: progress), y: 0)
                    .animation(.easeOut, value: progress)
            }
        }
        .background {
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        width = geometry.size.width
                    }
                    .onChange(of: geometry.size) { size in
                        width = size.width
                    }
            }
        }
    }

    private func xOffset(for progress: Double) -> CGFloat {
        let maxOffset: CGFloat = width - Constants.indicatorWidth
        let minOffset: CGFloat = 0

        return CGFloat.minimum(
            maxOffset,
            CGFloat.maximum(
                minOffset,
                abs(progress) * maxOffset / total
            )
        )
    }
}

#Preview {
    ProgressBar(progress: .constant(50), total: .constant(100))
        .padding()
}
