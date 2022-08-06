import CoreImage
import CoreImage.CIFilterBuiltins


/// Here we create an EDR brightness and wide gamut color test pattern image that can be used, for instance,
/// to verify colors are displayed correctly, filters conserve those color properties correctly, etc.
/// It also showcases how Core Image can be used for image compositing, though in production
/// a composition with this complexity is probably better done with Core Graphits since its too slow in CI.
/// ⚠️ For testing purposes only! This is not meant to be shipped in production code since generating
///    the pattern is slow and potentially error-prone (lots of force-unwraps in here for convenience).
@available(iOS 12.3, macCatalyst 13.1, macOS 10.14.3, tvOS 12.0, *)
extension CIImage {

    /// Create an EDR brightness and wide gamut color test pattern image that can be used, for instance,
    /// to verify colors are displayed correctly, filters conserve those color properties correctly, etc.
    ///
    /// The pattern contains a scale of different brightness values up to a peak EDR brightness of 3.2,
    /// which is the maximum brightness an XDR display from Apple can distinctly display.
    ///
    /// It also contains color swatches displaying different colors in tree different color spaces with
    /// increasing color gamut: sRGB, Display P3, and BT.2020 (from HDR video). Most Apple displays support P3 now,
    /// whereas only XDR displays and OLED screens can display the difference between P3 and BT.2020.
    ///
    /// You can also reduce the brightness of your display, which should reveal more levels of brightness and gamut.
    ///
    /// - Warning: ⚠️ For testing purposes only! This is not meant to be shipped in production code since generating
    ///               the pattern is slow and potentially error-prone (lots of force-unwraps in here for convenience).
    ///
    /// - Parameter label: An optional label text that will be added at the bottom left corner of the pattern.
    ///                    This can be used, for instance, for adding information about file format and color space of the rendering.
    /// - Returns: An EDR brightness and wide gamut color test pattern image.
    public static func testPattern(label: String? = nil) -> CIImage {
        // Note: Since Core Image's coordinate system has its origin in the lower left corner, we composite the pattern from the bottom up.

        // Start with an empty image and composite the pattern components on top.
        var pattern = CIImage.empty()

        // Add wide gamut color swatches in a grid in the lower part of the pattern.
        for (column, rowColors) in self.swatchColors.enumerated() {
            // Note: We reverse here so the first color specified in the array is displayed on the top.
            for (row, color) in rowColors.reversed().enumerated() {
                var swatch = CIImage.colorSwatch(for: color)
                swatch = swatch.moved(to: CGPoint(x: CGFloat(column) * (swatch.extent.width + self.margin), y: CGFloat(row) * (swatch.extent.height + self.margin)))
                pattern = swatch.composited(over: pattern)
            }
        }

        // Add the brightness scale above the color swatches.
        var brightnessScale = CIImage.brightnessScale(levels: self.brightnessScaleLevels)
        brightnessScale = brightnessScale.moved(to: CGPoint(x: 0, y: pattern.extent.maxY + self.margin))
        pattern = brightnessScale.composited(over: pattern)

        // Add a nice title to the pattern.
        var title = self.titleLabel()
        title = title.moved(to: CGPoint(x: 0, y: pattern.extent.maxY + self.margin))
        pattern = title.composited(over: pattern)

        // Add the given text label at the bottom left corner of the image, if any.
        if let labelText = label, !labelText.isEmpty {
            var label = CIImage.text(labelText, fontName: self.labelFont, fontSize: 30, color: .white)!
            label = label.moved(to: CGPoint(x: 0, y: -label.extent.height - self.margin))
            pattern = label.composited(over: pattern)
        }

        // Put everything on a black background.
        let background = CIImage(color: .black).cropped(to: pattern.extent.insetBy(dx: -self.margin, dy: -self.margin))
        return pattern.composited(over: background).moved(to: .zero)
    }


    // MARK: - Internal

    /// The size of the single color/brightness tiles.
    private static var tileSize: CGSize { CGSize(width: 160, height: 160) }
    /// The corner radius that is applied to color swatches and brightness scale.
    private static var tileCornerRadius: Double { 10 }
    /// The margin between elements in the pattern.
    private static var margin: CGFloat { 50 }
    /// The font to use for labels in the pattern.
    private static var labelFont: String { ".AppleSystemUIFontCompactRounded-Semibold" }
    /// Colors for which swatches should be rendered, ordered by columns (outer) and rows (inner arrays).
    private static var swatchColors: [[CIColor]] { [[.red, .green, .blue], [.cyan, .magenta, .yellow]] }
    /// The different color spaces in which colors should be rendered in the color swatches.
    private static var swatchColorSpaces: [(label: String, colorSpace: CGColorSpace)] = [
        ("sRGB", .extendedLinearSRGBColorSpace!),
        ("Display P3", .extendedLinearDisplayP3ColorSpace!),
        ("BT.2020", .extendedLinearITUR2020ColorSpace!)
    ]
    /// The different brightness values that should be rendered in the brightness scale.
    /// (The 3.2 is added manually because it's the peak brightness of Apple's XDR screens and should be included.)
    private static var brightnessScaleLevels: [Double] { Array(stride(from: 0.0, through: 3.0, by: 0.5)) + [3.2] }


