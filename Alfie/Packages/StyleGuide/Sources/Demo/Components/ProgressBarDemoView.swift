import SwiftUI

struct ProgressBarDemoView: View {
    var body: some View {
        VStack(spacing: Spacing.space0) {
            DemoHelper.demoSectionHeader(title: "Progress Bar")
                .padding(.horizontal, Spacing.space200)
                .padding(.bottom, Spacing.space400)

            ProgressableHorizontalScrollView(
                scrollViewConfiguration: .init(horizontalPadding: Spacing.space200),
                progressBarConfiguration: .init(horizontalPadding: Spacing.space800)
            ) {
                HStack {
                    ForEach(0..<40) { _ in
                        Rectangle()
                            .foregroundColor(Colors.primary.mono300)
                            .cornerRadius(CornerRadius.m)
                            .frame(width: 120, height: 120)
                    }
                }
            }

            Spacer()
        }
    }
}

#Preview {
    ProgressBarDemoView()
}
