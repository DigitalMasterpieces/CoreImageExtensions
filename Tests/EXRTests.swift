import CoreImage
import CoreImageExtensions
import XCTest


class EXRTests: XCTestCase {

    let context = CIContext()

    func testEXRDataCreation() {
        let testImage = CIImage.containing(values: CIVector(x: -2.0, y: 0.0, z: 3.0, w: 1.0))!.cropped(to: CGRect(x: 0, y: 0, width: 32, height: 16))

        guard let exrData = self.context.exrRepresentation(of: testImage, format: .RGBAh, colorSpace: context.workingColorSpace ?? CGColorSpaceCreateDeviceRGB()) else {
            XCTFail("Failed to create EXR data from image")
            return
        }

        guard let loadedImage = CIImage(data: exrData) else {
            XCTFail("Failed to read EXR data back into image")
            return
        }

        let value = self.context.readFloat32PixelValue(from: loadedImage, at: .zero)
        XCTAssertEqual(value.r, -2.0, accuracy: 0.001)
        XCTAssertEqual(value.g,  0.0, accuracy: 0.001)
        XCTAssertEqual(value.b,  3.0, accuracy: 0.001)
        XCTAssertEqual(value.a,  1.0, accuracy: 0.001)
    }

    func testEXRLoading() {
        let testEXRImage = CIImage(named: "AllHalfValues.exr", in: Bundle.module)!

        // sample a random pixel value for testing
        let value1 = self.context.readFloat32PixelValue(from: testEXRImage, at: CGPoint(x: 10, y: 20))
        XCTAssertEqual(value1.r, -3604.0)

        // try to render the image back into data and load again
        guard let exrData = self.context.exrRepresentation(of: testEXRImage, format: .RGBAh, colorSpace: context.workingColorSpace ?? CGColorSpaceCreateDeviceRGB()) else {
            XCTFail("Failed to create EXR data from image")
            return
        }
        guard let loadedImage = CIImage(data: exrData) else {
            XCTFail("Failed to read EXR data back into image")
            return
        }

        let value2 = self.context.readFloat32PixelValue(from: loadedImage, at: CGPoint(x: 10, y: 20))
        XCTAssertEqual(value2.r, -3604.0, accuracy: 0.001)
    }

}