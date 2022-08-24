import CoreImage


@available(iOS 11.0, macCatalyst 13.1, macOS 10.13, tvOS 11.0, *)
public extension CIKernel {

    /// Errors that can be thrown by the Metal kernel runtime compilation APIs.
    enum MetalKernelError: Swift.Error {
        case functionNotFound(_ message: String)
        case noMatchingKernelFound(_ message: String)
        case blendKernelsNotSupported(_ message: String)
        case ciklKernelCreationFailed(_ message: String)
    }


    /// Compiles a Core Image kernel at runtime from the given Metal `source` string.
    ///
    /// ⚠️ Important: There are a few limitations to this API:
    /// - It only works when the kernels are attributed as `[[ stitchable ]]`.
    ///   Please refer to [this WWDC talk](https://developer.apple.com/wwdc21/10159) for details.
    /// - It only works when the Metal device used by Core Image supports dynamic libraries.
    ///   You can check ``MTLDevice.supportsDynamicLibraries`` to see if runtime compilation of Metal-based
    ///   CIKernels is supported.
    /// - `CIBlendKernel` can't be compiled this way, unfortunately. The ``CIKernel.kernels(withMetalString:)``
    ///   API just identifies them as `CIColorKernel`
    ///
    /// It is generally a much better practice to compile Metal CIKernels along with the rest of your sources
    /// and only use runtime compilation as an exception. This way the compiler can check your sources at
    /// build-time, and initializing a CIKernel at runtime from pre-compiled sources is much faster.
    /// A notable exception might arise when you need a custom kernel inside a Swift package since CI Metal kernels
    /// can't be built with Swift packages (yet). But this should only be used as a last resort.
    ///
    /// - Parameters:
    ///   - source: A Metal source code string that contain one or more kernel routines.
    ///   - kernelName: The name of the kernel function to use for this kernel. Use this if multiple kernels
    ///                 are defined in the source string and you want to load a specific one. Otherwise the
    ///                 first function that matches the kernel type is used.
    /// - Returns: The compiled Core Image kernel.
    @available(iOS 15.0, macCatalyst 15.0, macOS 12.0, tvOS 15.0, *)
    @objc class func kernel(withMetalString source: String, kernelName: String? = nil) throws -> Self {
        // Try to compile all kernel routines found in `source`.
        let kernels = try CIKernel.kernels(withMetalString: source)

        if let kernelName = kernelName {
            // If we were given a specific kernel function name, try to find the kernel with that name that also matches
            // the type of the CIKernel (sub-)class (`Self`).
            guard let kernel = kernels.first(where: { $0.name == kernelName }), let kernel = kernel as? Self else {
                throw MetalKernelError.functionNotFound("No matching kernel function named \"\(kernelName)\" found.")
            }
            return kernel
        } else {
            // Otherwise just return the first kernel with a matching kernel type.
            guard let kernel = kernels.compactMap({ $0 as? Self }).first else {
                throw MetalKernelError.noMatchingKernelFound("No matching kernel of type \(String(reflecting: Self.self)) found.")
            }
            return kernel
        }
    }

    /// Compiles a Core Image kernel at runtime from the given Metal `source` string.
    /// If this feature is not supported by the OS, the legacy Core Image Kernel Language `ciklSource` is used instead.
    ///
    /// ⚠️ Important: There are a few limitations to this API:
    /// - Run-time compilation of Metal kernels is only supported starting from iOS 15 and macOS 12.
    ///   If the system doesn't support this feature, the legacy Core Image Kernel Language `ciklSource` is used instead.
    ///   Note, however, that this API was deprecated with macOS 10.14 and can drop support soon.
    ///   This API is meant to be used as a temporary solution for when older OSes than iOS 15 and macOS 12 still need to be supported.
    /// - It only works when the Metal kernels are attributed as `[[ stitchable ]]`.
    ///   Please refer to [this WWDC talk](https://developer.apple.com/wwdc21/10159) for details.
    /// - It only works when the Metal device used by Core Image supports dynamic libraries.
    ///   You can check ``MTLDevice.supportsDynamicLibraries`` to see if runtime compilation of Metal-based
    ///   CIKernels is supported.
    /// - `CIBlendKernel` can't be compiled this way, unfortunately. The ``CIKernel.kernels(withMetalString:)``
    ///   API just identifies them as `CIColorKernel`
    ///
    /// It is generally a much better practice to compile Metal CIKernels along with the rest of your sources
    /// and only use runtime compilation as an exception. This way the compiler can check your sources at
    /// build-time, and initializing a CIKernel at runtime from pre-compiled sources is much faster.
    /// A notable exception might arise when you need a custom kernel inside a Swift package since CI Metal kernels
    /// can't be built with Swift packages (yet). But this should only be used as a last resort.
    ///
    /// - Parameters:
    ///   - source: A Metal source code string that contain one or more kernel routines.
    ///   - metalKernelName: The name of the kernel function to use for this kernel. Use this if multiple kernels
    ///                      are defined in the source string and you want to load a specific one. Otherwise the
    ///                      first function that matches the kernel type is used.
    ///   - fallbackCIKLString: The kernel code in the legacy Core Image Kernel Language that is used as a fallback
    ///                         option on older OSes.
    /// - Returns: The compiled Core Image kernel.
    @objc class func kernel(withMetalString metalSource: String, metalKernelName: String? = nil, fallbackCIKLString ciklSource: String) throws -> Self {
        if #available(iOS 15.0, macCatalyst 15.0, macOS 12.0, tvOS 15.0, *) {
            return try self.kernel(withMetalString: metalSource, kernelName: metalKernelName)
        } else {
            guard let fallbackKernel = self.init(source: ciklSource) else {
                throw MetalKernelError.ciklKernelCreationFailed("Failed to create fallback kernel from CIKL source string.")
            }
            return fallbackKernel
        }
    }

}

@available(iOS 11.0, macCatalyst 13.1, macOS 10.13, tvOS 11.0, *)
public extension CIBlendKernel {

    /// ⚠️ `CIBlendKernel` can't be compiled from Metal sources at runtime at the moment.
    /// Please see ``CIKernel.kernel(withMetalString:kernelName:)`` for details.
    /// You can still compile them using the legacy Core Image Kernel Language and the ``CIBlendKernel.init?(source:)`` API, though.
    @available(iOS, unavailable)
    @available(macCatalyst, unavailable)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @objc override class func kernel(withMetalString source: String, kernelName: String? = nil) throws -> Self {
        throw MetalKernelError.blendKernelsNotSupported("CIBlendKernels can't be initialized with a Metal source string at runtime. Compile them at built-time instead.")
    }

    /// ⚠️ `CIBlendKernel` can't be compiled from Metal sources at runtime at the moment.
    /// Please see ``CIKernel.kernel(withMetalString:metalKernelName:fallbackCIKLString:)`` for details.
    /// You can still compile them using the legacy Core Image Kernel Language and the ``CIBlendKernel.init?(source:)`` API, though.
    @available(iOS, unavailable)
    @available(macCatalyst, unavailable)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @objc override class func kernel(withMetalString metalSource: String, metalKernelName: String? = nil, fallbackCIKLString ciklSource: String) throws -> Self {
        throw MetalKernelError.blendKernelsNotSupported("CIBlendKernels can't be initialized with a Metal source string at runtime. Compile them at built-time instead.")
    }

}
