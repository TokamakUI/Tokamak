# Building the `Renderer`
Now that we have a `Target`, we can start the `Renderer`:

```swift
public final class StaticRenderer: Renderer {
	public private(set) var reconciler: StackReconciler<StaticRenderer>?
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

We start by declaring the `StackReconciler`. It will handle the app, while our `Renderer` can focus on mounting and un-mounting `Views`.

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
    fatalError("Stateful apps cannot be created with TokamakStatic")
  }
}
```

Next we declare an initializer that takes a `View` and builds a reconciler. The reconciler takes the `View`, our root `Target` (in this case, `HTMLBody`), the renderer (`self`), and any default `EnvironmentValues` we may need to setup. The closure at the end is the scheduler. It tells the reconciler when it can update. In this case, we won’t need to update, so we can crash.

`HTMLBody` is declared like so:
```swift
struct HTMLBody: AnyHTML {
  let tag: String = "body"
  let innerHTML: String? = nil
  let attributes: [String : String] = [:]
  let listeners: [String : Listener] = [:]
}
```

## Mounting
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

1. We use the `mapAnyView` function to convert the `AnyView` passed in to `AnyHTML`, which can be used with our `HTMLTarget`.
2. `ParentView` is a special type of `View` in Tokamak. It indicates that the view has no representation itself, and is purely a container for children (e.g. `ForEach` or `Group`).
3. We create a new `HTMLTarget` for the view, assign it as a child of the parent, and return it.

The other two functions required by the `Renderer` protocol can crash, as `TokamakStatic` doesn’t support state changes:

```swift
public func update(target: HTMLTarget, with host: MountedHost) {
  fatalError("Stateful apps cannot be created with TokamakStatic")
}

public func unmount(
  target: HTMLTarget,
  from parent: HTMLTarget,
  with host: MountedHost,
  completion: @escaping () -> ()
) {
  fatalError("Stateful apps cannot be created with TokamakStatic")
}
```

If you are creating a `Renderer` that supports state changes, here’s a quick synopsis:

* `func update` - Mutate the `target` to match the `host`.
* `func unmount` - Remove the `target` from the `parent`, and call `completion` once it has been removed.

Now that we can mount, let’s give it a try:

```swift
struct ContentView : View {
  var body: some View {
    Text("Hello, world!")
  }
}

let renderer = StaticRenderer(ContentView())
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

Congratulations 🎉 You successfully wrote a `Renderer`.  We can’t wait to see what platforms you’ll bring Tokamak to.
