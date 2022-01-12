import CoreImage


private var ASSOCIATED_ACTOR_KEY = "CoreImageExtensions.CIContext.async"


@available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, *)
public extension CIContext {

    /// An actor for synchronizing calls to a `CIContext` and executing them in the background.
    /// The `Actor` instance associated with a context can be accessed via ``CIContext/async``.
    actor Actor {

        /// The "wrapped" context instance.
        private weak var context: CIContext!


        // MARK: - Lifecycle

        /// Creates a new instance.
        /// - Parameter ciContext: The `CIContext` to forward all rendering calls to.
        fileprivate init(_ ciContext: CIContext) {
            self.context = ciContext
        }


        // MARK: - Drawing

        /// Async version of the `CIContext` method with the same signature.
        public func draw(_ image: CIImage, in inRect: CGRect, from fromRect: CGRect) {
            self.context.draw(image, in: inRect, from: fromRect)
        }


        // MARK: - Direct Render

        /// Async version of the `CIContext` method with the same signature.
        public func render(_ image: CIImage, toBitmap data: UnsafeMutableRawPointer, rowBytes: Int, bounds: CGRect, format: CIFormat, colorSpace: CGColorSpace?) {
            self.context.render(image, toBitmap: data, rowBytes: rowBytes, bounds: bounds, format: format, colorSpace: colorSpace)
        }

        /// Async version of the `CIContext` method with the same signature.
        public func render(_ image: CIImage, to surface: IOSurfaceRef, bounds: CGRect, colorSpace: CGColorSpace?) {
            self.context.render(image, to: surface, bounds: bounds, colorSpace: colorSpace)
        }

        /// Async version of the `CIContext` method with the same signature.
        public func render(_ image: CIImage, to buffer: CVPixelBuffer) {
            self.context.render(image, to: buffer)
        }

        /// Async version of the `CIContext` method with the same signature.
        public func render(_ image: CIImage, to buffer: CVPixelBuffer, bounds: CGRect, colorSpace: CGColorSpace?) {
            self.context.render(image, to: buffer, bounds: bounds, colorSpace: colorSpace)
        }

        /// Async version of the `CIContext` method with the same signature.
        public func render(_ image: CIImage, to texture: MTLTexture, commandBuffer: MTLCommandBuffer?, bounds: CGRect, colorSpace: CGColorSpace) {
            self.context.render(image, to: texture, commandBuffer: commandBuffer, bounds: bounds, colorSpace: colorSpace)
        }


        // MARK: - CGImage Creation

        /// Async version of the `CIContext` method with the same signature.
        public func createCGImage(_ image: CIImage, from fromRect: CGRect) -> CGImage? {
            return self.context.createCGImage(image, from: fromRect)
        }

        /// Async version of the `CIContext` method with the same signature.
        public func createCGImage(_ image: CIImage, from fromRect: CGRect, format: CIFormat, colorSpace: CGColorSpace?) -> CGImage? {
            return self.context.createCGImage(image, from: fromRect, format: format, colorSpace: colorSpace)
        }

        /// Async version of the `CIContext` method with the same signature.
        public func createCGImage(_ image: CIImage, from fromRect: CGRect, format: CIFormat, colorSpace: CGColorSpace?, deferred: Bool) -> CGImage? {
            return self.context.createCGImage(image, from: fromRect, format: format, colorSpace: colorSpace, deferred: deferred)
        }


        // MARK: - Creating Data Representations

        /// Async version of the `CIContext` method with the same signature.
        public func tiffRepresentation(of image: CIImage, format: CIFormat, colorSpace: CGColorSpace, options: [CIImageRepresentationOption: Any] = [:]) -> Data? {
            return self.context.tiffRepresentation(of: image, format: format, colorSpace: colorSpace, options: options)
        }

        /// Async version of the `CIContext` method with the same signature.
        public func jpegRepresentation(of image: CIImage, colorSpace: CGColorSpace, options: [CIImageRepresentationOption: Any] = [:]) -> Data? {
            return self.context.jpegRepresentation(of: image, colorSpace: colorSpace, options: options)
        }

        /// Async version of the `CIContext` method with the same signature.
        public func heifRepresentation(of image: CIImage, format: CIFormat, colorSpace: CGColorSpace, options: [CIImageRepresentationOption: Any] = [:]) -> Data? {
            return self.context.heifRepresentation(of: image, format: format, colorSpace: colorSpace, options: options)
        }

        /// Async version of the `CIContext` method with the same signature.
        @available(iOS 15.0, macOS 12.0, macCatalyst 15.0, tvOS 15.0, *)
        public func heif10Representation(of image: CIImage, colorSpace: CGColorSpace, options: [CIImageRepresentationOption: Any] = [:]) throws -> Data {
            return try self.context.heif10Representation(of: image, colorSpace: colorSpace, options: options)
        }

        /// Async version of the `CIContext` method with the same signature.
        public func pngRepresentation(of image: CIImage, format: CIFormat, colorSpace: CGColorSpace, options: [CIImageRepresentationOption: Any] = [:]) -> Data? {
            return self.context.pngRepresentation(of: image, format: format, colorSpace: colorSpace, options: options)
        }

        /// Async version of the `CIContext` method with the same signature.
        public func writeTIFFRepresentation(of image: CIImage, to url: URL, format: CIFormat, colorSpace: CGColorSpace, options: [CIImageRepresentationOption: Any] = [:]) throws {
            try self.context.writeTIFFRepresentation(of: image, to: url, format: format, colorSpace: colorSpace, options: options)
        }

        /// Async version of the `CIContext` method with the same signature.
        public func writePNGRepresentation(of image: CIImage, to url: URL, format: CIFormat, colorSpace: CGColorSpace, options: [CIImageRepresentationOption: Any] = [:]) throws {
            try self.context.writePNGRepresentation(of: image, to: url, format: format, colorSpace: colorSpace, options: options)
        }

        /// Async version of the `CIContext` method with the same signature.
        public func writeJPEGRepresentation(of image: CIImage, to url: URL, colorSpace: CGColorSpace, options: [CIImageRepresentationOption: Any] = [:]) throws {
            try self.context.writeJPEGRepresentation(of: image, to: url, colorSpace: colorSpace, options: options)
        }

        /// Async version of the `CIContext` method with the same signature.
        public func writeHEIFRepresentation(of image: CIImage, to url: URL, format: CIFormat, colorSpace: CGColorSpace, options: [CIImageRepresentationOption: Any] = [:]) throws {
            try self.context.writeHEIFRepresentation(of: image, to: url, format: format, colorSpace: colorSpace, options: options)
        }

        /// Async version of the `CIContext` method with the same signature.
        @available(iOS 15.0, macOS 12.0, macCatalyst 15.0, tvOS 15.0, *)
        public func writeHEIF10Representation(of image: CIImage, to url: URL, colorSpace: CGColorSpace, options: [CIImageRepresentationOption: Any] = [:]) throws {
            try self.context.writeHEIF10Representation(of: image, to: url, colorSpace: colorSpace, options: options)
        }


        // MARK: Destination APIs

        /// Async version of the `CIContext` method with the same signature.
        @discardableResult
        public func startTask(toRender image: CIImage, from fromRect: CGRect, to destination: CIRenderDestination, at atPoint: CGPoint) throws -> CIRenderTask {
            return try self.context.startTask(toRender: image, from: fromRect, to: destination, at: atPoint)
        }

        /// Async version of the `CIContext` method with the same signature.
        @discardableResult
        public func startTask(toRender image: CIImage, to destination: CIRenderDestination) throws -> CIRenderTask {
            return try self.context.startTask(toRender: image, to: destination)
        }

        /// Async version of the `CIContext` method with the same signature.
        public func prepareRender(_ image: CIImage, from fromRect: CGRect, to destination: CIRenderDestination, at atPoint: CGPoint) throws {
            try self.context.prepareRender(image, from: fromRect, to: destination, at: atPoint)
        }

        /// Async version of the `CIContext` method with the same signature.
        @discardableResult
        public func startTask(toClear destination: CIRenderDestination) throws -> CIRenderTask {
            return try self.context.startTask(toClear: destination)
        }

        /// Analogue to ``startTask(toRender:from:to:at:)``, but this one will wait for the task to finish execution and return the resulting `CIRenderInfo` object.
        @discardableResult
        public func render(_ image: CIImage, from fromRect: CGRect, to destination: CIRenderDestination, at atPoint: CGPoint) throws -> CIRenderInfo {
            let task = try self.startTask(toRender: image, from: fromRect, to: destination, at: atPoint)
            return try task.waitUntilCompleted()
        }

        /// Analogue to ``startTask(toRender:to:)``, but this one will wait for the task to finish execution and return the resulting `CIRenderInfo` object.
        @discardableResult
        public func render(_ image: CIImage, to destination: CIRenderDestination) async throws -> CIRenderInfo {
            let task = try self.startTask(toRender: image, to: destination)
            return try task.waitUntilCompleted()
        }

        /// Analogue to ``startTask(toClear:)``, but this one will wait for the task to finish execution and return the resulting `CIRenderInfo` object.
        @discardableResult
        public func clear(_ destination: CIRenderDestination) throws -> CIRenderInfo {
            let task = try self.startTask(toClear: destination)
            return try task.waitUntilCompleted()
        }

    }

    /// Returns the ``Actor`` instance associated with this context.
    /// Calls to the actor will be forwarded to the context, but their execution
    /// will be synchronized and happen asynchronous in the background.
    var async: Actor {
        // check if we already have an Actor created for this context...
        if let actor = objc_getAssociatedObject(self, &ASSOCIATED_ACTOR_KEY) as? Actor {
            return actor
        // ... otherwise create a new one and safe it as associated object
        } else {
            let actor = Actor(self)
            objc_setAssociatedObject(self, &ASSOCIATED_ACTOR_KEY, actor, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return actor
        }
    }

}
