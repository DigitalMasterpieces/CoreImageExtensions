#if DEBUG
import CoreImage


public extension CIImage.DebugProxy {

    /// A wrapper around a `Pixel` value that offers better human-readable
    /// description and introspection of its values.
    struct DebugPixel<Scalar: SIMDScalar>: CustomStringConvertible, CustomReflectable {
        let value: Pixel<Float32>

        init(_ value: Pixel<Float32>) {
            self.value = value
        }

        public var r: Float32 { self.value.r }
        public var g: Float32 { self.value.g }
        public var b: Float32 { self.value.b }
        public var a: Float32 { self.value.a }

        /// Formates the pixel component values to 3 fraction digits and with aligned sign prefix.
        private var formattedValues: (r: String, g: String, b: String, a: String) {
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 3
            formatter.minimumFractionDigits = 3
            formatter.positivePrefix = " "
            let r = formatter.string(from: NSNumber(value: self.r))!
            let g = formatter.string(from: NSNumber(value: self.g))!
            let b = formatter.string(from: NSNumber(value: self.b))!
            let a = formatter.string(from: NSNumber(value: self.a))!
            return (r, g, b, a)
        }

        public var description: String {
            let vals = self.formattedValues
            return "(r: \(vals.r), g: \(vals.g), b: \(vals.b), a: \(vals.a))"
        }

        public var customMirror: Mirror {
            let vals = self.formattedValues
            return Mirror(self,
                          children: ["r": vals.r, "g": vals.g, "b": vals.b, "a": vals.a],
                          displayStyle: .tuple
            )
        }
    }

}

#endif
