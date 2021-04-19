import CoreImage
import CoreImageExtensions
import XCTest


class UInt8ValueAccessTests: XCTestCase {

    let context = CIContext()

    let testPixelImage = CIImage.containing(values: CIVector(x: -1.0, y: 0.0, z: 2.0, w: 1.0))!.cropped(to: .singlePixel)
    let test2x2Image = CIImage.containing(values: CIVector(x: 0.0, y: 0.5, z: 1.0, w: 1.0))!.cropped(to: .twoByTwo)

    func testReadPixels() {
        let values = self.context.readUInt8PixelValues(from: test2x2Image, in: .twoByTwo)
        XCTAssertEqual(values.count, 4)
        let pixelValue = Pixel<UInt8>(x: 0, y: 128, z: 255, w: 255)
        XCTAssertEqual(values, [pixelValue, pixelValue, pixelValue, pixelValue])
    }

    func testReadPixel() {
        let value = self.context.readUInt8PixelValue(from: test2x2Image, at: CGPoint(x: 0, y: 1))
        XCTAssertEqual(value, Pixel<UInt8>(x: 0, y: 128, z: 255, w: 255))
    }

    func testClamping() {
        let value = self.context.readUInt8PixelValue(from: testPixelImage, at: .zero)
        XCTAssertEqual(value, Pixel<UInt8>(x: 0, y: 0, z: 255, w: 255))
    }

}