    /// Creates a single tile (rectangle) filled with the given `color` in the given `colorSpace` with the given `size`
    /// and the given `label` string displayed on top of it.
    private static func colorTile(for color: CIColor, colorSpace: CGColorSpace, size: CGSize, label: String) -> CIImage {
        // Match the color from the given color space to the working space
        // so that all colors will be in the same base color space in the pattern.
        var tile = CIImage(color: color).matchedToWorkingSpace(from: colorSpace)!
        tile = tile.cropped(to: CGRect(origin: .zero, size: size))

        // Put the label in the bottom left corner over the tile.
        // Use a contrast color that is always readable, regardless of the tile's color.
        let labelImage = CIImage.text(label, fontName: self.labelFont, fontSize:  size.height / 8.0, color: color.contrastColor)!
        return labelImage.moved(to: CGPoint(x: 5, y: 5)).composited(over: tile)
    }

    /// Creates a swatch (line of colored tiles) for the given `color` for comparison.
    /// Each tile will display the color in one of the `swatchColorSpaces`.
    /// A label is added to the left next to the swatch displaying the color values.
    private static func colorSwatch(for color: CIColor) -> CIImage {
        // Generate a label to put next to the swatch.
        let labelText = String(format: """
            R: %.2f
            G: %.2f
            B: %.2f
            """, color.red, color.green, color.blue)
        var label = CIImage.text(labelText, fontName: ".AppleSystemUIFontMonospaced-Semibold", fontSize: self.tileSize.height / 7.0, color: .white, padding: 18)!

        // Generate a color tile for each color space and place them next to each other.
        var swatch = self.swatchColorSpaces.reduce(CIImage.empty()) { partialResult, entry in
            var tile = CIImage.colorTile(for: color, colorSpace: entry.colorSpace, size: self.tileSize, label: entry.label)
            tile = tile.translatedBy(dx: partialResult.extent.maxX.isInfinite ? 0 : partialResult.extent.maxX, dy: 0)
            return tile.composited(over: partialResult)
        }
        // Also apply some round corners to the whole swatch.
        swatch = swatch.withRoundedCorners(radius: self.tileCornerRadius)!

        // Adjust placement of label and swatch.
        label = label.centered(in: CGPoint(x: label.extent.midX, y: swatch.extent.midY))
        swatch = swatch.moved(to: CGPoint(x: label.extent.maxX, y: 0))

        return label.composited(over: swatch)
    }

    /// Creates a single tile (rectangle) filled with white (or gray) in the given `brightness` value with the given `size`.
    /// The tile will be labeled with the `brightness` value and the corresponding nits value
    /// (assuming standard brightness `1.0` = 500 nits).
    private static func brightnessTile(for brightness: Double, size: CGSize) -> CIImage {
        // Create the tile containing the brightness in all color channels.
        var tile = CIImage.containing(value: brightness)!
        tile = tile.cropped(to: CGRect(origin: .zero, size: size))

        // Put a label in the bottom left corner over the tile that displays the brightness value (also in nits).
        let labelText = String(format: "%.2f (%d nits)", brightness, Int(brightness * 500))
        let labelColor = CIColor(extendedWhite: brightness)!.contrastColor
        let label = CIImage.text(labelText, fontName: self.labelFont, fontSize: size.height / 8.0, color: labelColor)!
        return label.moved(to: CGPoint(x: 5, y: 5)).composited(over: tile)
    }

