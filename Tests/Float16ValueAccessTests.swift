import CoreImage
import CoreImageExtensions
import XCTest


@available(iOS 14, tvOS 14, *)
@available(macOS, unavailable)
@available(macCatalyst, unavailable)
class Float16ValueAccessTests: XCTestCase {

    let context = CIContext()

    let testPixelImage = CIImage.containing(values: CIVector(x: -1.0, y: 0.0, z: 2.0, w: 1.0))!.cropped(to: .singlePixel)
    let test2x2Image = CIImage.containing(values: CIVector(x: 0.0, y: 0.5, z: 1.0, w: 1.0))!.cropped(to: .twoByTwo)

    func testReadPixels() {
        let values = self.context.readFloat16PixelValues(from: test2x2Image, in: .twoByTwo)
        XCTAssertEqual(values.count, 4)
        let pixelValue = Pixel<Float16>(x: 0.0, y: 0.5, z: 1.0, w: 1.0)
        XCTAssertEqual(values, [pixelValue, pixelValue, pixelValue, pixelValue])
    }

    func testReadPixel() {
        let value = self.context.readFloat16PixelValue(from: test2x2Image, at: CGPoint(x: 1, y: 0))
        XCTAssertEqual(value, Pixel<Float16>(x: 0.0, y: 0.5, z: 1.0, w: 1.0))
    }

    func testExtendedRange() {
        let value = self.context.readFloat16PixelValue(from: testPixelImage, at: .zero)
        XCTAssertEqual(value, Pixel<Float16>(x: -1.0, y: 0.0, z: 2.0, w: 1.0))
    }

}
