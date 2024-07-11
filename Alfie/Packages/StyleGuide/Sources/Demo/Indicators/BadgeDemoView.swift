import SwiftUI

struct BadgeDemoView: View {
    @State private var badgeValue: Int? = 1

    var body: some View {
        VStack(spacing: Spacing.space250) {
            DemoHelper.demoSectionHeader(title: "Badge")

            HStack {
                Icon.bag.image
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 20, height: 20)
                    .badgeView(badgeValue: $badgeValue)
                Spacer()
                Icon.bag.image
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 40, height: 40)
                    .badgeView(badgeValue: $badgeValue)
                Spacer()
                Icon.bag.image
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 50, height: 50)
                    .badgeView(badgeValue: $badgeValue)
            }
            .padding(.horizontal)

            HStack {
                Icon.store.image
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 20, height: 20)
                    .badgeView(badgeValue: $badgeValue)
                Spacer()
                Icon.store.image
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 40, height: 40)
                    .badgeView(badgeValue: $badgeValue)
                Spacer()
                Icon.store.image
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 50, height: 50)
                    .badgeView(badgeValue: $badgeValue)
            }
            .padding(.horizontal)

            HStack {
                Rectangle()
                    .frame(width: 44, height: 44)
                    .badgeView(badgeValue: $badgeValue)
                Spacer()
                ThemedButton(text: "Add to bag", action: {})
                    .badgeView(badgeValue: $badgeValue)
                Spacer()
                Circle()
                    .frame(width: 44, height: 44)
                    .badgeView(badgeValue: $badgeValue)
            }

            DemoHelper.demoSectionHeader(title: "Options")
                .padding(.top, 20)

            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    ThemedButton(text: "Toggle", action: {
                        if badgeValue != nil {
                            badgeValue = nil
                        } else {
                            badgeValue = 1
                        }
                    })

                    Spacer()
                    ThemedButton(text: "Max", action: {
                        badgeValue = 100
                    })
                    Spacer()
                    ThemedButton(text: "Indicator", action: {
                        badgeValue = 0
                    })
                    Spacer()
                }
                HStack {
                    Spacer()
                    ThemedButton(text: "Increase", action: {
                        if let currentValue = badgeValue {
                            badgeValue = min(currentValue + 1, 100)
                        } else {
                            badgeValue = 1
                        }
                    })
                    Spacer()
                    ThemedButton(text: "Decrease", action: {
                        if let currentValue = badgeValue {
                            badgeValue = max(currentValue - 1, 1)
                        }
                    })
                    Spacer()
                }
            }

            Spacer()
        }
        .padding(.horizontal, Spacing.space200)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Icon.bell.image
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 20, height: 20)
                    .badgeView(badgeValue: $badgeValue)
            }
        }
    }

    private func button(label: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: CornerRadius.m)
                .fill(.black)
            Text.build(theme.font.small.bold(label))
                .padding()
                .foregroundColor(Colors.primary.white)
        }
        .frame(width: 110, height: 44)
    }
}

#Preview {
    BadgeDemoView()
}
