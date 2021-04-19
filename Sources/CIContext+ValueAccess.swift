import CoreImage


extension CIContext {

    // MARK: - UInt8

    /// Reads the RGBA-channel pixel values in UInt8 format from the given `image` in the given `rect` and returns them as an array.
    /// - Parameters:
    ///   - image: The image to read the pixel values from.
    ///   - rect: The region that should be read. Must be finite and intersect with the extent of `image`.
    ///   - colorSpace: The export color space used during rendering. If `nil`, the export color space of the context is used.
    /// - Returns: An array containing the UInt8 pixel values.
    public func readUInt8PixelValues(from image: CIImage, in rect: CGRect, colorSpace: CGColorSpace? = nil) -> [Pixel<UInt8>] {
        return self.readPixelValues(from: image, in: rect, format: .RGBA8, colorSpace: colorSpace, defaultValue: Pixel<UInt8>(repeating: 0))
    }

    /// Reads the RGBA-channel pixel value in UInt8 format from the given `image` at the given `point`.
    /// - Parameters:
    ///   - image: The image to read the pixel values from.
    ///   - point: The point in image space from which to read the pixel value. Must be within the extent of `image`.
    ///   - colorSpace: The export color space used during rendering. If `nil`, the export color space of the context is used.
    /// - Returns: The UInt8 pixel value.
    public func readUInt8PixelValue(from image: CIImage, at point: CGPoint, colorSpace: CGColorSpace? = nil) -> Pixel<UInt8> {
        let defaultValue = Pixel<UInt8>(repeating: 0)
        let rect = CGRect(origin: point, size: CGSize(width: 1, height: 1))
        let values = self.readUInt8PixelValues(from: image, in: rect, colorSpace: colorSpace)
        return values.first ?? defaultValue
    }


    // MARK: - Float32

    /// Reads the RGBA-channel pixel values in Float32 format from the given `image` in the given `rect` and returns them as an array.
    /// - Parameters:
    ///   - image: The image to read the pixel values from.
    ///   - rect: The region that should be read. Must be finite and intersect with the extent of `image`.
    ///   - colorSpace: The export color space used during rendering. If `nil`, the export color space of the context is used.
    /// - Returns: An array containing the Float32 pixel values.
    public func readFloat32PixelValues(from image: CIImage, in rect: CGRect, colorSpace: CGColorSpace? = nil) -> [Pixel<Float32>] {
        return self.readPixelValues(from: image, in: rect, format: .RGBAf, colorSpace: colorSpace, defaultValue: Pixel<Float32>(repeating: .nan))
    }

    /// Reads the RGBA-channel pixel value in Float32 format from the given `image` at the given `point`.
    /// - Parameters:
    ///   - image: The image to read the pixel values from.
    ///   - point: The point in image space from which to read the pixel value. Must be within the extent of `image`.
    ///   - colorSpace: The export color space used during rendering. If `nil`, the export color space of the context is used.
    /// - Returns: The Float32 pixel value.
    public func readFloat32PixelValue(from image: CIImage, at point: CGPoint, colorSpace: CGColorSpace? = nil) -> Pixel<Float32> {
        let defaultValue = Pixel<Float32>(repeating: .nan)
        let rect = CGRect(origin: point, size: CGSize(width: 1, height: 1))
        let values = self.readFloat32PixelValues(from: image, in: rect, colorSpace: colorSpace)
        return values.first ?? defaultValue
    }


    // MARK: - Float16

    /// Reads the RGBA-channel pixel values in Float16 format from the given `image` in the given `rect` and returns them as an array.
    /// - Parameters:
    ///   - image: The image to read the pixel values from.
    ///   - rect: The region that should be read. Must be finite and intersect with the extent of `image`.
    ///   - colorSpace: The export color space used during rendering. If `nil`, the export color space of the context is used.
    /// - Returns: An array containing the Float16 pixel values.
    @available(iOS 14, tvOS 14, *)
    @available(macOS, unavailable)
    @available(macCatalyst, unavailable)
    public func readFloat16PixelValues(from image: CIImage, in rect: CGRect, colorSpace: CGColorSpace? = nil) -> [Pixel<Float16>] {
        return self.readPixelValues(from: image, in: rect, format: .RGBAh, colorSpace: colorSpace, defaultValue: Pixel<Float16>(repeating: .nan))
    }

    /// Reads the RGBA-channel pixel value in Float16 format from the given `image` at the given `point`.
    /// - Parameters:
    ///   - image: The image to read the pixel values from.
    ///   - point: The point in image space from which to read the pixel value. Must be within the extent of `image`.
    ///   - colorSpace: The export color space used during rendering. If `nil`, the export color space of the context is used.
    /// - Returns: The Float16 pixel value.
    @available(iOS 14, tvOS 14, *)
    @available(macOS, unavailable)
    @available(macCatalyst, unavailable)
    public func readFloat16PixelValue(from image: CIImage, at point: CGPoint, colorSpace: CGColorSpace? = nil) -> Pixel<Float16> {
        let defaultValue = Pixel<Float16>(repeating: .nan)
        let rect = CGRect(origin: point, size: CGSize(width: 1, height: 1))
        let values = self.readFloat16PixelValues(from: image, in: rect, colorSpace: colorSpace)
        return values.first ?? defaultValue
    }


    // MARK: - Internal

    private func readPixelValues<PixelType>(from image: CIImage, in rect: CGRect, format: CIFormat, colorSpace: CGColorSpace?, defaultValue: PixelType) -> [PixelType] {
        assert(!rect.isInfinite, "Rect must not be infinite")
        assert(image.extent.contains(rect), "The give rect must intersect with the image's extent")
        // ⚠️ We only support reading 4-channel pixels right now due to alignment requirements of CIContext's `render` API.
        assert([.RGBA8, .RGBAh, .RGBAf].contains(format), "Only 4-channel formats are supported right now")

        var values = Array(repeating: defaultValue, count: Int(rect.width * rect.height))
        let rowBytes = MemoryLayout<PixelType>.size * Int(rect.width)
        self.render(image, toBitmap: &values, rowBytes: rowBytes, bounds: rect, format: format, colorSpace: colorSpace)
        return values
    }

}
