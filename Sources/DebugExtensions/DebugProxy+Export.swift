#if DEBUG

import CoreImage


// MARK: - macOS

#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit

public extension CIImage.DebugProxy {

    /// Renders the image with the given settings and opens a system dialog for picking a folder where to save the image to.
    /// - Parameters:
    ///   - filePrefix: A prefix that is added to the image file. By default, the name of the app is used.
    ///   - codec: The codec of the exported image. Uses uncompressed TIFF by default.
    ///   - format: The image format. This influences bit depth (8-, 16-, or 32-bit) and pixel format (uint or float). Defaults to 8-bit uint.
    ///             Note that not all formats are supported by all codecs. E.g., `jpeg` and `heif` only supports 8-bit formats.
    ///   - quality: The quality of the exported image, i.e., the amount of compression. Only supported by `jpeg`, `heif`, and `heif10` codecs.
    ///   - colorSpace: The color space of the exported image. By default, the Display P3 color space is used.
    ///                 Note that it needs to match the chosen `format`, i.e., a single-channel format needs a grayscale color space.
    func export(filePrefix: String? = nil, codec: ImageCodec = .tiff, format: CIFormat = .RGBA8, quality: Float = 1.0, colorSpace: CGColorSpace? = nil) {
        let filePrefix = exportFilePrefix(filePrefix: filePrefix)
        Task {
            await openSavePanel(message: "Select folder where to save the image") { url in
                let imageURL = url.appendingPathComponent("\(filePrefix)_image").appendingPathExtension(codec.fileExtension)
                self.write(to: imageURL, codec: codec, format: format, quality: quality, colorSpace: colorSpace)
            }
        }
    }

}

public extension CIImage.DebugProxy.RenderResult {

    /// Opens a system dialog for picking a folder where to export the rendering artifacts
    /// (the image as TIFF and various rendering graphs as PDFs) to.
    /// - Parameter filePrefix: A prefix that is added to the files. By default, the name of the app is used.
    func export(filePrefix: String? = nil) {
        let filePrefix = exportFilePrefix(filePrefix: filePrefix)
        Task {
            await openSavePanel(message: "Select folder where to save the render results") { url in
                // Write rendering results into the picked folder.
                self.writeResults(to: url, with: filePrefix)
            }
        }
    }

}

/// Opens the system panel for selecting a folder to save rendering results to.
/// - Parameters:
///   - message: A message to display on top of the panel.
///   - callback: A callback for writing the files to the chosen URL.
@MainActor private func openSavePanel(message: String, callback: @escaping (URL) -> Void) {
    // Use the system panel for picking the folder where to save the files.
    let openPanel = NSOpenPanel()
    openPanel.message = message
    openPanel.prompt = "Select"
    openPanel.canChooseFiles = false
    openPanel.canChooseDirectories = true
    openPanel.canCreateDirectories = true

    openPanel.begin { response in
        guard response == .OK else { return }
        callback(openPanel.url!)
    }
}

#endif // AppKit


// MARK: - iOS

#if canImport(UIKit)

import UIKit

public extension CIImage.DebugProxy {

    /// Renders the image with the given settings and opens a share sheet for exporting the image.
    /// - Parameters:
    ///   - filePrefix: A prefix that is added to the image file. By default, the name of the app is used.
    ///   - codec: The codec of the exported image. Uses uncompressed TIFF by default.
    ///   - format: The image format. This influences bit depth (8-, 16-, or 32-bit) and pixel format (uint or float). Defaults to 8-bit uint.
    ///             Note that not all formats are supported by all codecs. E.g., `jpeg` and `heif` only supports 8-bit formats.
    ///   - quality: The quality of the exported image, i.e., the amount of compression. Only supported by `jpeg`, `heif`, and `heif10` codecs.
    ///   - colorSpace: The color space of the exported image. By default, the Display P3 color space is used.
    ///                 Note that it needs to match the chosen `format`, i.e., a single-channel format needs a grayscale color space.
    func export(filePrefix: String? = nil, codec: ImageCodec = .tiff, format: CIFormat = .RGBAh, quality: Float = 1.0, colorSpace: CGColorSpace? = nil) {
        let filePrefix = exportFilePrefix(filePrefix: filePrefix)
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(filePrefix)_image").appendingPathExtension(codec.fileExtension)
        self.write(to: fileURL, codec: codec, format: format, quality: quality, colorSpace: colorSpace)
        Task {
            await openShareSheet(for: [fileURL])
        }
    }

}

public extension CIImage.DebugProxy.RenderResult {

    /// Opens a share sheet for exporting the rendering artifacts (the image as TIFF and various rendering graphs as PDFs).
    /// On macOS, the system dialog for picking an export folder will be shown instead.
    /// - Parameter filePrefix: A prefix that is added to the files. By default, the name of the app is used.
    func export(filePrefix: String? = nil) {
        let filePrefix = exportFilePrefix(filePrefix: filePrefix)
        let shareItems = self.writeResults(to: FileManager.default.temporaryDirectory, with: filePrefix)
        Task {
            await openShareSheet(for: shareItems)
        }
    }

}

