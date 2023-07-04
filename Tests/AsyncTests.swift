import CoreImage
import CoreImageExtensions
import XCTest


class AsyncTests: XCTestCase {

    let context = CIContext()

    let testPixelImage = CIImage.containing(values: CIVector(x: 0.0, y: 0.5, z: 1.0, w: 1.0))!.cropped(to: .singlePixel)

    func testContextRelease() {
        var context: CIContext? = CIContext()
        // create actor
        let _ = context?.async
        // create weak reference
        weak var weakContext = context
        // release context
        context = nil
        XCTAssertNil(weakContext, "The context should release properly, even after creating the actor.")
    }

    func testReadPixelAsync() async {
        let value = await self.context.async.readUInt8PixelValue(from: testPixelImage, at: .zero)
        XCTAssertEqual(value, Pixel<UInt8>(x: 0, y: 128, z: 255, w: 255))
    }

    func testCreateCGImageAsync() async {
        let cgImage = await self.context.async.createCGImage(testPixelImage, from: .singlePixel)
        XCTAssertNotNil(cgImage)
    }

}
