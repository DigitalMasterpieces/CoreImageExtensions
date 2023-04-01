#if DEBUG
import CoreImage


public extension CIImage.DebugProxy {

    /// Basic structure for collecting and displaying basic statistics of an image.
    struct ImageStatistics: CustomStringConvertible {
        /// The per-component minimum value among pixels.
        public let min: DebugPixel<Float32>
        /// The per-component maximum value among pixels.
        public let max: DebugPixel<Float32>
        /// The per-component average value among pixels.
        public let avg: DebugPixel<Float32>

        public var description: String {
            """
            min: \(self.min)
            max: \(self.max)
            avg: \(self.avg)
            """
        }

        init(min: Pixel<Float32>, max: Pixel<Float32>, avg: Pixel<Float32>) {
            self.min = DebugPixel(min)
            self.max = DebugPixel(max)
            self.avg = DebugPixel(avg)
        }
    }


    /// Calculates statistics (per-component minimum, maximum, average) of image pixels.
    /// - Parameters:
    ///   - rect: The area of the image from which to gather the statistics. Defaults to the whole image.
    ///   - colorSpace: The export color space used during rendering. If `nil`, the export color space of the context is used.
    /// - Returns: An `ImageStatistics` containing the statistical values.
    func statistics(in rect: CGRect? = nil, colorSpace: CGColorSpace? = nil) -> ImageStatistics {
        let rect = rect ?? self.image.extent
        guard !rect.isInfinite else {
            fatalError("Image extent is infinite. Image statistics can only be gathered in a finite area.")
        }

        // Generates a 2x1 px image with min and max values, respectively.
        let minMaxImage = self.image.applyingFilter("CIAreaMinMax", parameters: [kCIInputExtentKey: CIVector(cgRect: rect)])
        // Generates a single-pixel image with average values.
        let avgImage = self.image.applyingFilter("CIAreaAverage", parameters: [kCIInputExtentKey: CIVector(cgRect: rect)])
        // Extract values and return as `ImageStatistics`.
        return ImageStatistics(min: self.context.readFloat32PixelValue(from: minMaxImage, at: CGPoint(x: 0, y: 0), colorSpace: colorSpace),
                               max: self.context.readFloat32PixelValue(from: minMaxImage, at: CGPoint(x: 1, y: 0), colorSpace: colorSpace),
                               avg: self.context.readFloat32PixelValue(from: avgImage,    at: CGPoint(x: 0, y: 0), colorSpace: colorSpace))
    }

}

#endif
