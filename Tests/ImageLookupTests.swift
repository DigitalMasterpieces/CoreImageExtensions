import CoreImage
import CoreImageExtensions
import XCTest


class ImageLookupTests: XCTestCase {

    func testLoadingFromCatalog() {
        let bundle = Bundle.module
        let image = CIImage(named: "imageInCatalog", in: bundle)
        XCTAssertNotNil(image)
    }

    func testLoadingFromBundle() {
        let bundle = Bundle.module
        let image = CIImage(named: "imageInBundle", in: bundle)
        XCTAssertNotNil(image)
    }

}
