import CoreImage


extension CIContext {

    // MARK: - UInt8

    /// Reads the RGBA-channel pixel values in UInt8 format from the given `image` in the given `rect` and returns them as an array.
    /// - Parameters:
    ///   - image: The image to read the pixel values from.
    ///   - rect: The region that should be read. Must be finite and intersect with the extent of `image`.
    ///   - colorSpace: The export color space used during rendering. If `nil`, the export color space of the context is used.
    /// - Returns: An array containing the UInt8 pixel values.
    public func readRGBA8PixelValues(from image: CIImage, in rect: CGRect, colorSpace: CGColorSpace? = nil) -> [Pixel4<UInt8>] {
        return self.readPixelValues(from: image, in: rect, format: .RGBA8, colorSpace: colorSpace, defaultValue: Pixel4<UInt8>(repeating: 0))
    }

    /// Reads the RG-channel pixel values in UInt8 format from the given `image` in the given `rect` and returns them as an array.
    /// - Parameters:
    ///   - image: The image to read the pixel values from.
    ///   - rect: The region that should be read. Must be finite and intersect with the extent of `image`.
    ///   - colorSpace: The export color space used during rendering. If `nil`, the export color space of the context is used.
    /// - Returns: An array containing the UInt8 pixel values.
    public func readRG8PixelValues(from image: CIImage, in rect: CGRect, colorSpace: CGColorSpace? = nil) -> [Pixel2<UInt8>] {
        return self.readPixelValues(from: image, in: rect, format: .RG8, colorSpace: colorSpace, defaultValue: Pixel2<UInt8>(repeating: 0))
    }

    /// Reads the single R-channel pixel values in UInt8 format from the given `image` in the given `rect` and returns them as an array.
    /// - Parameters:
    ///   - image: The image to read the pixel values from.
    ///   - rect: The region that should be read. Must be finite and intersect with the extent of `image`.
    ///   - colorSpace: The export color space used during rendering. If `nil`, the export color space of the context is used.
    /// - Returns: An array containing the UInt8 pixel values.
    public func readR8PixelValues(from image: CIImage, in rect: CGRect, colorSpace: CGColorSpace? = nil) -> [UInt8] {
        return self.readPixelValues(from: image, in: rect, format: .R8, colorSpace: colorSpace, defaultValue: UInt8(0))
    }

    /// Reads the RGBA-channel pixel value in UInt8 format from the given `image` at the given `point`.
    /// - Parameters:
    ///   - image: The image to read the pixel values from.
    ///   - point: The point in image space from which to read the pixel value. Must be within the extent of `image`.
    ///   - colorSpace: The export color space used during rendering. If `nil`, the export color space of the context is used.
    /// - Returns: The UInt8 pixel value.
    public func readRGBA8PixelValue(from image: CIImage, at point: CGPoint, colorSpace: CGColorSpace? = nil) -> Pixel4<UInt8> {
        let defaultValue = Pixel4<UInt8>(repeating: 0)
        let rect = CGRect(origin: point, size: CGSize(width: 1, height: 1))
        let values = self.readRGBA8PixelValues(from: image, in: rect, colorSpace: colorSpace)
        return values.first ?? defaultValue
    }

    /// Reads the RG-channel pixel value in UInt8 format from the given `image` at the given `point`.
    /// - Parameters:
    ///   - image: The image to read the pixel values from.
    ///   - point: The point in image space from which to read the pixel value. Must be within the extent of `image`.
    ///   - colorSpace: The export color space used during rendering. If `nil`, the export color space of the context is used.
    /// - Returns: The UInt8 pixel value.
    public func readRG8PixelValue(from image: CIImage, at point: CGPoint, colorSpace: CGColorSpace? = nil) -> Pixel2<UInt8> {
        let defaultValue = Pixel2<UInt8>(repeating: 0)
        let rect = CGRect(origin: point, size: CGSize(width: 1, height: 1))
        let values = self.readRG8PixelValues(from: image, in: rect, colorSpace: colorSpace)
        return values.first ?? defaultValue
    }

    /// Reads the single R-channel pixel value in UInt8 format from the given `image` at the given `point`.
    /// - Parameters:
    ///   - image: The image to read the pixel values from.
    ///   - point: The point in image space from which to read the pixel value. Must be within the extent of `image`.
    ///   - colorSpace: The export color space used during rendering. If `nil`, the export color space of the context is used.
    /// - Returns: The UInt8 pixel value.
    public func readR8PixelValue(from image: CIImage, at point: CGPoint, colorSpace: CGColorSpace? = nil) -> UInt8 {
        let defaultValue = UInt8(0)
        let rect = CGRect(origin: point, size: CGSize(width: 1, height: 1))
        let values = self.readR8PixelValues(from: image, in: rect, colorSpace: colorSpace)
        return values.first ?? defaultValue
    }


    // MARK: - Float32

    /// Reads the RGBA-channel pixel values in Float32 format from the given `image` in the given `rect` and returns them as an array.
    /// - Parameters:
    ///   - image: The image to read the pixel values from.
    ///   - rect: The region that should be read. Must be finite and intersect with the extent of `image`.
    ///   - colorSpace: The export color space used during rendering. If `nil`, the export color space of the context is used.
    /// - Returns: An array containing the Float32 pixel values.
    public func readRGBAfPixelValues(from image: CIImage, in rect: CGRect, colorSpace: CGColorSpace? = nil) -> [Pixel4<Float32>] {
        return self.readPixelValues(from: image, in: rect, format: .RGBAf, colorSpace: colorSpace, defaultValue: Pixel4<Float32>(repeating: .nan))
    }

