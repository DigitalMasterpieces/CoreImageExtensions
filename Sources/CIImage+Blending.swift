import CoreImage


/// Some convenience methods for compositing/blending and colorizing images.
extension CIImage {

    /// Returns a new image created by compositing the original image over the specified background image
    /// using the given blend kernel.
    ///
    /// The `extent` of the result image will be determined by `extent` of the receiver,
    /// the `extent` of the `background` images, and the `blendKernel` used. For most of the
    /// built-in blend kernels (as well as custom blend kernels) the result image's
    /// `extent` will be the union of the receiver's and background image's extents.
    ///
    /// - Parameters:
    ///   - background: An image to serve as the background of the compositing operation.
    ///   - blendKernel: The `CIBlendKernel` to use for blending the image with the `background`.
    /// - Returns: An image object representing the result of the compositing operation.
    public func composited(over background: CIImage, using blendKernel: CIBlendKernel) -> CIImage? {
        return blendKernel.apply(foreground: self, background: background)
    }

    /// Returns a new image created by compositing the original image over the specified background image
    /// using the given blend kernel in the specified colorspace.
    ///
    /// The `extent` of the result image will be determined by `extent` of the receiver,
    /// the `extent` of the `background` images, and the `blendKernel` used. For most of the
    /// built-in blend kernels (as well as custom blend kernels) the result image's
    /// `extent` will be the union of the receiver's and background image's extents.
    ///
    /// - Parameters:
    ///   - background: An image to serve as the background of the compositing operation.
    ///   - blendKernel: The `CIBlendKernel` to use for blending the image with the `background`.
    ///   - colorSpace: The `CGColorSpace` to perform the blend operation in.
    /// - Returns: An image object representing the result of the compositing operation.
    public func composited(over background: CIImage, using blendKernel: CIBlendKernel, colorSpace: CGColorSpace) -> CIImage? {
        return blendKernel.apply(foreground: self, background: background, colorSpace: colorSpace)
    }

    /// Colorizes the image in the given color, i.e., all non-transparent pixels in the receiver will be set to `color`.
    ///
    /// - Parameter color: The color to override visible pixels of the receiver with.
    /// - Returns: The colorized image.
    public func colorized(with color: CIColor) -> CIImage? {
        if #available(iOS 11.0, macCatalyst 13.1, macOS 10.13, tvOS 11.0, *) {
            return CIBlendKernel.sourceAtop.apply(foreground: CIImage(color: color).cropped(to: self.extent), background: self)
        } else {
            return CIImage(color: color).cropped(to: self.extent).applyingFilter("CISourceAtopCompositing", parameters: [kCIInputBackgroundImageKey: self])
        }
    }

}
