# CoreImageExtensions

Useful extensions for Apple's Core Image framework.

## Async Rendering
Almost all rendering APIs of `CIContext` are synchronous, i.e., they will block the current thread until rendering is done. In many cases, especially when calling from the main thread, this is undesirable.

We added an extension to `CIContext` that adds `async` versions of all rendering APIs via a wrapping `actor` instance. The actor can be accessed via the `async` property:
```swift
let cgImage = await context.async.createCGImage(ciImage, from: ciImage.extent)
```

> **_Note:_**
> Though they are already asynchronous, even the APIs for working with `CIRenderDestination`, like `startTask(toRender:to:)`, will profit from using the `async` versions.
> This is because Core Image will perform an analysis of the filter graph that should be applied to the given image _before_ handing the rendering work to the GPU. 
> Especially for more complex filter pipelines this analysis can be quite costly and is better performed in a background queue to not block the main thread.

We also added async alternatives for the `CIRenderDestination`-related APIs that wait for the task execution and return the `CIRenderInfo` object:
```swift
let info = try await context.async.render(image, from: rect, to: destination, at: point)
let info = try await context.async.render(image, to: destination)
let info = try await context.async.clear(destination)
```

## Image Lookup
We added a convenience initializer to `CIImage` that you can use to load an image by its name from an asset catalog or from a bundle directly:
```swift
let image = CIImage(named: "myImage")
```

This provides the same signature as the corresponding `UIImage` method:
```swift
// on iOS, Catalyst, tvOS
init?(named name: String, in bundle: Bundle? = nil, compatibleWith traitCollection: UITraitCollection? = nil)

// on macOS
init?(named name: String, in bundle: Bundle? = nil)
```

## Images with Fixed Values
In Core Image, you can use the `init(color: CIColor)` initializer of `CIImage` to create an image with infinite extent that only contains pixels with the given color. This, however, only allows the creation of images filled with values in [0…1] since `CIColor` clamps values to this range.

We added two new factory methods on `CIImage` that allow the creation of images filled with arbitrary values:
```swift
/// Returns a `CIImage` with infinite extent only containing the given pixel value.
static func containing(values: CIVector) -> CIImage?

/// Returns a `CIImage` with infinite extent only containing the given value in RGB and alpha 1.
/// So `CIImage.containing(42.3)` would result in an image containing the value (42.3, 42.3, 42.3, 1.0) in each pixel.
static func containing(value: Double) -> CIImage?
```

This is useful, for instance, for passing scalar values into blend filters. For instance, this would create a color inversion effect in RGB:
```swift
var inverted = CIBlendKernel.multiply.apply(foreground: image, background: CIImage.containing(value: -1)!)!
inverted = CIBlendKernel.componentAdd.apply(foreground: inverted, background: CIImage.containing(value: 1)!)!
```

## Image Value Access
It can be rather complicated to access the actual pixel values of a `CIImage`. The image needs to be rendered first and the resulting bitmap memory needs to be accessed properly.

We added some convenience methods to `CIContext` to do just that in a one-liner:
```swift
// get all pixel values of `image` as an array of `SIMD4<UInt8>` values:
let values = context.readUInt8PixelValues(from: image, in: image.extent)
let red: UInt8 = values[42].r // for instance

// get the value of a specific pixel as a `SIMD4<Float32>`:
let value = context.readFloat32PixelValue(from: image, at: CGPoint.zero)
let green: Float32 = value.g // for instance
```

These methods come in variants for accessing an area of pixels (in a given `CGRect`) or single pixels (at a given `CGPoint`).
They are also available for three different data types: `UInt8` (the normal 8-bit per channel format, with [0…255] range), `Float32` (aka `float` containing arbitrary values, but colors are usually mapped to [0...1]), and `Float16` (only on iOS).

> **_Note:_**
> Also available as `async` versions.

