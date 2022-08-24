import CoreImage
import CoreImageExtensions
import XCTest


@available(iOS 11.0, macCatalyst 13.1, macOS 10.13, tvOS 11.0, *)
class RuntimeMetalKernelTests: XCTestCase {

    let metalKernelCode = """
        #include <CoreImage/CoreImage.h>
        using namespace metal;

        [[ stitchable ]] half4 general(coreimage::sampler_h src) {
            return src.sample(src.coord());
        }

        [[ stitchable ]] half4 otherGeneral(coreimage::sampler_h src) {
            return src.sample(src.coord());
        }

        [[ stitchable ]] half4 color(coreimage::sample_h src) {
            return src;
        }

        [[ stitchable ]] float2 warp(coreimage::destination dest) {
            return dest.coord();
        }
    """

    @available(iOS 15.0, macCatalyst 15.0, macOS 12.0, tvOS 15.0, *)
    func testRuntimeGeneralKernelCompilation() {
        XCTAssertNoThrow {
            let kernel = try CIKernel.kernel(withMetalString: self.metalKernelCode)
            XCTAssertEqual(kernel.name, "general")
        }
        XCTAssertNoThrow {
            let kernel = try CIKernel.kernel(withMetalString: self.metalKernelCode, kernelName: "otherGeneral")
            XCTAssertEqual(kernel.name, "otherGeneral")
        }
        XCTAssertThrowsError(try CIKernel.kernel(withMetalString: self.metalKernelCode, kernelName: "notFound"))
    }

    func testRuntimeGeneralKernelCompilationWithFallback() {
        let ciklKernelCode = """
            kernel vec4 passThrough(sampler src) {
                return sample(src, samplerTransform(src, destCoord()));
            }
        """
        XCTAssertNoThrow {
            let kernel = try CIKernel.kernel(withMetalString: self.metalKernelCode, fallbackCIKLString: ciklKernelCode)
            XCTAssertEqual(kernel.name, "general")
        }
        XCTAssertNoThrow {
            let kernel = try CIKernel.kernel(withMetalString: self.metalKernelCode, metalKernelName: "otherGeneral", fallbackCIKLString: ciklKernelCode)
            XCTAssertEqual(kernel.name, "otherGeneral")
        }
        XCTAssertThrowsError(try CIKernel.kernel(withMetalString: self.metalKernelCode, metalKernelName: "notFound", fallbackCIKLString: ciklKernelCode))
    }

    @available(iOS 15.0, macCatalyst 15.0, macOS 12.0, tvOS 15.0, *)
    func testRuntimeColorKernelCompilation() {
        XCTAssertNoThrow {
            let kernel = try CIColorKernel.kernel(withMetalString: self.metalKernelCode)
            XCTAssertEqual(kernel.name, "color")
        }
        XCTAssertNoThrow {
            let kernel = try CIColorKernel.kernel(withMetalString: self.metalKernelCode, kernelName: "color")
            XCTAssertEqual(kernel.name, "color")
        }
        XCTAssertThrowsError(try CIColorKernel.kernel(withMetalString: self.metalKernelCode, kernelName: "notFound"))
        XCTAssertThrowsError(try CIColorKernel.kernel(withMetalString: self.metalKernelCode, kernelName: "general"),
                             "Should not compile the general kernel as color kernel.")
    }

    func testRuntimeColorKernelCompilationWithFallback() {
        let ciklKernelCode = """
            kernel vec4 color(__sample src) {
                return src.rgba;
            }
        """
        XCTAssertNoThrow {
            let kernel = try CIColorKernel.kernel(withMetalString: self.metalKernelCode, fallbackCIKLString: ciklKernelCode)
            XCTAssertEqual(kernel.name, "color")
        }
        XCTAssertNoThrow {
            let kernel = try CIColorKernel.kernel(withMetalString: self.metalKernelCode, metalKernelName: "color", fallbackCIKLString: ciklKernelCode)
            XCTAssertEqual(kernel.name, "color")
        }
        XCTAssertThrowsError(try CIColorKernel.kernel(withMetalString: self.metalKernelCode, metalKernelName: "notFound", fallbackCIKLString: ciklKernelCode))
        XCTAssertThrowsError(try CIColorKernel.kernel(withMetalString: self.metalKernelCode, metalKernelName: "general", fallbackCIKLString: ciklKernelCode),
                             "Should not compile the general kernel as color kernel.")
    }

    @available(iOS 15.0, macCatalyst 15.0, macOS 12.0, tvOS 15.0, *)
    func testRuntimeWarpKernelCompilation() {
        XCTAssertNoThrow {
            let kernel = try CIWarpKernel.kernel(withMetalString: self.metalKernelCode)
            XCTAssertEqual(kernel.name, "warp")
        }
        XCTAssertNoThrow {
            let kernel = try CIWarpKernel.kernel(withMetalString: self.metalKernelCode, kernelName: "warp")
            XCTAssertEqual(kernel.name, "warp")
        }
        XCTAssertThrowsError(try CIWarpKernel.kernel(withMetalString: self.metalKernelCode, kernelName: "notFound"))
        XCTAssertThrowsError(try CIWarpKernel.kernel(withMetalString: self.metalKernelCode, kernelName: "general"),
                             "Should not compile the general kernel as warp kernel.")
    }

    func testRuntimeWarpKernelCompilationWithFallback() {
        let ciklKernelCode = """
            kernel vec2 warp() {
                return destCoord();
            }
        """
        XCTAssertNoThrow {
            let kernel = try CIWarpKernel.kernel(withMetalString: self.metalKernelCode, fallbackCIKLString: ciklKernelCode)
            XCTAssertEqual(kernel.name, "warp")
        }
        XCTAssertNoThrow {
            let kernel = try CIWarpKernel.kernel(withMetalString: self.metalKernelCode, metalKernelName: "warp", fallbackCIKLString: ciklKernelCode)
            XCTAssertEqual(kernel.name, "warp")
        }
        XCTAssertThrowsError(try CIWarpKernel.kernel(withMetalString: self.metalKernelCode, metalKernelName: "notFound", fallbackCIKLString: ciklKernelCode))
        XCTAssertThrowsError(try CIWarpKernel.kernel(withMetalString: self.metalKernelCode, metalKernelName: "general", fallbackCIKLString: ciklKernelCode),
                             "Should not compile the general kernel as warp kernel.")
    }

}
