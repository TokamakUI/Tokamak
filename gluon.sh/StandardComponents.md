## Views

| Gluon Component | Rendered on iOS as |
|---|---|
| [`Button`](https://github.com/MaxDesiatov/Gluon/blob/master/Sources/Gluon/Components/Host/Button.swift) | [`UIButton`](https://developer.apple.com/documentation/uikit/uibutton) |
| [`Label`](https://github.com/MaxDesiatov/Gluon/blob/master/Sources/Gluon/Components/Host/Label.swift) | [`UILabel`](https://developer.apple.com/documentation/uikit/uilabel) |
| [`ListView`](https://github.com/MaxDesiatov/Gluon/blob/master/Sources/Gluon/Components/Host/ListView.swift) | [`UITableView`](https://developer.apple.com/documentation/uikit/uitableview) |
| [`SegmentedControl`](https://github.com/MaxDesiatov/Gluon/blob/master/Sources/Gluon/Components/Host/SegmentedControl.swift) | [`UISegmentedControl`](https://developer.apple.com/documentation/uikit/uisegmentedcontrol) | 
| [`Slider`](https://github.com/MaxDesiatov/Gluon/blob/master/Sources/Gluon/Components/Host/Slider.swift) | [`UISlider`](https://developer.apple.com/documentation/uikit/uislider) |
| [`StackView`](https://github.com/MaxDesiatov/Gluon/blob/master/Sources/Gluon/Components/Host/StackView.swift) | [`UIStackView`](https://developer.apple.com/documentation/uikit/uistackview) |
| [`Stepper`](https://github.com/MaxDesiatov/Gluon/blob/master/Sources/Gluon/Components/Host/Stepper.swift) | [`UIStepper`](https://developer.apple.com/documentation/uikit/uistepper) |
| [`Switch`](https://github.com/MaxDesiatov/Gluon/blob/master/Sources/Gluon/Components/Host/Switch.swift) | [`UISwitch`](https://developer.apple.com/documentation/uikit/uiswitch) |
| [`View`](https://github.com/MaxDesiatov/Gluon/blob/master/Sources/Gluon/Components/Host/View.swift) | [`UIView`](https://developer.apple.com/documentation/uikit/uiview) |

## Presenters 

| Gluon Component | Rendered on iOS as |
|---|---|
| [`ModalPresenter`](https://github.com/MaxDesiatov/Gluon/blob/master/Sources/Gluon/Components/Presenters/ModalPresenter.swift) | [`UIViewController`](https://developer.apple.com/documentation/uikit/uiviewcontroller) with modal presentation|
| [`StackPresenter`](https://github.com/MaxDesiatov/Gluon/blob/master/Sources/Gluon/Components/Presenters/StackPresenter.swift) | [`UINavigationController`](https://developer.apple.com/documentation/uikit/uinavigationcontroller) |
| [`TabPresenter`](https://github.com/MaxDesiatov/Gluon/blob/master/Sources/Gluon/Components/Presenters/TabPresenter.swift) | [`UITabController`](https://developer.apple.com/documentation/uikit/uitabcontroller) |

## Style

All of the standard components rendered to views get an optional argument
[`Style`][style]
passed to their props. It bundles all of the common styling configuration that
can be applied to view components, but is abstract from a specific renderer
implementation. Thus, even if you render to UIKit, you can use
platform-independent layout structs such as [`Point`, `Size`,
`Rectangle`](https://github.com/MaxDesiatov/Gluon/blob/master/Sources/Gluon/Components/Props/Rectangle.swift)
and
[`Insets`](https://github.com/MaxDesiatov/Gluon/blob/master/Sources/Gluon/Components/Props/Insets.swift),
as well as other styling configuration like
[`Color`](https://github.com/MaxDesiatov/Gluon/blob/master/Sources/Gluon/Components/Props/Color.swift)
which is mapped to
[`UIColor`](https://developer.apple.com/documentation/uikit/uicolor) for
`UIKit` and when `AppKitRenderer` is available would be mapped to
[`NSColor`](https://developer.apple.com/documentation/appkit/nscolor).

## Layout

Gluon currently supports multiple layout approaches: 

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
with [`Leading`](https://github.com/MaxDesiatov/Gluon/blob/master/Sources/Gluon/Components/Props/Constraint/Leading.swift) and [`Trailing`](https://github.com/MaxDesiatov/Gluon/blob/master/Sources/Gluon/Components/Props/Constraint/Trailing.swift) constraints.

[style]: https://github.com/MaxDesiatov/Gluon/blob/master/Sources/Gluon/Components/Props/Style.swift