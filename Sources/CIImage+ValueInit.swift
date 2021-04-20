import CoreImage


public extension CIImage {

    /// Returns a `CIImage` with infinite extent only containing the given pixel value.
    /// This is similar to using `init(color:)`, but allows to pass channel values outside
    /// the normal [0..1] range.
    static func containing(values: CIVector) -> CIImage? {
        // use a CIColorMatrix with a clear input image to set the desired
        // pixel value via the biasVector, since the biasVector is not clamped to [0..1]
        guard let colorMatrixFilter = CIFilter(name: "CIColorMatrix") else {
            assertionFailure("Failed to find CIColorMatrix in the system")
            return nil
        }
        colorMatrixFilter.setValue(CIImage(color: CIColor(red: 0, green: 0, blue: 0, alpha: 0)), forKey: kCIInputImageKey)
        colorMatrixFilter.setValue(values, forKey: "inputBiasVector")
        guard let output = colorMatrixFilter.outputImage else {
            assertionFailure("Failed to create image containing values \(values)")
            return nil
        }
        return output
    }

    /// Returns a `CIImage` with infinite extent only containing the given value in RGB and alpha 1.
    /// So `CIImage.containing(42.3)` would result in an image containing the value (42.3, 42.3, 42.3, 1.0) in each pixel.
    static func containing(value: Double) -> CIImage? {
        return CIImage.containing(values: CIVector(x: CGFloat(value), y: CGFloat(value), z: CGFloat(value), w: 1.0))
    }

}