## OpenEXR Support
[OpenEXR](https://en.wikipedia.org/wiki/OpenEXR) is an open standard for storing arbitrary bitmap data that exceed “normal” image color data, like 32-bit high-dynamic range data or negative floating point values (for instance for height fields).

Although Image I/O has native support for the EXR format, Core Image doesn’t provide convenience ways for rendering a `CIImage` into EXR.
We added corresponding methods to `CIContext` for EXR export that align with the API provided for the other file formats:
```swift
// to create a `Data` object containing a 16-bit float EXR representation:
let exrData = try context.exrRepresentation(of: image, format: .RGBAh)

// to write a 32-bit float representation to an EXR file at `url`:
try context.writeEXRRepresentation(of: image, to: url, format: .RGBAf)
```

For reading EXR files into a `CIImage`, the usual initializers like `CIImage(contentsOf: url)` or `CIImage(named: “myImage.exr”` (see above) can be used.

> **_Note:_**
> Also available as `async` versions.

### OpenEXR Test Images
All EXR test images used in this project have been taken from [here](https://github.com/AcademySoftwareFoundation/openexr-images/).

## Image Transformations
We added some convenience methods to `CIImage` to do common affine transformations on an image in a one-liner (instead of working with `CGAffineTransform`):
```swift
// Scaling the image by the given factors in x- and y-direction.
let scaledImage = image.scaledBy(x: 0.5, y: 2.0)
// Translating the image within the working space by the given amount in x- and y-direction.
let translatedImage = image.translatedBy(dx: 42, dy: -321)
// Moving the image's origin within the working space to the given point.
let movedImage = image.moved(to: CGPoint(x: 50, y: 100))
// Moving the center of the image's extent to the given point.
let centeredImage = image.centered(in: .zero)
// Adding a padding of clear pixels around the image, effectively increasing its virtual extent.
let paddedImage = image.paddedBy(dx: 20, dy: 60)
```

You can also add rounded (transparent) corners to an image like this:
```swift
let imageWithRoundedCorners = image.withRoundedCorners(radius: 5)
```

## Image Composition
We added convenience APIs for compositing two images using different blend kernels (not just `sourceOver`, as in the built-in `CIImage.composited(over:)` API):
```swift
// Compositing the image over the specified background image using the given blend kernel.
let composition = image.composited(over: otherImage, using: .multiply)
// Compositing the image over the specified background image using the given blend kernel in the given color space.
let composition = image.composited(over: otherImage, using: .softLight, colorSpace: .displayP3ColorSpace)
```

You can also easily colorize an image (i.e., turn all visible pixels into the given color) like this:
```swift
// Colorizes visible pixels of the image in the given CIColor.
let colorized = image.colorized(with: .red)
```

## Color Extensions
`CIColor`s usually clamp their component values to `[0...1]`, which is impractical when working with wide gamut and/or extended dynamic range (EDR) colors.
One can work around that by initializing the color with an extended color space that allows component values outside of those bounds.
We added some convenient extensions for initializing colors with (extended) white and color values. Extended colors will be defined in linear sRGB, meaning a value of `1.0` will match the maximum component value in sRGB. Everything beyond is considered wide gamut.
```swift
// Convenience initializer for standard linear sRGB 50% gray.
let gray = CIColor(white: 0.5)
// A bright EDR white, way outside of the standard sRGB range.
let brightWhite = CIColor(extendedWhite: 2.0)
// A bright red color, way outside of the standard sRGB range.
// It will likely be clipped to the maximum value of the target color space when rendering.
let brightRed = CIColor(extendedRed: 2.0, green: 0.0, blue: 0.0)
``` 

We also added a convenience property to get a contrast color (either black or white) that is clearly visible when overlayed over the current color.
This can be used, for instance, to colorize text label overlays.
```swift
// A color that provide a high contrast to `backgroundColor`.
let labelColor = backgroundColor.contrastColor
```

## Color Space Convenience
A `CGColorSpace` is usually initialized by its name like this `CGColorSpace(name: CGColorSpace.extendedLinearSRGB)`.
This this is rather long, we added some static accessors for the most common color spaces used when working with Core Image for convenience:
```swift
CGColorSpace.sRGBColorSpace
CGColorSpace.extendedLinearSRGBColorSpace
CGColorSpace.displayP3ColorSpace
CGColorSpace.extendedLinearDisplayP3ColorSpace
CGColorSpace.itur2020ColorSpace
CGColorSpace.extendedLinearITUR2020ColorSpace
CGColorSpace.itur2100HLGColorSpace
CGColorSpace.itur2100PQColorSpace
```

These can be nicely used inline like this:
```swift
let color = CIColor(red: 1.0, green: 0.5, blue: 0.0, colorSpace: .displayP3ColorSpace)
``` 

## Text Generation
Core Image can generate images that contain text using `CITextImageGenerator` and `CIAttributedTextImageGenerator`.
We added extensions to make them much more convenient to use:
```swift
// Generating a text image with default settings.
let textImage = CIImage.text("This is text")
// Generating a text image with adjust text settings.
let textImage = CIImage.text("This is text", fontName: "Arial", fontSize: 24, color: .white, padding: 10)
// Generating a text image with a `UIFont` or `NSFont`.
let textImage = CIImage.text("This is text", font: someFont, color: .red, padding: 42)
// Generating a text image with an attributed string.
let attributedTextImage = CIImage.attributedText(someAttributedString, padding: 10)
```

## Runtime Kernel Compilation from Metal Sources
With the legacy Core Image Kernel Language it was possible (and even required) to compile custom kernel routines at runtime from CIKL source strings.
For custom kernels written in Metal the sources needed to be compiled (with specific flags) together with the rest of the sources at build-time.
While this has the huge benefits of compile-time source checking and huge performance improvements at runtime, it also looses some flexibility.
Most notably when it comes to prototyping, since setting up the Core Image Metal build toolchain is rather complicated and loading pre-compiled kernels require some boilerplate code.

New in iOS 15 and macOS 12, however, is the ability to also compile Metal-based kernels at runtime using the `CIKernel.kernels(withMetalString:)` API.
However, this API requires some type checking and boilerplate code to retrieve an actual `CIKernel` instance of an appropriate type.
So we added the following convenience API to ease the process:
```swift
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
// Load the first kernel that matches the type (CIKernel) from the metal sources.
let generalKernel = try CIKernel.kernel(withMetalString: metalKernelCode) // loads "general" kernel function
// Load the kernel with a specific function name.
let otherGeneralKernel = try CIKernel.kernel(withMetalString: metalKernelCode, kernelName: "otherGeneral")
// Load the first color kernel from the metal sources.
let colorKernel = try CIColorKernel.kernel(withMetalString: metalKernelCode) // loads "color" kernel function
// Load the first warp kernel from the metal sources.
let colorKernel = try CIWarp.kernel(withMetalString: metalKernelCode) // loads "warp" kernel function
```

**⚠️ _Important:_**
There are a few limitations to this API:
- Run-time compilation of Metal kernels is only supported starting from iOS 15 and macOS 12.
- It only works when the Metal kernels are attributed as `[[ stitchable ]]`.
  Please refer to [this WWDC talk](https://developer.apple.com/wwdc21/10159) for details.
- It only works when the Metal device used by Core Image supports dynamic libraries.
  You can check `MTLDevice.supportsDynamicLibraries` to see if runtime compilation of Metal-based CIKernels is supported.
- `CIBlendKernel` can't be compiled this way, unfortunately. The `CIKernel.kernels(withMetalString:)` API just identifies them as `CIColorKernel`

If your minimum deployment target doesn't yet support runtime compilation of Metal kernels, you can use the following API instead.
It allows to provide a backup kernel implementation in CIKL what is used on older system where Metal runtime compilation is not supported:
```swift
let metalKernelCode = """
    #include <CoreImage/CoreImage.h>
    using namespace metal;

    [[ stitchable ]] half4 general(coreimage::sampler_h src) {
        return src.sample(src.coord());
    }
"""
let ciklKernelCode = """
    kernel vec4 general(sampler src) {
        return sample(src, samplerTransform(src, destCoord()));
    }
"""
let kernel = try CIKernel.kernel(withMetalString: metalKernelCode, fallbackCIKLString: ciklKernelCode)
```

> **_Note:_**
> It is generally a much better practice to compile Metal CIKernels along with the rest of your  and only use runtime compilation as an exception. 
> This way the compiler can check your sources at build-time, and initializing a CIKernel at runtime from pre-compiled sources is much faster.
> A notable exception might arise when you need a custom kernel inside a Swift package since CI Metal kernels can't be built with Swift packages (yet). 
> But this should only be used as a last resort.

## EDR & Wide Gamut Test Pattern
Most Apple devices can capture and display images with colors that are outside of the standard sRGB color gamut and range (_Standard Dynamic Range_, _SDR_).
The Display P3 color space is the de facto standard on Apple platforms now.
Some high-end devices and monitors also have XDR screens that can go even beyond Display P3, and new iPhones can record movies in HDR now.
All those systems (wide color gamut, high display brightness, extended color spaces) are subsumed by Apple under the term _EDR_ (_Extended Dynamic Range_).

To ensure that all parts of our apps can properly process and display EDR media, we designed a test pattern image that
- displays a stripe of tiles with increasing pixel brightness value (up to the XDRs peak brightness of 1600 nits) 
- and swatches of various colors in three common color gamuts (sRGB, Display P3, and BT.2020).

![EDR & Wide Gamut Test Pattern](EDR_Wide_Gamut_Test_Patterns/TestPattern_tone-mapped.png)

> **_Note:_**
> The image above is tone-mapped from HDR to SDR to demonstrate what it will roughly look like on a HDR-capable screen (just much dimmer).
> If you want to see the colors in their correct form (and see where you screen has to clip colors), check out the extended range [EXR](EDR_Wide_Gamut_Test_Patterns/TestPattern_16bit_float_extended-linear-sRGB.exr?raw=true) or [TIFF](EDR_Wide_Gamut_Test_Patterns/TestPattern_16bit_float_extended-linear-sRGB.tiff?raw=true) version of the image.
> The tone-mapped PNG version above was chosen so you can better see the intent of the pattern.

The pattern image itself is generated with Core Image compositing techniques.
You can generate it as `CIImage` just like this:
```swift
let testPattern = CIImage.testPattern()
```

> **_Note:_**
> You should use this for testing purposes only! 
> This is not meant to be shipped in production code since generating the pattern is slow and potentially error-prone (lots of force-unwraps in the code for convenience).
> If you need a fast-loading version of it, best use the pre-generated [EXR version](EDR_Wide_Gamut_Test_Patterns/TestPattern_16bit_float_extended-linear-sRGB.exr?raw=true).

You can find many pre-generated test pattern images in various file formats, bit depths, and color spaces in the [EDR_Wide_Gamut_Test_Patterns](EDR_Wide_Gamut_Test_Patterns/) folder for download.
Those images can also be generated using the `TestPatternTests`.
The generated images are attached to the test runs and can be found when opening the test result in the Reports navigator.
