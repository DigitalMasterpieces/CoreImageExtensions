import CoreImage
import CoreImageExtensions
import XCTest


class ColorExtensionsTests: XCTestCase {

    func testWhite() {
        let whiteColor = CIColor(white: 0.42, alpha: 0.21, colorSpace: .itur2020ColorSpace)

        XCTAssertEqual(whiteColor?.red, 0.42)
        XCTAssertEqual(whiteColor?.green, 0.42)
        XCTAssertEqual(whiteColor?.blue, 0.42)
        XCTAssertEqual(whiteColor?.alpha, 0.21)
        XCTAssertEqual(whiteColor?.colorSpace, .itur2020ColorSpace)

        let clampedWhite = CIColor(white: 1.5)
        XCTAssertEqual(clampedWhite?.red, 1.0)
        XCTAssertEqual(clampedWhite?.green, 1.0)
        XCTAssertEqual(clampedWhite?.blue, 1.0)
        XCTAssertEqual(clampedWhite?.alpha, 1.0)
    }

    func testExtendedWhite() {
        let extendedWhiteColor = CIColor(extendedWhite: 1.42, alpha: 0.34)

        XCTAssertEqual(extendedWhiteColor?.red, 1.42)
        XCTAssertEqual(extendedWhiteColor?.green, 1.42)
        XCTAssertEqual(extendedWhiteColor?.blue, 1.42)
        XCTAssertEqual(extendedWhiteColor?.alpha, 0.34)
        XCTAssertEqual(extendedWhiteColor?.colorSpace, .extendedLinearSRGBColorSpace)
    }

    func testExtendedColor() {
        let extendedColor = CIColor(extendedRed: -0.12, green: 0.43, blue: 1.45, alpha: 0.89)

        XCTAssertEqual(extendedColor?.red, -0.12)
        XCTAssertEqual(extendedColor?.green, 0.43)
        XCTAssertEqual(extendedColor?.blue, 1.45)
        XCTAssertEqual(extendedColor?.alpha, 0.89)
        XCTAssertEqual(extendedColor?.colorSpace, .extendedLinearSRGBColorSpace)
    }

    func testContrastColor() {
        XCTAssertEqual(CIColor.white.contrastOverlayColor, .black)
        XCTAssertEqual(CIColor.red.contrastOverlayColor, .white)
        XCTAssertEqual(CIColor.green.contrastOverlayColor, .black)
        XCTAssertEqual(CIColor.blue.contrastOverlayColor, .white)
        XCTAssertEqual(CIColor.yellow.contrastOverlayColor, .black)
        XCTAssertEqual(CIColor.cyan.contrastOverlayColor, .black)
        XCTAssertEqual(CIColor.magenta.contrastOverlayColor, .black)
        XCTAssertEqual(CIColor.black.contrastOverlayColor, .white)
    }

}
