# Building the `Target`
If you recall, we defined a `Target` as:

> the destination for rendered `Views`

In `TokamakStatic`, this would be a tag in an `HTML` file. A tag has several properties, although we don’t need to worry about all of them. For now, we can consider a tag to have:

* The HTML for the tag itself (outer HTML)
* Child tags (inner HTML)

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

`AnyHTML` is from `TokamakDOM`, which you can declare as a dependency. The target stores the `View` it hosts, the `HTML` that represents it, and its child elements.

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
