import CoreImage


/// Some useful extensions for performing common transformations on an image.
public extension CIImage {

    /// Returns a new image that represents the original image after scaling it by the given factors in x- and y-direction.
    ///
    /// The interpolation used for the sampling technique used by the image.
    /// This can be changed by calling `samplingLinear()` or `samplingNearest()` on the image
    /// before calling this method.
    /// Defaults to (bi)linear scaling.
    ///
    /// - Parameters:
    ///   - x: The scale factor in x-direction.
    ///   - y: The scale factor in y-direction.
    /// - Returns: A scaled image.
    func scaledBy(x: CGFloat, y: CGFloat) -> CIImage {
        return self.transformed(by: CGAffineTransform(scaleX: x, y: y))
    }

    /// Returns a new image that represents the original image after translating within the working space
    /// by the given amount in x- and y-direction.
    /// - Parameters:
    ///   - dx: The amount to move the image in x-direction.
    ///   - dy: The amount to move the image in y-direction.
    /// - Returns: A moved/translated image.
    func translatedBy(dx: CGFloat, dy: CGFloat) -> CIImage {
        return self.transformed(by: CGAffineTransform(translationX: dx, y: dy))
    }

    /// Returns a new image that represents the original image after moving its origin within the working space to the given point.
    /// - Parameter origin: The new origin point of the image.
    /// - Returns: A moved image with the new origin.
    func moved(to origin: CGPoint) -> CIImage {
        return self.translatedBy(dx: origin.x - self.extent.origin.x, dy: origin.y - self.extent.origin.y)
    }

    /// Returns a new image that represents the original image after adding a padding of clear pixels around it,
    /// effectively increasing its virtual extent.
    /// - Parameters:
    ///   - dx: The amount of padding to add to the left and right.
    ///   - dy: The amount of padding to add at the top and bottom.
    /// - Returns: A padded image.
    func paddedBy(dx: CGFloat, dy: CGFloat) -> CIImage {
        let background = CIImage(color: .clear).cropped(to: self.extent.insetBy(dx: -dx, dy: -dy))
        return self.composited(over: background)
    }

}
