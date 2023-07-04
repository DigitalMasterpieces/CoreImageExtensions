import CoreGraphics


/// Some useful extensions for convenience access to the most common color spaces needed when working with Core Image.
public extension CGColorSpace {

    /// The standard Red Green Blue (sRGB) color space.
    static var sRGBColorSpace: CGColorSpace? { CGColorSpace(name: CGColorSpace.sRGB) }
    /// The sRGB color space with a linear transfer function and extended-range values.
    static var extendedLinearSRGBColorSpace: CGColorSpace? { CGColorSpace(name: CGColorSpace.extendedLinearSRGB) }

    /// The Display P3 color space.
    static var displayP3ColorSpace: CGColorSpace? { CGColorSpace(name: CGColorSpace.displayP3) }
    /// The Display P3 color space with a linear transfer function and extended-range values.
    static var extendedLinearDisplayP3ColorSpace: CGColorSpace? { CGColorSpace(name: CGColorSpace.extendedLinearDisplayP3) }

    /// The recommendation of the International Telecommunication Union (ITU) Radiocommunication sector for the BT.2020 color space.
    static var itur2020ColorSpace: CGColorSpace? { CGColorSpace(name: CGColorSpace.itur_2020) }
    /// The recommendation of the International Telecommunication Union (ITU) Radiocommunication sector for the BT.2020 color space,
    /// with a linear transfer function and extended range values.
    static var extendedLinearITUR2020ColorSpace: CGColorSpace? { CGColorSpace(name: CGColorSpace.extendedLinearITUR_2020) }

    /// The recommendation of the International Telecommunication Union (ITU) Radiocommunication sector for the BT.2100 color space,
    /// with the HLG transfer function.
    @available(iOS 12.6, macCatalyst 13.1, macOS 10.15.6, tvOS 12.0, watchOS 5.0, *)
    static var itur2100HLGColorSpace: CGColorSpace? {
        if #available(iOS 14.0, macCatalyst 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            return CGColorSpace(name: CGColorSpace.itur_2100_HLG)
        } else {
            return CGColorSpace(name: CGColorSpace.itur_2020_HLG)
        }
    }
    /// The recommendation of the International Telecommunication Union (ITU) Radiocommunication sector for the BT.2100 color space,
    /// with the PQ transfer function.
    static var itur2100PQColorSpace: CGColorSpace? {
        if #available(iOS 14.0, macCatalyst 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            return CGColorSpace(name: CGColorSpace.itur_2100_PQ)
        } else {
            return CGColorSpace(name: CGColorSpace.itur_2020_PQ_EOTF)
        }
    }

}
