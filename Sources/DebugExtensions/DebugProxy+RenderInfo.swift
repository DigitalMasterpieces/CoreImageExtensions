#if DEBUG
import CoreImage
import PDFKit


public extension CIImage.DebugProxy {

    /// The result of a debug rendering of an image.
    ///
    /// It contains the rendered image, the `CIRenderTask` and `CIRenderInfo` that contain the optimized and the
    /// program filter graphs, respectively. These graphs are the same as obtained by `CI_PRINT_TREE`.
    /// The graphs can be viewed when using Quick Look on the returned `task` or `info` object.
    struct RenderResult {

        let debugProxy: CIImage.DebugProxy

        /// The rendered image in 16-bit half float format as `CGImage`.
        /// This is the same format that Core Image uses internally during processing (with default settings).
        public let image: CGImage
        /// The `CIRenderTask` object describing the optimized rendering graph before execution.
        public let renderTask: CIRenderTask
        /// The `CIRenderInfo` obtained after rendering, containing runtime information as well as the concatenated program filter graph.
        public let renderInfo: CIRenderInfo

        /// Shows the rendered image as well as the unoptimized filter graph.
        /// This is more or less equivalent to the "initial graph" obtained by `CI_PRINT_TREE`.
        public var initialGraph: PDFDocument { self.debugProxy.image.pdfRepresentation }
        /// Shows the optimized filter graph, equivalent to the "optimized graph" obtained by `CI_PRINT_TREE`.
        public var optimizedGraph: PDFDocument { self.renderTask.pdfRepresentation }
        /// Shows runtime information and the program filter graph, equivalent to the concatenated "program graph" obtained by `CI_PRINT_TREE`.
        public var programGraph: PDFDocument { self.renderInfo.pdfRepresentation }

        init(debugProxy: CIImage.DebugProxy, image: CGImage, renderTask: CIRenderTask, renderInfo: CIRenderInfo) {
            self.debugProxy = debugProxy
            self.image = image
            self.renderTask = renderTask
            self.renderInfo = renderInfo
        }

    }

    /// Renders the image into an empty surface and returns all rendering results and infos.
    /// - Parameter outputColorSpace: The color space of the resulting image. By default, the `workingColorSpace` of the `context` is used.
    /// - Returns: A `RenderingResult` containing all information about the rendering process and
    ///            its results.
    func render(outputColorSpace: CGColorSpace? = nil) -> RenderResult {
        if self.image.extent.isInfinite {
            fatalError("Can't render an image with infinite extent. You need to crop the image to a finite extent first.")
        }

        // Move image to [0, 0] so it matches the destination.
        let image = self.image.moved(to: .zero)

        // Use the working color space of the context if non was given.
        let outputColorSpace = outputColorSpace ?? self.context.workingColorSpace ?? .extendedLinearSRGBColorSpace!

        // Create a bitmap context so we have some image memory we can render into...
        let bitmapContext = CGContext(data: nil,
                                      width: Int(image.extent.width),
                                      height: Int(image.extent.height),
                                      bitsPerComponent: 16,
                                      bytesPerRow: 8 * Int(image.extent.width),
                                      space: outputColorSpace,
                                      bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder16Little.rawValue | CGBitmapInfo.floatComponents.rawValue).rawValue)!
        // ... and create a `CIRenderDestination` for rendering into that bitmap memory.
        let destination = CIRenderDestination(bitmapData: bitmapContext.data!,
                                              width: bitmapContext.width,
                                              height: bitmapContext.height,
                                              bytesPerRow: bitmapContext.bytesPerRow,
                                              format: .RGBAh)
        destination.colorSpace = outputColorSpace

        let task = try! self.context.startTask(toRender: image, to: destination)
        let info = try! task.waitUntilCompleted()
        let cgImage = bitmapContext.makeImage()!
        return RenderResult(debugProxy: self, image: cgImage, renderTask: task, renderInfo: info)
    }

}

public extension CIImage.DebugProxy {
    /// Renders the `image` into a `CGImage` using the `context`'s `workingFormat` and `workingColorSpace` and returns it.
    ///
    /// You can use this property as an alternative when QuickLook on the `CIImage` fails
    /// or when you only want to see the rendered image without the filter graph.
    var cgImage: CGImage {
        return self.context.createCGImage(self.image, from: self.image.extent, format: self.context.workingFormat, colorSpace: self.context.workingColorSpace)!
    }
}

public extension CIImage {
    /// Exposes the internal API used to create the Quick Look representation of a `CIImage` as a `PDFDocument`.
    /// This shows the rendered image as well as the unoptimized filter graph.
    /// This is more or less equivalent to the "initial graph" obtained by `CI_PRINT_TREE`.
    var pdfRepresentation: PDFDocument {
        PDFDocument(data: self.value(forKey: "_pdfDataRepresentation") as! Data)!
    }
}

public extension CIRenderTask {
    /// Exposes the internal API used to create the Quick Look representation of a `CIRenderTask` as a `PDFDocument`.
    /// This shows the optimized filter graph, equivalent to the "optimized graph" obtained by `CI_PRINT_TREE`.
    var pdfRepresentation: PDFDocument {
        PDFDocument(data: self.value(forKey: "_pdfDataRepresentation") as! Data)!
    }
}

public extension CIRenderInfo {
    /// Exposes the internal API used to create the Quick Look representation of a `CIRenderInfo` as a `PDFDocument`.
    /// This shows runtime information and the program filter graph, equivalent to the concatenated "program graph" obtained by `CI_PRINT_TREE`.
    var pdfRepresentation: PDFDocument {
        PDFDocument(data: self.value(forKey: "_pdfDataRepresentation") as! Data)!
    }
}

#endif
