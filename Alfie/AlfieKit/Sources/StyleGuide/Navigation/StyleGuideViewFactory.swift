import Navigation
import SwiftUI

public final class StyleGuideViewFactory: ViewFactoryProtocol {
    public typealias Screen = StyleGuideScreen
    public init() {}

    @ViewBuilder
    public func view(for screen: StyleGuideScreen) -> some View {
        switch screen {
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

        case .pageControl:
            PageControlDemoView()
                .modifier(ContainerDemoViewModifier())

        case .dividers:
            DividerDemoView()
                .modifier(ContainerDemoViewModifier())

        case .snackbars:
            SnackbarDemoView()

        case .buttons:
            ButtonDemoView()
                .modifier(ContainerDemoViewModifier())

        case .tags:
            TagDemoView()
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

        case .motion:
            MotionDemoView()
                .modifier(ContainerDemoViewModifier())

        case .accordion:
            AccordionDemoView()
                .modifier(ContainerDemoViewModifier())

        case .toolbar:
            ToolbarDemoView()

        case .demo:
            StyleGuideDemoView()

        case .skeleton:
            SkeletonDemoView()
                .modifier(ContainerDemoViewModifier())
        }
    }
}
