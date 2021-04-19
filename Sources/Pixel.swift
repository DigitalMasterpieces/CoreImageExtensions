import simd


/// Helper type representing a pixel with RGBA channels.
public typealias Pixel = SIMD4

public extension Pixel {

    /// The red channel of the pixel.
    var r: Scalar { self.x }
    /// The green channel of the pixel.
    var g: Scalar { self.y }
    /// The blue channel of the pixel.
    var b: Scalar { self.z }
    /// The alpha channel of the pixel.
    var a: Scalar { self.w }

}
