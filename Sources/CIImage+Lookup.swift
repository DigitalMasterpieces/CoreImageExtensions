import CoreGraphics
import CoreImage

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif


public extension CIImage {

    #if canImport(UIKit)
    /// Convenience initializer for loading an image by its name from the given bundle.
    /// This will try to load the image from an asset catalog first and will search the bundle
    /// directly otherwise.
    /// - Parameters:
    ///   - name: The name of the image. Should contain the file extension for bundle resources.
    ///   - bundle: The bundle containing the image file or asset catalog. Specify nil to search the app’s main bundle.
    ///   - traitCollection: The traits associated with the intended environment for the image. Use this parameter to ensure
    ///                      that the correct variant of the image is loaded. If you specify nil,
    ///                      this method uses the traits associated with the main screen.
    convenience init?(named name: String, in bundle: Bundle? = nil, compatibleWith traitCollection: UITraitCollection? = nil) {
        // on iOS, UIImage handles all the lookup logic automatically, so just use that
        if let uiImage = UIImage(named: name, in: bundle, compatibleWith: traitCollection) {
            self.init(image: uiImage)
        } else {
            return nil
        }
    }
    #endif

    #if canImport(AppKit)
    /// Convenience initializer for loading an image by its name from the given bundle.
    /// This will try to load the image from an asset catalog first and will search the bundle
    /// directly otherwise.
    /// - Parameters:
    ///   - name: The name of the image. Should contain the file extension for bundle resources.
    ///   - bundle: The bundle containing the image file or asset catalog. Specify nil to search the app’s main bundle.
    convenience init?(named name: String, in bundle: Bundle? = nil) {
        let bundle = bundle ?? Bundle.main
        // try to load from asset catalog first
        if let nsImage = bundle.image(forResource: name), let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            self.init(cgImage: cgImage)
        // search the bundle directly otherwise
        } else if let url = bundle.url(forResource: name, withExtension: nil) {
            self.init(contentsOf: url)
        } else {
            return nil
        }
    }
    #endif

}
