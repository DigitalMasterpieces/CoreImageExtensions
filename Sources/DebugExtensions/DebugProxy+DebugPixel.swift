#if DEBUG
import CoreImage


public extension CIImage.DebugProxy {

    /// A wrapper around a `Pixel` value that offers better human-readable
    /// description and introspection of its values.
    @dynamicMemberLookup
    struct DebugPixel<Scalar: SIMDScalar>: CustomStringConvertible, CustomReflectable {
        let value: Pixel<Float32>

        init(_ value: Pixel<Float32>) {
            self.value = value
        }

        // Forward accessors and methods to inner `value`.
        subscript<T>(dynamicMember keyPath: KeyPath<Pixel<Float32>, T>) -> T {
            value[keyPath: keyPath]
        }

        /// Formates the pixel component values to 3 fraction digits and with aligned sign prefix.
        private var formattedValues: (r: String, g: String, b: String, a: String) {
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 3
            formatter.minimumFractionDigits = 3
            formatter.positivePrefix = " "
            /// Round very small values to zero to avoid `-0.000` values when printing.
            let value = self.value.cleaned
            let r = formatter.string(from: NSNumber(value: value.r))!
            let g = formatter.string(from: NSNumber(value: value.g))!
            let b = formatter.string(from: NSNumber(value: value.b))!
            let a = formatter.string(from: NSNumber(value: value.a))!
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


private extension Pixel<Float32> {
    /// Rounds very small values to zero to avoid `-0.000` values when printing.
    var cleaned: Self { return Self(self.r.cleaned, self.g.cleaned, self.b.cleaned, self.a.cleaned) }
}

private extension Float32 {
    /// Rounds very small values to zero to avoid `-0.000` values when printing.
    var cleaned: Self { return (abs(self) < 0.0001) ? 0.0 : self }
}

#endif
