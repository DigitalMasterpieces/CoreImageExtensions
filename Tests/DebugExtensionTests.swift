import CoreImage
import CoreImageExtensions
import XCTest


class DebugExtensionTests: XCTestCase {

    /// A simple test image containing a colorful circle.
    let testImage = CIFilter(name: "CIHueSaturationValueGradient", parameters: [kCIInputRadiusKey: 50])!.outputImage!


    @available(iOS 12.0, macOS 10.5, macCatalyst 13.0, tvOS 12.0, *)
    func testImageStatistics() {
        let wholeStats = testImage.debug.statistics()
        XCTAssertEqual(wholeStats.description,
        """
        min: (r: -0.000, g: -0.000, b: -0.000, a:  0.000)
        max: (r:  1.004, g:  1.004, b:  1.004, a:  1.000)
        avg: (r:  0.423, g:  0.423, b:  0.423, a:  0.770)
        """)

        let areaStats = testImage.debug.statistics(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        XCTAssertEqual(areaStats.description,
        """
        min: (r:  0.076, g:  0.076, b:  0.076, a:  1.000)
        max: (r:  1.004, g:  1.004, b:  1.004, a:  1.000)
        avg: (r:  0.676, g:  0.670, b:  0.670, a:  1.000)
        """)
    }

    func testRenderInfo() {
        let result = testImage.debug.render()
        // Just test that those APIs don't crash.
        _ = result.image
        _ = testImage.debug.cgImage
        _ = testImage.pdfRepresentation
        _ = result.renderTask.pdfRepresentation
        _ = result.renderInfo.pdfRepresentation
    }

}