/// Opens a share sheet (or document picker on Catalyst) for exporting the given files from the application's main window.
/// - Parameter items: A list of files to export. The files will be either moved or deleted after successful export.
@MainActor private func openShareSheet(for items: [URL]) {
    let window = UIApplication.shared.windows.first

    if #available(iOS 14, *), ProcessInfo().isMacCatalystApp || ProcessInfo().isiOSAppOnMac {
        let documentPicker = UIDocumentPickerViewController(forExporting: items)
        window?.rootViewController?.present(documentPicker, animated: true)
    } else {
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { _, _, _, _ in
            items.forEach { try? FileManager.default.removeItem(at: $0) }
        }
        activityViewController.popoverPresentationController?.sourceView = window
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: window?.bounds.midX ?? 0, y: 0, width: 1, height: 20)
        window?.rootViewController?.present(activityViewController, animated: true)
    }
}

#endif // UIKit


// MARK: - Common

extension CIImage.DebugProxy {

    public enum ImageCodec {
        case exr
        case jpeg
        case heif
        @available(iOS 15, macOS 12, macCatalyst 15, *)
        case heif10
        case png
        case tiff

        fileprivate var fileExtension: String {
            switch self {
                case .exr: return "exr"
                case .jpeg: return "jpeg"
                case .heif, .heif10: return "heic"
                case .png: return "png"
                case .tiff: return "tiff"
            }
        }
    }

    private func write(to fileURL: URL, codec: ImageCodec, format: CIFormat = .RGBA8, quality: Float = 1.0, colorSpace: CGColorSpace?) {
        let colorSpace = colorSpace ?? .displayP3ColorSpace ?? CGColorSpaceCreateDeviceRGB()
        switch codec {
            case .exr:
                try! self.context.writeEXRRepresentation(of: self.image, to: fileURL, format: format, colorSpace: colorSpace)
            case .jpeg:
                try! self.context.writeJPEGRepresentation(of: self.image, to: fileURL, colorSpace: colorSpace, quality: quality)
            case .heif:
                try! self.context.writeHEIFRepresentation(of: self.image, to: fileURL, format: format, colorSpace: colorSpace, quality: quality)
            case .heif10:
                if #available(iOS 15, macOS 12, macCatalyst 15, *) {
                    try! self.context.writeHEIF10Representation(of: self.image, to: fileURL, colorSpace: colorSpace, quality: quality)
                }
            case .png:
                try! self.context.writePNGRepresentation(of: self.image, to: fileURL, format: format, colorSpace: colorSpace)
            case .tiff:
                try! self.context.writeTIFFRepresentation(of: self.image, to: fileURL, format: format, colorSpace: colorSpace)
        }
    }

}

/// Creates a prefix to use for exported files, containing the given `filePrefix` (or the app name if not given) and the current time.
private func exportFilePrefix(filePrefix: String?) -> String {
    // The the name of the app as default prefix if possible.
    let filePrefix = (filePrefix ?? Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String)?.appending("_") ?? ""

    // Add the current time to the file name to avoid name clashes.
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH-mm-ss"
    let timeString = dateFormatter.string(from: Date())
    return filePrefix.appending(timeString)
}

private extension CIImage.DebugProxy.RenderResult {

    /// Writes file representations of all rendering result objects (image and various render graphs)
    /// into the given `directory` with the given `filePrefix` and returns the URLs of the written files.
    @discardableResult func writeResults(to directory: URL, with filePrefix: String) -> [URL] {
        let imageURL = directory.appendingPathComponent("\(filePrefix)_image").appendingPathExtension("tiff")
        self.image.writeTIFFRepresentation(to: imageURL, with: self.debugProxy.image.properties as CFDictionary)
        let initialGraphURL = directory.appendingPathComponent("\(filePrefix)_initial_graph").appendingPathExtension("pdf")
        self.initialGraph.write(to: initialGraphURL)
        let optimizedGraphURL = directory.appendingPathComponent("\(filePrefix)_optimized_graph").appendingPathExtension("pdf")
        self.optimizedGraph.write(to: optimizedGraphURL)
        let programGraphURL = directory.appendingPathComponent("\(filePrefix)_program_graph").appendingPathExtension("pdf")
        self.programGraph.write(to: programGraphURL)

        return [imageURL, initialGraphURL, optimizedGraphURL, programGraphURL]
    }

}

#if canImport(MobileCoreServices)
import MobileCoreServices
#else
import CoreServices
#endif

private extension CGImage {

    /// Writes a TIFF file containing the image with the give metadata `properties` to `url`.
    func writeTIFFRepresentation(to url: URL, with properties: CFDictionary) {
        let destination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypeTIFF as CFString, 1, nil)!
        CGImageDestinationAddImage(destination, self, properties)
        CGImageDestinationFinalize(destination)
    }

}

#endif // DEBUG
