import SwiftUI

struct SwatchColors: ThemeReading {
    let border: Color
    let text: Color

    init(isSelected: Bool, isEnabled: Bool) {
        border = isEnabled && isSelected ? Self.theme.color.contentContentPrimary : Self.theme.color.borderSoft
        text = isEnabled ? Self.theme.color.contentContentPrimary : Self.theme.color.contentContentTerciary
    }
}
