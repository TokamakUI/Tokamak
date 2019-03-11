## Standard View Components

| Tokamak Component | Rendered on iOS as | Rendered on macOS as |
|---|---|---|
| [`Button`](https://github.com/MaxDesiatov/Tokamak/blob/master/Sources/Tokamak/Components/Host/Button.swift) | [`UIButton`](https://developer.apple.com/documentation/uikit/uibutton) | [`NSButton`](https://developer.apple.com/documentation/appkit/nsbutton) |
| [`CollectionView`](https://github.com/MaxDesiatov/Tokamak/blob/master/Sources/Tokamak/Components/Host/CollectionView.swift) | [`UICollectionView`](https://developer.apple.com/documentation/uikit/uicollectionview) | not available yet |
| [`DatePicker`](https://github.com/MaxDesiatov/Tokamak/blob/master/Sources/Tokamak/Components/Host/DatePicker.swift) | [`UIDatePicker`](https://developer.apple.com/documentation/uikit/uidatepicker) | not available yet |
| [`ImageView`](https://github.com/MaxDesiatov/Tokamak/blob/master/Sources/Tokamak/Components/Host/ImageView.swift) | [`UIImageView`](https://developer.apple.com/documentation/uikit/uiimageview) | not available yet |
| [`Label`](https://github.com/MaxDesiatov/Tokamak/blob/master/Sources/Tokamak/Components/Host/Label.swift) | [`UILabel`](https://developer.apple.com/documentation/uikit/uilabel) | [`NSTextView`](https://developer.apple.com/documentation/appkit/nstextview) |
| [`ListView`](https://github.com/MaxDesiatov/Tokamak/blob/master/Sources/Tokamak/Components/Host/ListView.swift) | [`UITableView`](https://developer.apple.com/documentation/uikit/uitableview) | not available yet |
| [`ScrollView`](https://github.com/MaxDesiatov/Tokamak/blob/master/Sources/Tokamak/Components/Host/ScrollView.swift) | [`UIScrollView`](https://developer.apple.com/documentation/uikit/uiscrollview) | not available yet |
| [`SegmentedControl`](https://github.com/MaxDesiatov/Tokamak/blob/master/Sources/Tokamak/Components/Host/SegmentedControl.swift) | [`UISegmentedControl`](https://developer.apple.com/documentation/uikit/uisegmentedcontrol) | not available yet |
| [`Slider`](https://github.com/MaxDesiatov/Tokamak/blob/master/Sources/Tokamak/Components/Host/Slider.swift) | [`UISlider`](https://developer.apple.com/documentation/uikit/uislider) | not available yet |
| [`StackView`](https://github.com/MaxDesiatov/Tokamak/blob/master/Sources/Tokamak/Components/Host/StackView.swift) | [`UIStackView`](https://developer.apple.com/documentation/uikit/uistackview) | not available yet |
| [`Stepper`](https://github.com/MaxDesiatov/Tokamak/blob/master/Sources/Tokamak/Components/Host/Stepper.swift) | [`UIStepper`](https://developer.apple.com/documentation/uikit/uistepper) | not available yet |
| [`Switch`](https://github.com/MaxDesiatov/Tokamak/blob/master/Sources/Tokamak/Components/Host/Switch.swift) | [`UISwitch`](https://developer.apple.com/documentation/uikit/uiswitch) | not available yet |
| [`TextField`](https://github.com/MaxDesiatov/Tokamak/blob/master/Sources/Tokamak/Components/Host/TextField.swift) | [`UITextField`](https://developer.apple.com/documentation/uikit/uitextfield) | not available yet |
| [`View`](https://github.com/MaxDesiatov/Tokamak/blob/master/Sources/Tokamak/Components/Host/View.swift) | [`UIView`](https://developer.apple.com/documentation/uikit/uiview) | [`NSView`](https://developer.apple.com/documentation/appkit/nsview) |

## Standard Presenter Components

| Tokamak Component | Rendered on iOS as |
|---|---|
| [`ModalPresenter`](https://github.com/MaxDesiatov/Tokamak/blob/master/Sources/Tokamak/Components/Presenters/ModalPresenter.swift) | [`UIViewController`](https://developer.apple.com/documentation/uikit/uiviewcontroller) with modal presentation|
| [`NavigationPresenter`](https://github.com/MaxDesiatov/Tokamak/blob/master/Sources/Tokamak/Components/Presenters/NavigationPresenter.swift) | [`UINavigationController`](https://developer.apple.com/documentation/uikit/uinavigationcontroller) |
| [`TabPresenter`](https://github.com/MaxDesiatov/Tokamak/blob/master/Sources/Tokamak/Components/Presenters/TabPresenter.swift) | [`UITabBarController`](https://developer.apple.com/documentation/uikit/uitabbarcontroller) |

## Style

All of the standard view components get an optional argument [`Style`][style]
passed to their props (except the `StackView`, which [only affects layout, but
can't be styled](https://useyourloaf.com/blog/stack-view-background-color/)). It
bundles all of the common styling configuration that can be applied to view
components, but is abstract from a specific renderer implementation. Thus, even
if you render to `UIKit` you can use platform-independent layout structs such as
[`Point`, `Size`,
`Rectangle`](https://github.com/MaxDesiatov/Tokamak/blob/master/Sources/Tokamak/Components/Props/Rectangle.swift)
and
[`Insets`](https://github.com/MaxDesiatov/Tokamak/blob/master/Sources/Tokamak/Components/Props/Insets.swift),
as well as other styling configuration. For example
[`Color`](https://github.com/MaxDesiatov/Tokamak/blob/master/Sources/Tokamak/Components/Props/Color.swift)
is mapped to
[`UIColor`](https://developer.apple.com/documentation/uikit/uicolor) for
`UIKit`, and when `AppKitRenderer` is available would be mapped to
[`NSColor`](https://developer.apple.com/documentation/appkit/nscolor).

## Layout

Tokamak currently supports multiple layout approaches: 

1. Manual frame-based layout.  You can pass precomputed layout information as
   `frame` argument to [`Style`][style] initializer, e.g.:

```swift
Label.node(.init(
  Style(
    Rectangle(
      Point.zero, 
      Size(width: 200, height: 100)
    )
  )
), "label")
```

The downside of this approach is that you have to precompute all of the layout
information yourself. It also has to be manually recomputed and updated when
layout environment changes on device rotation or when the root window is
resized. On the other hand, you're free to attach whatever layout engine you'd
like to this API. One example could be flexbox support implemented with
[Yoga](https://github.com/facebook/yoga/tree/master/YogaKit).

2. Auto layout: a DSL for location and size constraints with values that can
be passed to [`Style`][style] initializer:

```swift
Label.node(.init(
  Style([
    Size.equal(to: Size(width: 200, height: 100), 
    Top.equal(to: .parent),
    Leading.equal(to: .parent)
  ]
), "label")
```

`UIKitRenderer` maps this DSL directly to native auto layout constraints and
reconciles any updates with existing constraints created during previous
renders. This allows UI to stay responsive to any dynamic changes and also has
native support for [RTL scripts](https://en.wikipedia.org/wiki/Right-to-left)
with [`Leading`](https://github.com/MaxDesiatov/Tokamak/blob/master/Sources/Tokamak/Components/Props/Constraint/Leading.swift) and [`Trailing`](https://github.com/MaxDesiatov/Tokamak/blob/master/Sources/Tokamak/Components/Props/Constraint/Trailing.swift) constraints.

[style]: https://github.com/MaxDesiatov/Tokamak/blob/master/Sources/Tokamak/Components/Props/Style.swift