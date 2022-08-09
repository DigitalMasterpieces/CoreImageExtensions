import CoreImage


public extension CIColor {

    /// Initializes a `CIColor` object with the specified `white` component value in all three (RGB) channels.
    /// - Parameters:
    ///   - white: The unpremultiplied component value that should be use for all three color channels.
    ///   - alpha: The alpha (opacity) component of the color.
    ///   - colorSpace: The color space in which to create the new color. This color space must conform to the `CGColorSpaceModel.rgb` color space model.
    convenience init?(white: CGFloat, alpha: CGFloat = 1.0, colorSpace: CGColorSpace? = nil) {
        if let colorSpace = colorSpace {
            self.init(red: white, green: white, blue: white, alpha: alpha, colorSpace: colorSpace)
        } else {
            self.init(red: white, green: white, blue: white, alpha: alpha)
        }
    }

    /// Initializes a `CIColor` object with the specified extended white component value in all three (RGB) channels.
    ///
    /// The color will use the extended linear sRGB color space, which allows EDR values outside of the `[0...1]` SDR range.
    ///
    /// - Parameters:
    ///   - white: The unpremultiplied component value that should be use for all three color channels.
    ///            This value can be outside of the `[0...1]` SDR range to create an EDR color.
    ///   - alpha: The alpha (opacity) component of the color.
    convenience init?(extendedWhite white: CGFloat, alpha: CGFloat = 1.0) {
        guard let colorSpace = CGColorSpace.extendedLinearSRGBColorSpace else { return nil }
        self.init(white: white, alpha: alpha, colorSpace: colorSpace)
    }

    /// Initializes a `CIColor` object with the specified extended component values.
    ///
    /// The color will use the extended linear sRGB color space, which allows EDR values outside of the `[0...1]` SDR range.
    ///
    /// - Parameters:
    ///   - r: The unpremultiplied red component value.
    ///        This value can be outside of the `[0...1]` SDR range to create an EDR color.
    ///   - g: The unpremultiplied green component value.
    ///        This value can be outside of the `[0...1]` SDR range to create an EDR color.
    ///   - b: The unpremultiplied blue component value.
    ///        This value can be outside of the `[0...1]` SDR range to create an EDR color.
    ///   - a: The alpha (opacity) component of the color.
    convenience init?(extendedRed r: CGFloat, green g: CGFloat, blue b: CGFloat, alpha a: CGFloat = 1.0) {
        guard let colorSpace = CGColorSpace.extendedLinearSRGBColorSpace else { return nil }
        self.init(red: r, green: g, blue: b, alpha: a, colorSpace: colorSpace)
    }

    /// Returns a color that provides a high contrast to the receiver.
    ///
    /// The returned color is either black or white, depending on which has the better visibility
    /// when put over the receiver color.
    var contrastColor: CIColor {
        let lightColor = CIColor.white
        let darkColor = CIColor.black

        // Calculate luminance based on D65 white point (assuming linear color values).
        let luminance = (self.red * 0.2126) + (self.green * 0.7152) + (self.blue * 0.0722)
        // Compare against the perceptual luminance midpoint (0.5 after gamma correction).
        return (luminance > 0.214) ? darkColor : lightColor
    }

}
