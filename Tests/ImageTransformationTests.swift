import CoreImage
import CoreImageExtensions
import XCTest


class ImageTransformationTests: XCTestCase {

    /// Empty dummy image we can transform around to test effects on image extent.
    let testImage = CIImage.clear.cropped(to: CGRect(x: 0, y: 0, width: 200, height: 100))


    func testScaling() {
        let scaledImage = self.testImage.scaledBy(x: 0.5, y: 2.0)
        XCTAssertEqual(scaledImage.extent, CGRect(x: 0, y: 0, width: 100, height: 200))
    }

    func testTranslation() {
        let translatedImage = self.testImage.translatedBy(dx: 42.0, dy: -321.0)
        XCTAssertEqual(translatedImage.extent, CGRect(origin: CGPoint(x: 42.0, y: -321.0), size: self.testImage.extent.size))
    }

    func testMovingOrigin() {
        let newOrigin = CGPoint(x: 21.0, y: -42.0)
        let movedImage = self.testImage.moved(to: newOrigin)
        XCTAssertEqual(movedImage.extent, CGRect(origin: newOrigin, size: self.testImage.extent.size))
    }

    func testCentering() {
        let recenteredImage = self.testImage.centered(at: .zero)
        XCTAssertEqual(recenteredImage.extent, CGRect(origin: CGPoint(x: -100.0, y: -50.0), size: self.testImage.extent.size))
    }

    func testPadding() {
        let paddedImage = self.testImage.paddedBy(dx: 20, dy: 60)
        XCTAssertEqual(paddedImage.extent, CGRect(x: -20, y: -60, width: 240, height: 220))
    }

}
