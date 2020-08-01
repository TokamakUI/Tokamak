# Providing platform-specific primitives

Primitive `Views`, such as `Text`, `Button`, `HStack`, etc. have a body type of `Never`. When the `StackReconciler` goes to render these `Views`, it expects your `Renderer` to provide a body.

This is done via the `ViewDeferredToRenderer` protocol. There we can provide a `View` that our `Renderer` understands. For instance, `TokamakDOM` (and `TokamakStaticHTML` by extension) use the `HTML` view. Let’s look at a simpler version of this view:

```swift
protocol AnyHTML {
  let tag: String
  let attributes: [String:String]
  let innerHTML: String
}

struct HTML: View, AnyHTML {
  let tag: String
  let attributes: [String:String]
  let innerHTML: String
  var body: Never {
    neverBody("HTML")
  }
}
```

Here we define an `HTML` view to have a body type of `Never`, like other primitive `Views`. It also conforms to `AnyHTML`, which allows our `Renderer` to access the attributes of the `HTML` without worrying about the `associatedtypes` involved with `View`.

## `ViewDeferredToRenderer`

Now we can use `HTML` to override the body of the primitive `Views` provided by `TokamakCore`:

```swift
extension Text: ViewDeferredToRenderer {
  var deferredBody: AnyView {
    AnyView(HTML("span", [:], _TextProxy(self).rawText))
  }
}
```

If you recall, our `Renderer` mapped the `AnyView` received from the reconciler to `AnyHTML`:

```swift
// 1.
guard let html = mapAnyView(
  host.view,
  transform: { (html: AnyHTML) in html }
) else { ... }
```

Then we were able to access the properties of the HTML.

## Proxies

Proxies allow access to internal properties of views implemented by `TokamakCore`. For instance, to access the storage of the `Text` view, we were required to use a `_TextProxy`.

Proxies contain all of the properties of the primitive necessary to build your platform-specific implementation.
