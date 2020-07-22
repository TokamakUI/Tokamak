# Understanding `Renderers`
So, what goes into a `Renderer`?

1. A `Target` - Targets are the destination for rendered `Views`. For instance, on iOS this is `UIView`, on macOS an `NSView`, and on the web we render to DOM nodes.
2. A `StackReconciler` - The reconciler does all the heavy lifting to understand the view tree. It notifies your `Renderer` of what views need to be mounted/unmounted.
3. `func mountTarget`- This function is called when a new target instance should be created and added to the parent (either as a subview or some other way, e.g. installed if it’s a layout constraint).
4. `func update` - This function is called when an existing target instance should be updated (e.g. when `State` changes).
5. `func unmount` - This function is called when an existing target instance should be unmounted: removed from the parent and most likely destroyed.

That’s it! Let’s get our project setup.
