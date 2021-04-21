import CoreImage


public extension CIContext {

    /// Errors that might be caused during image export.
    enum ExportError: Error {
        case unsupportedExtent(message: String)
        case renderingFailure(message: String)
        case imageDestinationCreationFailure(message: String)
    }


    /// Renders the image and exports the resulting image data in EXR format.
    ///
    /// To render an image for export, the image’s contents must not be empty and its extent dimensions must be finite.
    /// To export after applying a filter whose output has infinite extent, see the clampedToExtent() method.
    ///
    /// ⚠️ Note: Due to a bug in Apple's EXR encoder (FB9080694), the image height must be at least 16 pixels!
    ///          It will cause a BAD_ACCESS otherwise.
    ///
    /// No options keys are supported at this time.
    ///
    /// - Parameters:
    ///   - image: The image to render.
    ///   - format: The pixel format for the output image.
    ///   - colorSpace: The color space in which to render the output image. This color space must conform
    ///                 to either the `CGColorSpaceModel.rgb` or `CGColorSpaceModel.monochrome` model and must be compatible
    ///                 with the specified pixel format.
    ///   - options: No options keys are supported at this time.
    /// - Returns: A data representation of the rendered image in EXR format.
    /// - Throws: A `CIContext.ExportError` if the image data could not be created.
    func exrRepresentation(of image: CIImage, format: CIFormat, colorSpace: CGColorSpace?, options: [CIImageRepresentationOption: Any] = [:]) throws -> Data {
        let cgImage = try self.createCGImageForEXRExport(of: image, format: format, colorSpace: colorSpace)

        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data, "com.ilm.openexr-image" as CFString, 1, nil) else {
            throw ExportError.imageDestinationCreationFailure(message: "Failed to create an EXR image destination")
        }
        CGImageDestinationAddImage(destination, cgImage, image.properties as CFDictionary)
        CGImageDestinationFinalize(destination)

        return data as Data
    }

    /// Renders the image and exports the resulting image data as a file in EXR format.
    ///
    /// To render an image for export, the image’s contents must not be empty and its extent dimensions must be finite.
    /// To export after applying a filter whose output has infinite extent, see the clampedToExtent() method.
    ///
    /// ⚠️ Note: Due to a bug in Apple's EXR encoder (FB9080694), the image height must be at least 16 pixels!
    ///          It will cause a BAD_ACCESS otherwise.
    ///
    /// No options keys are supported at this time.
    ///
    /// - Parameters:
    ///   - image: The image to render.
    ///   - url: The file URL at which to write the output EXR file.
    ///   - format: The pixel format for the output image.
    ///   - colorSpace: The color space in which to render the output image. This color space must conform
    ///                 to either the `CGColorSpaceModel.rgb` or `CGColorSpaceModel.monochrome` model and must be compatible
    ///                 with the specified pixel format.
    ///   - options: No options keys are supported at this time.
    /// - Throws: A `CIContext.ExportError` if the image could not be written to the file.
    func writeEXRRepresentation(of image: CIImage, to url: URL, format: CIFormat, colorSpace: CGColorSpace, options: [CIImageRepresentationOption: Any] = [:]) throws {
        let cgImage = try self.createCGImageForEXRExport(of: image, format: format, colorSpace: colorSpace)

        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, "com.ilm.openexr-image" as CFString, 1, nil) else {
            throw ExportError.imageDestinationCreationFailure(message: "Failed to create an EXR image destination")
        }
        CGImageDestinationAddImage(destination, cgImage, image.properties as CFDictionary)
        CGImageDestinationFinalize(destination)
    }

    private func createCGImageForEXRExport(of image: CIImage, format: CIFormat, colorSpace: CGColorSpace?) throws -> CGImage {
        guard image.extent.height >= 16 else {
            throw ExportError.unsupportedExtent(message: "The image's height must be at least 16 due to a bug in Apple's EXR encoder implementation")
        }
        guard !image.extent.isInfinite else {
            throw ExportError.unsupportedExtent(message: "The image's extent must be finite")
        }
        guard let cgImage = self.createCGImage(image, from: image.extent, format: format, colorSpace: colorSpace) else {
            throw ExportError.renderingFailure(message: "Failed to render image")
        }
        return cgImage
    }

}
