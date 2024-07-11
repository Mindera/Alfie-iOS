import Foundation
import SwiftUI
import UIKit

// MARK: - AttributedString

extension AttributedString {
    public func build(font: UIFont,
                      lineHeight: CGFloat? = nil,
                      letterSpacing: CGFloat? = nil,
                      strike: Bool = false,
                      isUnderlined: Bool = false,
                      foregroundColor: Color? = nil,
                      backgroundColor: Color? = nil) -> AttributedString {
        guard !characters.isEmpty else {
            return self
        }
        var container = AttributeContainer()
        container.font = font
        if let foregroundColor {
            container.foregroundColor = foregroundColor
        }
        if let backgroundColor {
            container.backgroundColor = backgroundColor
        }
        if let letterSpacing {
            container.kern = letterSpacing
        }
        container.underlineStyle = isUnderlined ? .single : nil
        container.strikethroughStyle = strike ? .single : nil

        var attributedString = self
        attributedString.mergeAttributes(container)
        // workaround to avoid "Conformance of 'NSParagraphStyle' to 'Sendable' is unavailable" if setting paragraphStyle in the container
        attributedString.mergeAttributes(.init([.paragraphStyle: paragraphStyle(attributedString: attributedString, lineHeight: lineHeight)]))
        return attributedString
    }

    private func paragraphStyle(attributedString: AttributedString, lineHeight: CGFloat?) -> NSParagraphStyle {
        let languageCode = UIView.appearance().semanticContentAttribute == .forceLeftToRight ? "en" : "ar"
        let paragraphStyle: NSMutableParagraphStyle = {
            if !attributedString.characters.isEmpty {
                return NSAttributedString(attributedString).attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
            } else {
                return NSMutableParagraphStyle()
            }
        }()
        if let lineHeight {
            paragraphStyle.lineSpacing = lineHeight
        }
        paragraphStyle.baseWritingDirection = NSParagraphStyle.defaultWritingDirection(forLanguage: languageCode)
        return paragraphStyle
    }
}

// MARK: - NSAttributedString

extension NSAttributedString {
    public static func fromHtml(_ htmlString: String,
                                font: UIFont,
                                color: UIColor,
                                lineHeight: CGFloat? = nil,
                                textAlignment: NSTextAlignment = .left)
        -> NSAttributedString? {
        let htmlData = htmlString.data(using: .unicode) ?? Data(htmlString.utf8)
        guard let attributedString = try? NSMutableAttributedString(data: htmlData,
                                                                    options: [.documentType: NSAttributedString.DocumentType.html],
                                                                    documentAttributes: nil)
        else {
            return NSAttributedString(string: htmlString)
        }

        let fontSize = font.pointSize
        let paragraphLineHeight = lineHeight ?? fontSize + 8.0
        let range = NSRange(location: 0, length: attributedString.length)
        let isLTR = UIView.appearance().semanticContentAttribute == .forceLeftToRight

        attributedString.addAttributes([.font: font], range: range)
        attributedString.addAttribute(.foregroundColor, value: color, range: range)

        attributedString.enumerateAttribute(.paragraphStyle, in: range, options: []) { paragraphStyle, range, _ in
            guard let paragraphStyle = paragraphStyle as? NSParagraphStyle else { return }

            let updatedStyle = NSMutableParagraphStyle()
            updatedStyle.setParagraphStyle(paragraphStyle)
            updatedStyle.minimumLineHeight = paragraphLineHeight
            updatedStyle.maximumLineHeight = paragraphLineHeight
            updatedStyle.baseWritingDirection = isLTR ? .leftToRight : .rightToLeft
            if textAlignment != .left {
                updatedStyle.alignment = textAlignment
            } else {
                updatedStyle.alignment = isLTR ? .left : .right
            }

            // Adjust tabs for bullets added to represent list items
            if !paragraphStyle.textLists.isEmpty {
                updatedStyle.tabStops = [
                    NSTextTab(textAlignment: .natural, location: 1),
                    NSTextTab(textAlignment: .natural, location: fontSize),
                ]
                updatedStyle.textLists = []
                updatedStyle.firstLineHeadIndent = 0
                updatedStyle.headIndent = fontSize + 0.5
                updatedStyle.defaultTabInterval = 0
            }

            attributedString.addAttribute(.paragraphStyle, value: updatedStyle, range: range)
        }
        return attributedString
    }

    public func trimmed() -> NSAttributedString {
        let nonNewlines = CharacterSet.whitespacesAndNewlines.inverted
        let startRange = string.rangeOfCharacter(from: nonNewlines)
        let endRange = string.rangeOfCharacter(from: nonNewlines, options: .backwards)
        guard let startLocation = startRange?.lowerBound, let endLocation = endRange?.lowerBound else {
            return self
        }

        let range = NSRange(startLocation ... endLocation, in: string)
        return attributedSubstring(from: range)
    }

    public func underline(selectedString: String?) -> AttributedString {
        guard let selectedString else {
            return AttributedString(self)
        }

        let mutableString: NSMutableAttributedString = .init(attributedString: self)
        let range = (string.lowercased() as NSString).range(of: selectedString.lowercased())
        mutableString.addAttribute(.underlineStyle,
                                   value: NSUnderlineStyle.single.rawValue,
                                   range: range)
        return AttributedString(mutableString)
    }

    public func hightlightedAttributedString(with subString: String, font: UIFont, color: UIColor) -> AttributedString {
        let range = (self.string.lowercased() as NSString).range(of: subString.lowercased())
        let highlightedSuggestion: NSMutableAttributedString = .init(attributedString: self)
        highlightedSuggestion.addAttribute(NSAttributedString.Key.font, value: font, range: range)
        highlightedSuggestion.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        return AttributedString(highlightedSuggestion)
    }
}

// MARK: - SwiftUI helper

public extension Text {
    static func build(_ attributedString: AttributedString) -> some View {
        var lineSpacing: CGFloat = 0

        if let font = attributedString.uiKit.font,
           // equivalent UIKit NSParagraphStyle not available yet in AttributeScopes.SwiftUIAttributes
           let paragraphStyle = NSAttributedString(attributedString).attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle {
            lineSpacing = paragraphStyle.lineSpacing - font.pointSize
        }

        return Text.format(attributedString)
            .lineSpacing(lineSpacing) // needs a modifier as there are no AttributedString SwiftUI attribute
    }

    static func build(_ attributedString: AttributedString, highlighting: String, font: UIFont, color: Color) -> some View {
        build(NSAttributedString(attributedString).hightlightedAttributedString(with: highlighting, font: font, color: color.ui))
    }

    private static func format(_ attributedString: AttributedString) -> Text {
        guard !attributedString.characters.isEmpty else {
            return .init("")
        }

        var text = Text(attributedString)
        if let font = attributedString.font {
            text = text.font(font)
        }
        if let kern = attributedString.kern {
            text = text.kerning(kern)
        }
        if attributedString.strikethroughStyle != nil {
            if let strikeColor = attributedString.strikethroughColor {
                text = text.strikethrough(true, color: Color(strikeColor))
            } else {
                text = text.strikethrough(true)
            }
        }
        if attributedString.underlineStyle != nil {
            if let underlineColor = attributedString.underlineColor {
                text = text.underline(true, color: Color(underlineColor))
            } else {
                text = text.underline(true)
            }
        }

        return text
    }
}

public extension UIFont {
    var font: Font {
        .init(self)
    }
}
