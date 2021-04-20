import CoreImage
import CoreImageExtensions
import XCTest


class Float32ValueAccessTests: XCTestCase {

    let context = CIContext()

    let testPixelImage = CIImage.containing(values: CIVector(x: -1.0, y: 0.0, z: 2.0, w: 1.0))!.cropped(to: .singlePixel)
    let test2x2Image = CIImage.containing(value: 0.5)!.cropped(to: .twoByTwo)

    func testReadPixels() {
        let values = self.context.readFloat32PixelValues(from: test2x2Image, in: .twoByTwo)
        XCTAssertEqual(values.count, 4)
        let pixelValue = Pixel<Float32>(x: 0.5, y: 0.5, z: 0.5, w: 1.0)
        XCTAssertEqual(values, [pixelValue, pixelValue, pixelValue, pixelValue])
    }

    func testReadPixel() {
        let value = self.context.readFloat32PixelValue(from: test2x2Image, at: CGPoint(x: 1, y: 0))
        XCTAssertEqual(value, Pixel<Float32>(x: 0.5, y: 0.5, z: 0.5, w: 1.0))
    }

    func testExtendedRange() {
        let value = self.context.readFloat32PixelValue(from: testPixelImage, at: .zero)
        XCTAssertEqual(value, Pixel<Float32>(x: -1.0, y: 0.0, z: 2.0, w: 1.0))
    }

}
