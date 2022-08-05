import CoreImage
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif


/// Some convenience methods for rendering text into a `CIImage`.
extension CIImage {

    /// Generates an image that contains the given text.
    /// - Parameters:
    ///   - text: The string of text to render.
    ///   - fontName: The name of the font that should be used for rendering the text.
    ///   - fontSize: The size of the font that should be used for rendering the text.
    ///   - color: The color of the text. The background of the text will be transparent.
    ///   - padding: A padding to add around the text, effectively increasing the text's virtual `extent`.
    /// - Returns: An image containing the rendered text.
    @available(iOS 11.0, macCatalyst 13.1, macOS 10.13, tvOS 11.0, *)
    public static func text(_ text: String, fontName: String = "HelveticaNeue", fontSize: CGFloat = 12.0, color: CIColor = .black, padding: CGFloat = 0.0) -> CIImage? {
        guard let textGenerator = CIFilter(name: "CITextImageGenerator") else { return nil }

        textGenerator.setValue(fontName, forKey: "inputFontName")
        textGenerator.setValue(fontSize, forKey: "inputFontSize")
        textGenerator.setValue(text, forKey: "inputText")
        if #available(iOS 16.0, macCatalyst 16.0, macOS 13.0, tvOS 16.0, *) {
            // Starting from iOS 16 / macOS 13 we can use the built-in padding property...
            textGenerator.setValue(padding, forKey: "inputPadding")
            return textGenerator.outputImage?.colorized(with: color)
        } else {
            // ... otherwise we will do the padding manually.
            return textGenerator.outputImage?.colorized(with: color)?.paddedBy(dx: padding, dy: padding).moved(to: .zero)
        }
    }

#if canImport(AppKit)

    /// Generates an image that contains the given text.
    /// - Parameters:
    ///   - text: The string of text to render.
    ///   - font: The `NSFont` that should be used for rendering the text.
    ///   - color: The color of the text. The background of the text will be transparent.
    ///   - padding: A padding to add around the text, effectively increasing the text's virtual `extent`.
    /// - Returns: An image containing the rendered text.
    @available(macOS 10.13, *)
    @available(iOS, unavailable)
    @available(macCatalyst, unavailable)
    @available(tvOS, unavailable)
    public static func text(_ text: String, font: NSFont, color: CIColor = .black, padding: CGFloat = 0.0) -> CIImage? {
        return self.text(text, fontName: font.fontName, fontSize: font.pointSize, color: color, padding: padding)
    }

#endif

#if canImport(UIKit)

    /// Generates an image that contains the given text.
    /// - Parameters:
    ///   - text: The string of text to render.
    ///   - font: The `UIFont` that should be used for rendering the text.
    ///   - color: The color of the text. The background of the text will be transparent.
    ///   - padding: A padding to add around the text, effectively increasing the text's virtual `extent`.
    /// - Returns: An image containing the rendered text.
    @available(iOS 11.0, macCatalyst 13.1, macOS 10.13, tvOS 11.0, *)
    public static func text(_ text: String, font: UIFont, color: CIColor = .black, padding: CGFloat = 0.0) -> CIImage? {
        return self.text(text, fontName: font.fontName, fontSize: font.pointSize, color: color, padding: padding)
    }

#endif

    /// Generates an image that contains the given attributed text.
    /// - Parameters:
    ///   - attributedText: The `NSAttributedString` to render.
    ///   - padding: A padding to add around the text, effectively increasing the text's virtual `extent`.
    /// - Returns: An image containing the rendered attributed text
    @available(iOS 11.0, macCatalyst 13.1, macOS 10.13, tvOS 11.0, *)
    public static func attributedText(_ attributedText: NSAttributedString, padding: CGFloat = 0.0) -> CIImage? {
        guard let textGenerator = CIFilter(name: "CIAttributedTextImageGenerator") else { return nil }

        textGenerator.setValue(attributedText, forKey: "inputText")
        if #available(iOS 16.0, macCatalyst 16.0, macOS 13.0, tvOS 16.0, *) {
            // Starting from iOS 16 / macOS 13 we can use the built-in padding property...
            textGenerator.setValue(padding, forKey: "inputPadding")
            return textGenerator.outputImage
        } else {
            // ... otherwise we will do the padding manually.
            return textGenerator.outputImage?.paddedBy(dx: padding, dy: padding).moved(to: .zero)
        }
    }

}
