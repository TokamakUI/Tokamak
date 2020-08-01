# `TokamakStaticHTML` Setup

Every `Renderer` can choose what `Views`, `ViewModifiers`, property wrappers, etc. are available to use. A `Core.swift` file is used to reexport these symbols. For `TokamakStaticHTML`, we’ll use the following `Core.swift` file:

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
