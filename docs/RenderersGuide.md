# `Renderers` in Tokamak

**Author: [@carson-katri](https://github.com/carson-katri)**

Tokamak is a flexible library. `TokamakCore` provides the SwiftUI API, which your `Renderer` can use
to construct a representation of `Views` that your platform understands.

To explain the creation of `Renderers`, we’ll be creating a simple one: `TokamakStaticHTML` (which
you can find in the `Tokamak` repository).

Before we create the `Renderer`, we need to understand the requirements of our platform:

1. Stateful apps cannot be created. This simplifies the scope of our project, as we only have to
   render once. However, if you are building a `Renderer` that supports state changes, the process
   is largely the same. `TokamakCore`’s `StackReconciler` will let your `Renderer` know when a
   `View` has to be redrawn.
2. HTML should be rendered. `TokamakDOM` provides HTML representations of many `Views`, so we can
   utilize it. However, we will cover how to provide custom `View` bodies your `Renderer` can
   understand, and when you are required to do so.

And that’s it! In the next part we’ll go more in depth on `Renderers`.

## Understanding `Renderers`

So, what goes into a `Renderer`?

1. A `Target` - Targets are the destination for rendered `Views`. For instance, on iOS this is
   `UIView`, on macOS an `NSView`, and on the web we render to DOM nodes.
2. A `StackReconciler` - The reconciler does all the heavy lifting to understand the view tree. It
   notifies your `Renderer` of what views need to be mounted/unmounted.
3. `func mountTarget`- This function is called when a new target instance should be created and
   added to the parent (either as a subview or some other way, e.g. installed if it’s a layout
   constraint).
4. `func update` - This function is called when an existing target instance should be updated (e.g.
   when `State` changes).
5. `func unmount` - This function is called when an existing target instance should be unmounted:
   removed from the parent and most likely destroyed.

That’s it! Let’s get our project set up.

## `TokamakStaticHTML` Setup

Every `Renderer` can choose what `Views`, `ViewModifiers`, property wrappers, etc. are available to
use. A `Core.swift` file is used to re-export these symbols. For `TokamakStaticHTML`, we’ll use the
following `Core.swift` file:

```swift
import TokamakCore

// MARK: Environment & State

public typealias Environment = TokamakCore.Environment

// MARK: Modifiers & Styles

public typealias ViewModifier = TokamakCore.ViewModifier
public typealias ModifiedContent = TokamakCore.ModifiedContent

public typealias DefaultListStyle = TokamakCore.DefaultListStyle
public typealias PlainListStyle = TokamakCore.PlainListStyle
public typealias InsetListStyle = TokamakCore.InsetListStyle
public typealias GroupedListStyle = TokamakCore.GroupedListStyle
public typealias InsetGroupedListStyle = TokamakCore.InsetGroupedListStyle

// MARK: Shapes

public typealias Shape = TokamakCore.Shape

public typealias Capsule = TokamakCore.Capsule
public typealias Circle = TokamakCore.Circle
public typealias Ellipse = TokamakCore.Ellipse
public typealias Path = TokamakCore.Path
public typealias Rectangle = TokamakCore.Rectangle
public typealias RoundedRectangle = TokamakCore.RoundedRectangle

// MARK: Primitive values

public typealias Color = TokamakCore.Color
public typealias Font = TokamakCore.Font

public typealias CGAffineTransform = TokamakCore.CGAffineTransform
public typealias CGPoint = TokamakCore.CGPoint
public typealias CGRect = TokamakCore.CGRect
public typealias CGSize = TokamakCore.CGSize

// MARK: Views

public typealias Divider = TokamakCore.Divider
public typealias ForEach = TokamakCore.ForEach
public typealias GridItem = TokamakCore.GridItem
public typealias Group = TokamakCore.Group
public typealias HStack = TokamakCore.HStack
public typealias LazyHGrid = TokamakCore.LazyHGrid
public typealias LazyVGrid = TokamakCore.LazyVGrid
public typealias List = TokamakCore.List
public typealias ScrollView = TokamakCore.ScrollView
public typealias Section = TokamakCore.Section
public typealias Spacer = TokamakCore.Spacer
public typealias Text = TokamakCore.Text
public typealias VStack = TokamakCore.VStack
public typealias ZStack = TokamakCore.ZStack

// MARK: Special Views

public typealias View = TokamakCore.View
public typealias AnyView = TokamakCore.AnyView
public typealias EmptyView = TokamakCore.EmptyView

// MARK: Misc

// Note: This extension is required to support concatenation of `Text`.
extension Text {
  public static func + (lhs: Self, rhs: Self) -> Self {
    _concatenating(lhs: lhs, rhs: rhs)
  }
}

```

We’ve omitted any stateful `Views`, as well as property wrappers used to modify state.

## Building the `Target`

If you recall, we defined a `Target` as:

> the destination for rendered `Views`

In `TokamakStaticHTML`, this would be a tag in an `HTML` file. A tag has several properties,
although we don’t need to worry about all of them. For now, we can consider a tag to have:

- The HTML for the tag itself (outer HTML)
- Child tags (inner HTML)

We can describe our target simply:

```swift
public final class HTMLTarget: Target {
  var html: AnyHTML
  var children: [HTMLTarget] = []

  init<V: View>(_ view: V,
                _ html: AnyHTML) {
    self.html = html
    super.init(view)
  }
}
```

`AnyHTML` type is coming from `TokamakDOM`, which you can declare as a dependency. The target stores
the `View` it hosts, the `HTML` that represents it, and its child elements.

Lastly, we can also provide an HTML string representation of the target:

```swift
extension HTMLTarget {
  var outerHTML: String {
    """
    <\(html.tag)\(html.attributes.isEmpty ? "" : " ")\
    \(html.attributes.map { #"\#($0)="\#($1)""# }.joined(separator: " "))>\
    \(html.innerHTML ?? "")\
    \(children.map(\.outerHTML).joined(separator: "\n"))\
    </\(html.tag)>
    """
  }
}
```

## Building the `Renderer`

Now that we have a `Target`, we can start the `Renderer`:

```swift
public final class StaticHTMLRenderer: Renderer {
  public private(set) var reconciler: StackReconciler<StaticHTMLRenderer>?
  var rootTarget: HTMLTarget

  public var html: String {
    """
    <html>
    \(rootTarget.outerHTML)
    </html>
    """
  }
}
```

We start by declaring the `StackReconciler`. It will handle the app, while our `Renderer` can focus
on mounting and un-mounting `Views`.

```swift
...
public init<V: View>(_ view: V) {
  rootTarget = HTMLTarget(view, HTMLBody())
  reconciler = StackReconciler(
    view: view,
    target: rootTarget,
    renderer: self,
    environment: EnvironmentValues()
  ) { closure in
    fatalError("Stateful apps cannot be created with TokamakStaticHTML")
  }
}
```

Next we declare an initializer that takes a `View` and builds a reconciler. The reconciler takes the
`View`, our root `Target` (in this case, `HTMLBody`), the renderer (`self`), and any default
`EnvironmentValues` we may need to setup. The closure at the end is the scheduler. It tells the
reconciler when it can update. In this case, we won’t need to update, so we can crash.

`HTMLBody` is declared like so:

```swift
struct HTMLBody: AnyHTML {
  let tag: String = "body"
  let innerHTML: String? = nil
  let attributes: [String : String] = [:]
  let listeners: [String : Listener] = [:]
}
```

### Mounting

Now that we have a reconciler, we need to be able to mount the `HTMLTargets` it asks for.

```swift
public func mountTarget(to parent: HTMLTarget, with host: MountedHost) -> HTMLTarget? {
  // 1.
  guard let html = mapAnyView(
    host.view,
    transform: { (html: AnyHTML) in html }
  ) else {
    // 2.
    if mapAnyView(host.view, transform: { (view: ParentView) in view }) != nil {
      return parent
    }

    return nil
  }

  // 3.
  let node = HTMLTarget(host.view, html)
  parent.children.append(node)
  return node
}}
```

1. We use the `mapAnyView` function to convert the `AnyView` passed in to `AnyHTML`, which can be
   used with our `HTMLTarget`.
2. `ParentView` is a special type of `View` in Tokamak. It indicates that the view has no
   representation itself, and is purely a container for children (e.g. `ForEach` or `Group`).
3. We create a new `HTMLTarget` for the view, assign it as a child of the parent, and return it.

The other two functions required by the `Renderer` protocol can crash, as `TokamakStaticHTML`
doesn’t support state changes:

```swift
public func update(target: HTMLTarget, with host: MountedHost) {
  fatalError("Stateful apps cannot be created with TokamakStaticHTML")
}

public func unmount(
  target: HTMLTarget,
  from parent: HTMLTarget,
  with host: MountedHost,
  completion: @escaping () -> ()
) {
  fatalError("Stateful apps cannot be created with TokamakStaticHTML")
}
```

If you are creating a `Renderer` that supports state changes, here’s a quick synopsis:

- `func update` - Mutate the `target` to match the `host`.
- `func unmount` - Remove the `target` from the `parent`, and call `completion` once it has been
  removed.

Now that we can mount, let’s give it a try:

```swift
struct ContentView : View {
  var body: some View {
    Text("Hello, world!")
  }
}

let renderer = StaticHTMLRenderer(ContentView())
print(renderer.html)
```

This spits out:

```html
<html>
  <body>
    <span style="...">Hello, world!</span>
  </body>
</html>
```

Congratulations 🎉 You successfully wrote a `Renderer`. We can’t wait to see what platforms you’ll
bring Tokamak to.

## Providing platform-specific primitives

Primitive `Views`, such as `Text`, `Button`, `HStack`, etc. have a body type of `Never`. When the
`StackReconciler` goes to render these `Views`, it expects your `Renderer` to provide a body.

This is done via a few additional functions in the `Renderer` protocol.

```swift
public protocol Renderer: AnyObject {
  // ...
  // Functions unrelated to this feature skipped for brevity.

  /** Returns a body of a given primitive view, or `nil` if `view` is not a primitive view for
   this renderer.
   */
  func primitiveBody(for view: Any) -> AnyView?

  /** Returns `true` if a given view type is a primitive view that should be deferred to this
   renderer.
   */
  func isPrimitiveView(_ type: Any.Type) -> Bool
}
```

This allows to declare a renderer-specific protocol for these views. Let's call it `HTMLPrimitive`:

```swift
public protocol HTMLPrimitive {
  var renderedBody: AnyView { get }
}
```

Then add the implementation using this protocol to your `StaticHTMLRenderer`:

```swift
public final class StaticHTMLRenderer: Renderer {
  // ...
  // Rest of the functions skipped for brevity.

  public func isPrimitiveView(_ type: Any.Type) -> Bool {
    type is HTMLPrimitive.Type
  }

  public func primitiveBody(for view: Any) -> AnyView? {
    (view as? HTMLPrimitive)?.renderedBody
  }
}
```

In a conformance to `HTMLPrimitive` we can provide a `View` that our
`Renderer` understands. For instance, `TokamakDOM` (and `TokamakStaticHTML` by extension) use the
`HTML` view. Let’s look at a simpler version of this view:

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

Here we define an `HTML` view to have a body type of `Never`, like other primitive `Views`. It also
conforms to `AnyHTML`, which allows our `Renderer` to access the attributes of the `HTML` without
worrying about the `associatedtype`s involved with `View`.

### `HTMLPrimitive`

Now we can use `HTML` to override the body of the primitive `Views` provided by `TokamakCore`:

```swift
extension Text: HTMLPrimitive {
  var renderedBody: AnyView {
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

### Proxies

Proxies allow access to internal properties of views implemented by `TokamakCore`. For instance, to
access the storage of the `Text` view, we were required to use a `_TextProxy`.

Proxies contain all of the properties of the primitive necessary to build your platform-specific
implementation.
