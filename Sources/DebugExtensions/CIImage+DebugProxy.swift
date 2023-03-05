#if DEBUG
import CoreImage


public extension CIImage {

    /// A proxy object that wraps an `CIImage` and allows to call various methods
    /// for debugging and introspection of that image.
    struct DebugProxy {
        let image: CIImage
        let context: CIContext

        init(image: CIImage, context: CIContext? = nil) {
            self.image = image
            // If no context was given, the internal singleton context that Apple uses
            // when generating debugging artifacts.
            self.context = context ?? (CIContext.value(forKey: "_singletonContext") as? CIContext) ?? CIContext()
        }
    }


    /// Creates a `DebugProxy` object that allows to call various methods
    /// for debugging and introspection of the receiver.
    /// - Parameter context: The context that is used when rendering the image during debugging
    ///                      tasks. If none was given, the internal singleton context that Apple
    ///                      uses when generating debugging artifacts is used.
    /// - Returns: A `DebugProxy` wrapping the receiver.
    func debug(with context: CIContext? = nil) -> DebugProxy {
        DebugProxy(image: self, context: context)
    }

    /// Creates a `DebugProxy` object that allows to call various methods
    /// for debugging and introspection of the receiver.
    /// It will use the internal singleton `CIContext` that Apple uses when generating debug artifacts.
    var debug: DebugProxy { self.debug() }

}

#endif
