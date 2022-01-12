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

### OpenEXR Test Images
All EXR test images used in this project have been taken from [here](https://github.com/AcademySoftwareFoundation/openexr-images/).
