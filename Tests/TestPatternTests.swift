import CoreImage
import CoreImageExtensions
import UniformTypeIdentifiers
import XCTest


/// These tests can be used to generate EDR & wide gamut test pattern images in various formats.
/// The generated images are attached to the test runs and can be found when opening the test result
/// in the Reports navigator.
@available(iOS 14.0, macOS 11.0, macCatalyst 14.0, tvOS 14.0, *)
class TestPatternTests: XCTestCase {

    let context = CIContext()

    /// Helper type for assigning some human-readable labels to color spaces.
    private typealias ColorSpace = (cgSpace: CGColorSpace, label: String)

    // Some common color spaces that we want to generate patterns in.
    private let sRGBColorSpace = ColorSpace(.sRGBColorSpace!, "sRGB")
    private let extendedLinearSRGBColorSpace = ColorSpace(.extendedLinearSRGBColorSpace!, "extended linear sRGB")
    private let displayP3ColorSpace = ColorSpace(.displayP3ColorSpace!, "Display P3")
    private let itur2020ColorSpace = ColorSpace(.itur2020ColorSpace!, "BT.2020")
    private let itur2100HLGColorSpace = ColorSpace(.itur2100HLGColorSpace!, "BT.2100 HLG")
    private let itur2100PQColorSpace = ColorSpace(.itur2100PQColorSpace!, "BT.2100 PQ")

    /// Color spaces that are suitable for image formats with low bit-depth (i.e. 8-bit).
    private lazy var lowBitColorSpaces: [ColorSpace] = [sRGBColorSpace, displayP3ColorSpace]
    /// Color spaces that require image formats with higher bit depth to not cause quantization artifacts
    /// between consecutive color values.
    private lazy var highBitColorSpaces: [ColorSpace] = [itur2020ColorSpace, itur2100HLGColorSpace, itur2100PQColorSpace]


    /// Generates a test pattern image. The parameters are used to compose the label that is added at the bottom of the pattern image.
    private func testPattern(for fileType: UTType, bitDepth: Int, isFloat: Bool, colorSpace: ColorSpace) -> CIImage {
        let label = "\(fileType.preferredFilenameExtension!.uppercased()), \(bitDepth)-bit, \(isFloat ? "float, " : "")\(colorSpace.label)"
        return CIImage.testPattern(label: label)
    }

    /// Attaches the given image `data` of the given `type` to the test case so it can be retrieved from the test report after the run.
    /// The other parameters are used for naming the file in accordance with the image properties.
    private func attach(_ data: Data, type: UTType, bitDepth: Int, isFloat: Bool, colorSpace: ColorSpace) {
        let attachment = XCTAttachment(data: data, uniformTypeIdentifier: type.identifier)
        attachment.lifetime = .keepAlways
        let colorSpaceFileName = colorSpace.label.replacingOccurrences(of: " ", with: "-")
        attachment.name = "TestPattern_\(bitDepth)bit_\(isFloat ? "float_" : "")\(colorSpaceFileName).\(type.preferredFilenameExtension!)"
        self.add(attachment)
    }


    /// Generates an EDR & wide gamut test pattern image in EXR file format.
    /// Since EDR can store values as-is, we only generate one 16-bit float image in extended linear sRGB color space,
    /// which are the reference properties when composing the test pattern.
    func testEXRPatternGeneration() throws {
        let testPattern = self.testPattern(for: .exr, bitDepth: 16, isFloat: true, colorSpace: extendedLinearSRGBColorSpace)
        let data = try self.context.exrRepresentation(of: testPattern, format: .RGBAh, colorSpace: extendedLinearSRGBColorSpace.cgSpace)
        self.attach(data, type: .exr, bitDepth: 16, isFloat: true, colorSpace: extendedLinearSRGBColorSpace)

    }

    /// Generates EDR & wide gamut test pattern images in TIFF file format.
    /// Since TIFF can store 16-bit floating-point values, we generate an image in extended linear sRGB color space,
    /// which are the reference properties when composing the test pattern.
    /// We also generate images in the HDR color spaces for reference.
    func testTIFFPatternGeneration() {
        for colorSpace in highBitColorSpaces + [extendedLinearSRGBColorSpace] {
            let testPattern = self.testPattern(for: .tiff, bitDepth: 16, isFloat: true, colorSpace: colorSpace)
            let data = self.context.tiffRepresentation(of: testPattern, format: .RGBAh, colorSpace: colorSpace.cgSpace)!
            self.attach(data, type: .tiff, bitDepth: 16, isFloat: true, colorSpace: colorSpace)
        }
    }

