// Copyright 2018-2020 Tokamak contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Created by Max Desiatov on 02/12/2018.
//

/// A control that performs an action when triggered.
///
/// Available when `Label` conforms to `View`.
///
/// A button is created using a `Label`; the `action` initializer argument (a method or closure)
/// is to be called on click.
///
///     @State private var counter: Int = 0
///     var body: some View {
///       Button(action: { counter += 1 }) {
///         Text("\(counter)")
///       }
///     }
///
/// When your label is `Text`, you can create the button by directly passing a `String`:
///
///     @State private var counter: Int = 0
///     var body: some View {
///       Button("\(counter)", action: { counter += 1 })
///     }
public struct Button<Label>: View where Label: View {
  let label: Label
  let action: () -> ()
  let role: ButtonRole?

  @Environment(\.buttonStyle)
  var buttonStyle

  public init(action: @escaping () -> (), @ViewBuilder label: () -> Label) {
    self.init(role: nil, action: action, label: label)
  }

  @_spi(TokamakCore)
  public var body: some View {
    switch buttonStyle {
    case let .primitiveButtonStyle(style):
      style.makeBody(configuration: .init(
        role: role, label: .init(body: AnyView(label)),
        action: action
      ))
    case let .buttonStyle(style):
      _Button(
        label: label,
        role: role,
        action: action,
        anyStyle: style
      )
    }
  }
}

public struct _PrimitiveButtonStyleBody<Label>: View where Label: View {
  public let label: Label
  public let role: ButtonRole?
  public let action: () -> ()

  let anyStyle: AnyPrimitiveButtonStyle
  public var style: Any.Type { anyStyle.type }

  init<S: PrimitiveButtonStyle>(
    style: S,
    configuration: PrimitiveButtonStyleConfiguration,
    @ViewBuilder label: () -> Label
  ) {
    role = configuration.role
    action = configuration.action
    self.label = label()
    anyStyle = .init(style)
  }

  @Environment(\.controlSize)
  public var controlSize

  public var body: Never {
    neverBody("_PrimitiveButtonStyleBody")
  }

  public func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
    visitor.visit(label)
  }
}

public struct _Button<Label>: View where Label: View {
  public let label: Label
  public let role: ButtonRole?
  public let action: () -> ()

  @State
  public var isPressed = false

  let anyStyle: AnyButtonStyle
  public var style: Any.Type { anyStyle.type }
  public func makeStyleBody() -> some View {
    anyStyle.makeBody(
      configuration: .init(
        role: role,
        label: .init(body: AnyView(label)),
        isPressed: isPressed
      )
    )
  }

  public var body: some View {
    makeStyleBody()
  }
}

public extension Button where Label == Text {
  init<S>(_ title: S, action: @escaping () -> ()) where S: StringProtocol {
    self.init(title, role: nil, action: action)
  }
}

public extension Button {
  init(
    role: ButtonRole?,
    action: @escaping () -> (),
    @ViewBuilder label: () -> Label
  ) {
    self.label = label()
    self.action = action
    self.role = role
  }
}

public extension Button where Label == Text {
  init<S>(
    _ title: S,
    role: ButtonRole?,
    action: @escaping () -> ()
  ) where S: StringProtocol {
    label = Text(title)
    self.action = action
    self.role = role
  }
}
