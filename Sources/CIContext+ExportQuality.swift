import CoreImage


public extension CIContext {

    /// Same as ``.heifRepresentation(of:format:colorSpace:options:)``, but the `quality` is a parameter here and doesn't need to be set via `options`. ``CIContext``
    /// The `quality` needs to be between `0.0` (worst) and `1.0` (best).
    func heifRepresentation(of image: CIImage, format: CIFormat, colorSpace: CGColorSpace, quality: Float, options: [CIImageRepresentationOption: Any] = [:]) -> Data? {
        return self.heifRepresentation(of: image, format: format, colorSpace: colorSpace, options: options.withQuality(quality))
    }

    /// Same as ``writeHEIFRepresentation(of:to:format:colorSpace:options:)``, but the `quality` is a parameter here and doesn't need to be set via `options`.
    /// The `quality` needs to be between `0.0` (worst) and `1.0` (best).
    func writeHEIFRepresentation(of image: CIImage, to url: URL, format: CIFormat, colorSpace: CGColorSpace, quality: Float, options: [CIImageRepresentationOption: Any] = [:]) throws {
        try self.writeHEIFRepresentation(of: image, to: url, format: format, colorSpace: colorSpace, options: options.withQuality(quality))
    }

    /// Same as ``heif10Representation(of:colorSpace:options:)``, but the `quality` is a parameter here and doesn't need to be set via `options`.
    /// The `quality` needs to be between `0.0` (worst) and `1.0` (best).
    @available(iOS 15.0, macOS 12.0, macCatalyst 15.0, *)
    func heif10Representation(of image: CIImage, colorSpace: CGColorSpace, quality: Float, options: [CIImageRepresentationOption: Any] = [:]) throws -> Data? {
        return try self.heif10Representation(of: image, colorSpace: colorSpace, options: options.withQuality(quality))
    }

    /// Same as ``writeHEIF10Representation(of:to:colorSpace:options:)``, but the `quality` is a parameter here and doesn't need to be set via `options`.
    /// The `quality` needs to be between `0.0` (worst) and `1.0` (best).
    @available(iOS 15.0, macOS 12.0, macCatalyst 15.0, *)
    func writeHEIF10Representation(of image: CIImage, to url: URL, colorSpace: CGColorSpace, quality: Float, options: [CIImageRepresentationOption: Any] = [:]) throws {
        try self.writeHEIF10Representation(of: image, to: url, colorSpace: colorSpace, options: options.withQuality(quality))
    }

    /// Same as ``jpegRepresentation(of:colorSpace:options:)``, but the `quality` is a parameter here and doesn't need to be set via `options`.
    /// The `quality` needs to be between `0.0` (worst) and `1.0` (best).
    func jpegRepresentation(of image: CIImage, colorSpace: CGColorSpace, quality: Float, options: [CIImageRepresentationOption: Any] = [:]) -> Data? {
        return self.jpegRepresentation(of: image, colorSpace: colorSpace, options: options.withQuality(quality))
    }

    /// Same as ``writeJPEGRepresentation(of:to:colorSpace:options:)``, but the `quality` is a parameter here and doesn't need to be set via `options`.
    /// The `quality` needs to be between `0.0` (worst) and `1.0` (best).
    func writeJPEGRepresentation(of image: CIImage, to url: URL, colorSpace: CGColorSpace, quality: Float, options: [CIImageRepresentationOption: Any] = [:]) throws {
        try self.writeJPEGRepresentation(of: image, to: url, colorSpace: colorSpace, options: options.withQuality(quality))
    }

}

public extension CIContext.Actor {

    /// Async version of ``.heifRepresentation(of:format:colorSpace:options:)``, but the `quality` is a parameter here and doesn't need to be set via `options`. ``CIContext``
    /// The `quality` needs to be between `0.0` (worst) and `1.0` (best).
    func heifRepresentation(of image: CIImage, format: CIFormat, colorSpace: CGColorSpace, quality: Float, options: [CIImageRepresentationOption: Any] = [:]) -> Data? {
        return self.context.heifRepresentation(of: image, format: format, colorSpace: colorSpace, quality: quality, options: options)
    }

    /// Async version of ``writeHEIFRepresentation(of:to:format:colorSpace:options:)``, but the `quality` is a parameter here and doesn't need to be set via `options`.
    /// The `quality` needs to be between `0.0` (worst) and `1.0` (best).
    func writeHEIFRepresentation(of image: CIImage, to url: URL, format: CIFormat, colorSpace: CGColorSpace, quality: Float, options: [CIImageRepresentationOption: Any] = [:]) throws {
        try self.context.writeHEIFRepresentation(of: image, to: url, format: format, colorSpace: colorSpace, quality: quality, options: options)
    }

    /// Async version of ``heif10Representation(of:colorSpace:options:)``, but the `quality` is a parameter here and doesn't need to be set via `options`.
    /// The `quality` needs to be between `0.0` (worst) and `1.0` (best).
    @available(iOS 15.0, macOS 12.0, macCatalyst 15.0, *)
    func heif10Representation(of image: CIImage, colorSpace: CGColorSpace, quality: Float, options: [CIImageRepresentationOption: Any] = [:]) throws -> Data? {
        return try self.context.heif10Representation(of: image, colorSpace: colorSpace, quality: quality, options: options)
    }

    /// Async version of ``writeHEIF10Representation(of:to:colorSpace:options:)``, but the `quality` is a parameter here and doesn't need to be set via `options`.
    /// The `quality` needs to be between `0.0` (worst) and `1.0` (best).
    @available(iOS 15.0, macOS 12.0, macCatalyst 15.0, *)
    func writeHEIF10Representation(of image: CIImage, to url: URL, colorSpace: CGColorSpace, quality: Float, options: [CIImageRepresentationOption: Any] = [:]) throws {
        try self.context.writeHEIF10Representation(of: image, to: url, colorSpace: colorSpace, quality: quality, options: options)
    }

    /// Async version of ``jpegRepresentation(of:colorSpace:options:)``, but the `quality` is a parameter here and doesn't need to be set via `options`.
    /// The `quality` needs to be between `0.0` (worst) and `1.0` (best).
    func jpegRepresentationWithMattes(of image: CIImage, colorSpace: CGColorSpace, quality: Float, options: [CIImageRepresentationOption: Any] = [:]) -> Data? {
        return self.context.jpegRepresentation(of: image, colorSpace: colorSpace, quality: quality, options: options)
    }

    /// Async version of ``writeJPEGRepresentation(of:to:colorSpace:options:)``, but the `quality` is a parameter here and doesn't need to be set via `options`.
    /// The `quality` needs to be between `0.0` (worst) and `1.0` (best).
    func writeJPEGRepresentation(of image: CIImage, to url: URL, colorSpace: CGColorSpace, quality: Float, options: [CIImageRepresentationOption: Any] = [:]) throws {
        try self.context.writeJPEGRepresentation(of: image, to: url, colorSpace: colorSpace, quality: quality, options: options)
    }

}


private extension Dictionary where Key == CIImageRepresentationOption, Value == Any {

    func withQuality(_ quality: Float) -> Self {
        var copy = self
        copy[CIImageRepresentationOption(rawValue: kCGImageDestinationLossyCompressionQuality as String)] = quality
        return copy
    }

}