    /// Creates a "scale" (basically a long swatch) with tiles of different `levels` of brightness.
    /// It also adds an annotation below the scale showing which part of the scale is SDR (standard dynamic range)
    /// and which part is EDR (extended dynamic range).
    private static func brightnessScale(levels: [Double]) -> CIImage {
        // Create a long swatch containing the different brightness tiles.
        var scale = levels.reduce(CIImage.empty()) { partialResult, brightness in
            var tile = CIImage.brightnessTile(for: brightness, size: self.tileSize)
            tile = tile.translatedBy(dx: partialResult.extent.maxX.isInfinite ? 0 : partialResult.extent.maxX, dy: 0)
            return tile.composited(over: partialResult)
        }
        // Add some round corners.
        scale = scale.withRoundedCorners(radius: self.tileCornerRadius)!
        // Move the scale up so we can add the annotation below.
        scale = scale.translatedBy(dx: 0, dy: 80)

        // Annotation properties.
        let annotationColor = CIColor.white
        let annotationLineWidth: CGFloat = 2.0

        // Find the brightness that symbolizes "reference white" (i.e. brightness value 1.0).
        let referenceWhiteIndex = levels.firstIndex(where: { $0 >= 1.0 }) ?? levels.indices.upperBound
        // Find the place where the separator between SDR and EDR needs to go.
        let sdrEndSeparatorX = CGFloat(referenceWhiteIndex + 1) * self.tileSize.width - annotationLineWidth / 2.0

        // For drawing the "lines" we simply use a white image that we crop to narrow rectangles and place it under the scales.
        let line = CIImage(color: annotationColor)
        // One long line horizontal line below the scales.
        scale = line.cropped(to: CGRect(x: 0, y: 30, width: scale.extent.width, height: annotationLineWidth)).composited(over: scale)
        // Three small vertical "tick" lines marking the beginning and end of the swatch...
        scale = line.cropped(to: CGRect(x: 0, y: 30, width: annotationLineWidth, height: 40)).composited(over: scale)
        scale = line.cropped(to: CGRect(x: scale.extent.maxX - annotationLineWidth, y: 30, width: annotationLineWidth, height: 40)).composited(over: scale)
        // ... and the border between SDR and EDR.
        scale = line.cropped(to: CGRect(x: sdrEndSeparatorX, y: 30, width: annotationLineWidth, height: 40)).composited(over: scale)

        // Add an "SDR" label in the middle of the line below the SDR part of the scale.
        var sdrLabel = CIImage.text("SDR", fontName: self.labelFont, fontSize: 35, color: annotationColor, padding: 10)!
        sdrLabel = sdrLabel.moved(to: CGPoint(x: (sdrEndSeparatorX - sdrLabel.extent.width) / 2.0, y: 0))
        // Remove the part below the label from the annotation line by multiplying its color with black (zero) before adding the label on top.
        scale = CIImage(color: .black).cropped(to: sdrLabel.extent).composited(over: scale, using: .multiply)!
        scale = sdrLabel.composited(over: scale)

        // Add an "EDR" label in the middle of the line below the EDR part of the scale.
        var hdrLabel = CIImage.text("EDR", fontName: self.labelFont, fontSize: 35, color: annotationColor, padding: 10)!
        hdrLabel = hdrLabel.moved(to: CGPoint(x: sdrEndSeparatorX + (scale.extent.width - sdrEndSeparatorX - hdrLabel.extent.width) / 2.0, y: 0))
        // Remove the part below the label from the annotation line by multiplying its color with black (zero) before adding the label on top.
        scale = CIImage(color: .black).cropped(to: hdrLabel.extent).composited(over: scale, using: .multiply)!
        scale = hdrLabel.composited(over: scale)

        return scale
    }

    /// Creates a title label for the pattern that reads "EDR & Wide Gamut Test Pattern" with some fancy gradients.
    private static func titleLabel() -> CIImage {
        // Create a title label image. The 97 point font size will let the label have roughly the same width as the brightness scale.
        var label = CIImage.text("EDR & Wide Gamut Test Pattern", fontName: self.labelFont, fontSize: 97, color: .white)!

        // Add a gradient from bright EDR white to normal white over the "EDR" part of the label.
        let edrLabelRect = CGRect(x: 0, y: 0, width: 169, height: 116)
        let edrGradient = CIFilter(name: "CISmoothLinearGradient", parameters: [
            "inputPoint0": CIVector(x: edrLabelRect.minX, y: edrLabelRect.midY),
            "inputPoint1": CIVector(x: edrLabelRect.maxX, y: edrLabelRect.midY),
            "inputColor0": CIColor(extendedWhite: 3.2)!,
            "inputColor1": CIColor(white: 1.0)!
        ])!.outputImage!.cropped(to: edrLabelRect)
        label = edrGradient.composited(over: label, using: .sourceAtop)!

        // Add a "rainbow" color gradient over the "Wide Gamut" part of the Label.
        let wideGamutRect = CGRect(x: 248, y: 0, width: 523, height: 116)
        let wideGamutGradient = self.hueGradient(from: wideGamutRect.minX, to: wideGamutRect.maxX)
            .cropped(to: wideGamutRect)
            .matchedToWorkingSpace(from: .extendedLinearITUR2020ColorSpace!)!
        label = wideGamutGradient.composited(over: label, using: .sourceAtop)!

        return label
    }

    /// Generates an image containing a horizontal "rainbow" gradient containing all color hues.
    /// The hues are mapped to the x-axis between `startX` and `endX`.
    ///
    /// - Warning: ⚠️ This uses a simple color kernel written in the very much deprecated
    ///               Core Image Kernel Language that is compiled at runtime.
    ///               This is mainly for convenience reasons, but also because custom
    ///               Metal kernels can't be compiled in a Swift package yet.
    ///               If you want to use something similar in production, you should implement
    ///               it using a Metal kernel that is compiled (and validated) together with the
    ///               rest of the code.
    private static func hueGradient(from startX: CGFloat, to endX: CGFloat) -> CIImage {
        let kernelCode = """
            kernel vec4 hueGradient(float startX, float endX) {
                // Map the x-axis between the points to the hue value in HSV color space.
                float hue = (destCoord().x - startX) / (endX - startX);
                vec3 hsv = vec3(clamp(hue, 0.0, 1.0), 1.0, 1.0);
                // Convert HSV back to RGB (taken from https://stackoverflow.com/a/17897228/541016).
                vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                vec3 p = abs(fract(hsv.xxx + K.xyz) * 6.0 - K.www);
                return vec4(hsv.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), hsv.y), 1.0);
            }
        """
        let kernel = CIColorKernel(source: kernelCode)!
        return kernel.apply(extent: .infinite, arguments: [startX, endX])!
    }

}
