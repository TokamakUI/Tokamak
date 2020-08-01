# `Renderers` in Tokamak

Tokamak is a flexible library. `TokamakCore` provides the SwiftUI-API, which your `Renderer` can use to construct a representation of `Views` that your platform understands.

To explain the creation of `Renderers`, we’ll be creating a simple one: `TokamakStaticHTML` (which you can find in the `Tokamak` repository).

Before we create the `Renderer`, we need to understand the requirements of our platform:

1. Stateful apps cannot be created
   This simplifies the scope of our project, as we only have to render once. However, if you are building a `Renderer` that supports state changes, the process is largely the same. `TokamakCore`’s `StackReconciler` will let your `Renderer` know when a `View` has to be redrawn.
2. HTML should be rendered
   `TokamakDOM` provides HTML representations of many `Views`, so we can utilize it. However, we will cover how to provide custom `View` bodies your `Renderer` can understand, and when you are required to do so.

And that’s it! In the next part we’ll go more in depth on `Renderers`.
