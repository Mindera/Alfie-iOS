import SwiftUI

public struct StyleGuideDemoView: View {
    public init() {
        ThemeProvider.shared.setupAppearance()
    }

    public var body: some View {
        VStack {
            List {
                link(for: .accordion, text: "Accordion")
                link(for: .badges, text: "Badge")
                link(for: .buttons, text: "Button")
                link(for: .checkboxes, text: "Checkbox")
                link(for: .chips, text: "Chips")
                link(for: .color, text: "Color Palette")
                link(for: .colorSwatches, text: "Color Swatches")
                link(for: .datePicker, text: "Date Picker")
                link(for: .dividers, text: "Divider")
                link(for: .shadows, text: "Elevation / Shadowing")
                link(for: .icons, text: "Iconography")
                link(for: .inputs, text: "Input Fields")
                link(for: .loading, text: "Loading")
                link(for: .modal, text: "Modal")
                link(for: .motion, text: "Motion")
                link(for: .price, text: "Price")
                link(for: .pdpImageGallery, text: "PDP Image Gallery")
                link(for: .pdpSnapImageGallery, text: "PDP Snap Image Gallery")
                link(for: .productCard, text: "Product Card")
                link(for: .productCarousel, text: "Product Carousel")
                link(for: .progressBar, text: "Progress Bar")
                link(for: .pageControl, text: "Progress Indicators")
                link(for: .radioButtonsList, text: "Radio Buttons")
                link(for: .cornerRadius, text: "Rounded Corners")
                link(for: .search, text: "Search Bar")
                link(for: .segments, text: "Segmented Controls")
                link(for: .sizingSwaches, text: "Sizing Swatches")
                link(for: .skeleton, text: "Skeleton Animation")
                link(for: .snackbars, text: "Snackbars")
                link(for: .spacings, text: "Spacing")
                link(for: .sortBy, text: "Sort By")
                link(for: .tabControlIntrisicWidth, text: "Tab Control (Intrinsic Width)")
                link(for: .tabControlFixedWidth, text: "Tab Control (Fixed Width)")
                link(for: .tags, text: "Tag")
                link(for: .toolbar, text: "Title Header")
                link(for: .toggle, text: "Toggle")
                link(for: .typography, text: "Typography")
            }
            .listStyle(.plain)
        }
        .navigationDestination(for: DemoNavigation.self) { destination in
            navigateTo(destination)
        }
    }

    private func link(for link: DemoNavigation, text: String) -> some View {
        NavigationLink(value: link) {
            Text.build(theme.font.small.normal(text))
        }
    }

    @ViewBuilder
    private func navigateTo(_ destination: DemoNavigation) -> some View {
        switch destination {
            case .cornerRadius:
                CornerRadiusDemoView()
                    .modifier(ContainerDemoViewModifier())
            case .typography:
                TypographyDemoView()
                    .modifier(ContainerDemoViewModifier())
            case .color:
                ColorsDemoView()
                    .modifier(ContainerDemoViewModifier())
            case .icons:
                IconographyDemoView()
                    .modifier(ContainerDemoViewModifier())
            case .badges:
                BadgeDemoView()
                    .modifier(ContainerDemoViewModifier())
            case .spacings:
                SpacingDemoView()
                    .modifier(ContainerDemoViewModifier())
            case .dividers:
                DividerDemoView()
                    .modifier(ContainerDemoViewModifier())
            case .tags:
                TagDemoView()
                    .modifier(ContainerDemoViewModifier())
            case .snackbars:
                SnackbarDemoView() // Don't apply the modifier here, the view has tabs for demo purposes
            case .buttons:
                ButtonDemoView()
                    .modifier(ContainerDemoViewModifier())
            case .toggle:
                ToggleDemoView()
                    .modifier(ContainerDemoViewModifier())
            case .datePicker:
                DatePickerDemoView()
                    .modifier(ContainerDemoViewModifier())
            case .shadows:
                ShadowDemoView()
                    .modifier(ContainerDemoViewModifier())
            case .progressBar:
                ProgressBarDemoView()
                    .modifier(ContainerDemoViewModifier())
            case .inputs:
                InputDemoView()
                    .modifier(ContainerDemoViewModifier())
            case .loading:
                LoadingDemoView()
                    .modifier(ContainerDemoViewModifier())
            case .sizingSwaches:
                SizingBannerDemoView()
                    .modifier(ContainerDemoViewModifier())
            case .colorSwatches:
                ColorBannerDemoView()
                    .modifier(ContainerDemoViewModifier())
            case .checkboxes:
                CheckboxesDemoView()
                    .modifier(ContainerDemoViewModifier())
            case .radioButtonsList:
                RadioListDemoView()
                    .modifier(ContainerDemoViewModifier())
            case .pageControl:
                if #available(iOS 17.0, *) {
                    PageControlCarouselDemoView()
                        .modifier(ContainerDemoViewModifier())
                } else {
                    PageControlDemoView()
                        .modifier(ContainerDemoViewModifier())
                }
            case .modal:
                ModalDemoView()
                    .modifier(ContainerDemoViewModifier())
            case .motion:
                MotionDemoView()
                    .modifier(ContainerDemoViewModifier())
            case .accordion:
                AccordionDemoView()
                    .modifier(ContainerDemoViewModifier())
            case .search:
                SearchBarDemoView()
                    .modifier(ContainerDemoViewModifier(embedInScrollView: false))
            case .skeleton:
                SkeletonDemoView()
                    .modifier(ContainerDemoViewModifier())
            case .sortBy:
                DemoSortByView()
                    .modifier(ContainerDemoViewModifier())
            case .toolbar:
                ToolbarDemoView()
            case .pdpImageGallery:
                CarouselDemoView()
                    .modifier(ContainerDemoViewModifier(embedInScrollView: false))
            case .pdpSnapImageGallery:
                SnapCarouselDemoView()
                    .modifier(ContainerDemoViewModifier(embedInScrollView: false))
            case .productCard:
                ProductCardDemoView()
                    .modifier(ContainerDemoViewModifier(embedInScrollView: false))
            case .productCarousel:
                ProductCarouselDemoView()
                    .modifier(ContainerDemoViewModifier())
            case .chips:
                ChipsDemoView()
                    .modifier(ContainerDemoViewModifier(embedInScrollView: false))
            case .price:
                PriceComponentDemoView()
                    .modifier(ContainerDemoViewModifier())
            case .tabControlIntrisicWidth:
                TabControlIntrinsicWidthDemoView()
                    .modifier(ContainerDemoViewModifier())
            case .tabControlFixedWidth:
                TabControlFixedWidthDemoView()
                    .modifier(ContainerDemoViewModifier())
            case .segments:
                SegmentsDemoView()
                    .modifier(ContainerDemoViewModifier())
        }
    }

    private enum DemoNavigation: Hashable {
        case accordion
        case badges
        case buttons
        case checkboxes
        case chips
        case color
        case colorSwatches
        case cornerRadius
        case datePicker
        case dividers
        case icons
        case inputs
        case loading
        case modal
        case motion
        case pageControl
        case pdpImageGallery
        case pdpSnapImageGallery
        case price
        case productCard
        case productCarousel
        case progressBar
        case radioButtonsList
        case search
        case shadows
        case sizingSwaches
        case skeleton
        case snackbars
        case spacings
        case sortBy
        case tabControlIntrisicWidth
        case tabControlFixedWidth
        case tags
        case toggle
        case toolbar
        case typography
        case segments
    }
}

#Preview {
    StyleGuideDemoView()
}