    /// Reads the RG-channel pixel values in Float32 format from the given `image` in the given `rect` and returns them as an array.
    /// - Parameters:
    ///   - image: The image to read the pixel values from.
    ///   - rect: The region that should be read. Must be finite and intersect with the extent of `image`.
    ///   - colorSpace: The export color space used during rendering. If `nil`, the export color space of the context is used.
    /// - Returns: An array containing the Float32 pixel values.
    public func readRGfPixelValues(from image: CIImage, in rect: CGRect, colorSpace: CGColorSpace? = nil) -> [Pixel2<Float32>] {
        return self.readPixelValues(from: image, in: rect, format: .RGf, colorSpace: colorSpace, defaultValue: Pixel2<Float32>(repeating: .nan))
    }

    /// Reads the single R-channel pixel values in Float32 format from the given `image` in the given `rect` and returns them as an array.
    /// - Parameters:
    ///   - image: The image to read the pixel values from.
    ///   - rect: The region that should be read. Must be finite and intersect with the extent of `image`.
    ///   - colorSpace: The export color space used during rendering. If `nil`, the export color space of the context is used.
    /// - Returns: An array containing the Float32 pixel values.
    public func readRfPixelValues(from image: CIImage, in rect: CGRect, colorSpace: CGColorSpace? = nil) -> [Float32] {
        return self.readPixelValues(from: image, in: rect, format: .Rf, colorSpace: colorSpace, defaultValue: Float32.nan)
    }

    /// Reads the RGBA-channel pixel value in Float32 format from the given `image` at the given `point`.
    /// - Parameters:
    ///   - image: The image to read the pixel values from.
    ///   - point: The point in image space from which to read the pixel value. Must be within the extent of `image`.
    ///   - colorSpace: The export color space used during rendering. If `nil`, the export color space of the context is used.
    /// - Returns: The Float32 pixel value.
    public func readRGBAfPixelValue(from image: CIImage, at point: CGPoint, colorSpace: CGColorSpace? = nil) -> Pixel4<Float32> {
        let defaultValue = Pixel4<Float32>(repeating: .nan)
        let rect = CGRect(origin: point, size: CGSize(width: 1, height: 1))
        let values = self.readRGBAfPixelValues(from: image, in: rect, colorSpace: colorSpace)
        return values.first ?? defaultValue
    }

    /// Reads the RG-channel pixel value in Float32 format from the given `image` at the given `point`.
    /// - Parameters:
    ///   - image: The image to read the pixel values from.
    ///   - point: The point in image space from which to read the pixel value. Must be within the extent of `image`.
    ///   - colorSpace: The export color space used during rendering. If `nil`, the export color space of the context is used.
    /// - Returns: The Float32 pixel value.
    public func readRGfPixelValue(from image: CIImage, at point: CGPoint, colorSpace: CGColorSpace? = nil) -> Pixel2<Float32> {
        let defaultValue = Pixel2<Float32>(repeating: .nan)
        let rect = CGRect(origin: point, size: CGSize(width: 1, height: 1))
        let values = self.readRGfPixelValues(from: image, in: rect, colorSpace: colorSpace)
        return values.first ?? defaultValue
    }

    /// Reads the single R-channel pixel value in Float32 format from the given `image` at the given `point`.
    /// - Parameters:
    ///   - image: The image to read the pixel values from.
    ///   - point: The point in image space from which to read the pixel value. Must be within the extent of `image`.
    ///   - colorSpace: The export color space used during rendering. If `nil`, the export color space of the context is used.
    /// - Returns: The Float32 pixel value.
    public func readRfPixelValue(from image: CIImage, at point: CGPoint, colorSpace: CGColorSpace? = nil) -> Float32 {
        let defaultValue = Float32.nan
        let rect = CGRect(origin: point, size: CGSize(width: 1, height: 1))
        let values = self.readRfPixelValues(from: image, in: rect, colorSpace: colorSpace)
        return values.first ?? defaultValue
    }


    // MARK: - Internal

    private func readPixelValues<PixelType>(from image: CIImage, in rect: CGRect, format: CIFormat, colorSpace: CGColorSpace?, defaultValue: PixelType) -> [PixelType] {
        assert(!rect.isInfinite, "Rect must not be infinite")
        assert(image.extent.contains(rect), "The give rect must intersect with the image's extent")

        var values = Array(repeating: defaultValue, count: Int(rect.width * rect.height))
        // Make sure `rowBytes` is aligned to a 16-byte boundary (rounded up to a multiple of 16).
        // It seems (learned from error messages), that 8-bit formats require a 4-byte alignment and
        // 16-bit formats require 8-byte alignment, and according to "Quartz 2D Graphics for Mac OS X Developers",
        // a 16-byte alignment is best for performance. So we simply choose 16 here to cover all cases.
        // (See https://flylib.com/books/en/3.310.1.63/1/)
        let rowBytes = ((MemoryLayout<PixelType>.size * Int(rect.width) + 15) / 16) * 16
        self.render(image, toBitmap: &values, rowBytes: rowBytes, bounds: rect, format: format, colorSpace: colorSpace)
        return values
    }

}
