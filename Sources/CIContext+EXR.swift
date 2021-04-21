import CoreImage


public extension CIContext {

    /// Renders the image and exports the resulting image data in EXR format.
    ///
    /// To render an image for export, the image’s contents must not be empty and its extent dimensions must be finite.
    /// To export after applying a filter whose output has infinite extent, see the clampedToExtent() method.
    ///
    /// No options keys are supported at this time.
    ///
    /// - Parameters:
    ///   - image: The image to render.
    ///   - format: The pixel format for the output image.
    ///   - colorSpace: The color space in which to render the output image. This color space must conform
    ///                 to either the CGColorSpaceModel.rgb or CGColorSpaceModel.monochrome model and must be compatible
    ///                 with the specified pixel format.
    ///   - options: No options keys are supported at this time.
    /// - Returns: A data representation of the rendered image in EXR format, or nil if the image could not be rendered.
    func exrRepresentation(of image: CIImage, format: CIFormat, colorSpace: CGColorSpace?, options: [CIImageRepresentationOption: Any] = [:]) -> Data? {
        guard !image.extent.isInfinite else {
            assertionFailure("The image's extent must be finite")
            return nil
        }
        guard let cgImage = self.createCGImage(image, from: image.extent, format: format, colorSpace: colorSpace) else {
            assertionFailure("Failed to render image")
            return nil
        }

        let data = NSMutableData()
        let destination = CGImageDestinationCreateWithData(data, "com.ilm.openexr-image" as CFString, 1, nil)!
        CGImageDestinationAddImage(destination, cgImage, image.properties as CFDictionary)
        CGImageDestinationFinalize(destination)

        return data as Data
    }

}