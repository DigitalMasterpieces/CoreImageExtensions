#if DEBUG

import CoreImage


// MARK: - macOS

#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit

public extension CIImage.DebugProxy.RenderResult {

    /// Opens a system dialog for picking a folder where to export the rendering artifacts
    /// (the image as TIFF and various rendering graphs as PDFs) to.
    /// - Parameter filePrefix: A prefix that is added to the files. By default, the name of the app is used.
    func export(filePrefix: String? = nil) {
        let filePrefix = exportFilePrefix(filePrefix: filePrefix)
        openSavePanel(message: "Select folder where to save the render results") { url in
            // Write rendering results into the picked folder.
            self.writeResults(to: url, with: filePrefix)
        }
    }

}

/// Opens the system panel for selecting a folder to save rendering results to.
/// - Parameters:
///   - message: A message to display on top of the panel.
///   - callback: A callback for writing the files to the chosen URL.
private func openSavePanel(message: String, callback: @escaping (URL) -> Void) {
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

public extension CIImage.DebugProxy.RenderResult {

    /// Opens a share sheet for exporting the rendering artifacts (the image as TIFF and various rendering graphs as PDFs).
    /// On macOS, the system dialog for picking an export folder will be shown instead.
    /// - Parameter filePrefix: A prefix that is added to the files. By default, the name of the app is used.
    func export(filePrefix: String? = nil) {
        let filePrefix = exportFilePrefix(filePrefix: filePrefix)
        let shareItems = self.writeResults(to: FileManager.default.temporaryDirectory, with: filePrefix)
        openShareSheet(for: shareItems)
    }

}

/// Opens a share sheet for exporting the given files from the application's main window.
/// - Parameter items: A list of files to export. The files will be either moved or deleted after successful export.
private func openShareSheet(for items: [URL]) {
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