    /// Generates EDR & wide gamut test pattern images in PNG file format.
    /// PNG supports 8- and 16-bit color depths, so we generate patterns in the color spaces fitting those bit depths.
    /// However, PNG does not support floating-point values, so we don't need to generate an image in extended color space.
    func testPNGPatternGeneration() {
        for colorSpace in lowBitColorSpaces {
            let testPattern = self.testPattern(for: .png, bitDepth: 8, isFloat: false, colorSpace: colorSpace)
            let data = self.context.pngRepresentation(of: testPattern, format: .RGBA8, colorSpace: colorSpace.cgSpace)!
            self.attach(data, type: .png, bitDepth: 8, isFloat: false, colorSpace: colorSpace)
        }

        for colorSpace in highBitColorSpaces {
            let testPattern = self.testPattern(for: .png, bitDepth: 16, isFloat: false, colorSpace: colorSpace)
            let data = self.context.pngRepresentation(of: testPattern, format: .RGBAh, colorSpace: colorSpace.cgSpace)!
            self.attach(data, type: .png, bitDepth: 16, isFloat: false, colorSpace: colorSpace)
        }
    }

    /// Generates EDR & wide gamut test pattern images in JPEG file format.
    /// JPEG only supports 8-bit color depth, so we only generate images in color spaces that are fitting for 8-bit.
    func testJPEGPatternGeneration() {
        for colorSpace in lowBitColorSpaces {
            let testPattern = self.testPattern(for: .jpeg, bitDepth: 8, isFloat: false, colorSpace: colorSpace)
            let data = self.context.jpegRepresentation(of: testPattern, colorSpace: colorSpace.cgSpace, options: [.quality: 1.0])!
            self.attach(data, type: .jpeg, bitDepth: 8, isFloat: false, colorSpace: colorSpace)
        }
    }

    /// Generates EDR & wide gamut test pattern images in HEIC file format.
    /// HEIC supports 8- and 10-bit color depths, so we generate patterns in the color spaces fitting those bit depths.
    /// However, HEIC does not support floating-point values, so we don't need to generate an image in extended color space.
    func testHEICPatternGeneration() throws {
        for colorSpace in lowBitColorSpaces {
            let testPattern = self.testPattern(for: .heic, bitDepth: 8, isFloat: false, colorSpace: colorSpace)
            let data = self.context.heifRepresentation(of: testPattern, format: .RGBA8, colorSpace: colorSpace.cgSpace, options: [.quality: 1.0])!
            self.attach(data, type: .heic, bitDepth: 8, isFloat: false, colorSpace: colorSpace)
        }

        if #available(iOS 15.0, macOS 12.0, macCatalyst 15.0, tvOS 15.0, *) {
            for colorSpace in highBitColorSpaces {
                let testPattern = self.testPattern(for: .heic, bitDepth: 10, isFloat: false, colorSpace: colorSpace)
                let data = try! self.context.heif10Representation(of: testPattern, colorSpace: colorSpace.cgSpace, options: [.quality: 1.0])
                self.attach(data, type: .heic, bitDepth: 10, isFloat: false, colorSpace: colorSpace)
            }
        }
    }

    /// Generates EDR & wide gamut test pattern images in PNG file format that is tone-mapped from BT.2100 PQ (HDR) to sRGB
    /// to demonstrate what it might roughly like on EDR-capable screens (just much dimmer).
    func testToneMappedPatternGeneration() {
        let testPattern = CIImage.testPattern(label: "BT.2100 PQ (HDR) tone-mapped to sRGB")
        // Create a pattern image that contains HDR data.
        let hdrData = self.context.pngRepresentation(of: testPattern, format: .RGBAh, colorSpace: .itur2100PQColorSpace!)!
        // Load that data again into a `CIImage` and let CI perform tone-mapping to SDR.
        let toneMappedImage = CIImage(data: hdrData, options: [CIImageOption.toneMapHDRtoSDR: true])!
        // Render the tone-mapped SDR image in sRGB and save as attachment.
        let data = self.context.pngRepresentation(of: toneMappedImage, format: .RGBA8, colorSpace: .sRGBColorSpace!)!
        let attachment = XCTAttachment(data: data, uniformTypeIdentifier: UTType.png.identifier)
        attachment.lifetime = .keepAlways
        attachment.name = "TestPattern_tone-mapped.png"
        self.add(attachment)
    }

}


@available(iOS 14.0, macOS 11.0, macCatalyst 14.0, tvOS 14.0, *)
private extension UTType {
    static var exr: Self { UTType("com.ilm.openexr-image")! }
}

private extension CIImageRepresentationOption {
    static var quality: Self { CIImageRepresentationOption(rawValue: kCGImageDestinationLossyCompressionQuality as String) }
}
