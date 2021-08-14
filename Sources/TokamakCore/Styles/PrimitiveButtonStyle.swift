// Copyright 2020 Tokamak contributors
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
//  Created by Carson Katri on 7/12/21.
//

public protocol PrimitiveButtonStyle {
  associatedtype Body: View
  @ViewBuilder
  func makeBody(configuration: Self.Configuration) -> Self.Body
  typealias Configuration = PrimitiveButtonStyleConfiguration
}

public struct PrimitiveButtonStyleConfiguration {
  public struct Label: View {
    public let body: AnyView
  }

  public let role: ButtonRole?
  public let label: PrimitiveButtonStyleConfiguration.Label

  let action: () -> ()
  public func trigger() { action() }
}

public struct DefaultButtonStyle: PrimitiveButtonStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    BorderedButtonStyle().makeBody(configuration: configuration)
  }
}

public struct PlainButtonStyle: ButtonStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .foregroundColor(configuration.isPressed ? .secondary : .primary)
  }
}

public struct BorderedButtonStyle: PrimitiveButtonStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    _PrimitiveButtonStyleBody(style: self, configuration: configuration) {
      configuration.label
    }
  }
}

public struct BorderedProminentButtonStyle: PrimitiveButtonStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    _PrimitiveButtonStyleBody(style: self, configuration: configuration) {
      configuration.label
    }
  }
}

public struct BorderlessButtonStyle: ButtonStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .foregroundColor(configuration.isPressed ? .primary : .secondary)
  }
}

public struct LinkButtonStyle: ButtonStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    configuration.label.body
      .foregroundColor(
        configuration
          .isPressed ? Color(red: 128 / 255, green: 192 / 255, blue: 240 / 255) : .blue
      )
  }
}

struct AnyPrimitiveButtonStyle: PrimitiveButtonStyle {
  let bodyClosure: (PrimitiveButtonStyleConfiguration) -> AnyView
  let type: Any.Type

  init<S: PrimitiveButtonStyle>(_ style: S) {
    type = S.self
    bodyClosure = {
      AnyView(style.makeBody(configuration: $0))
    }
  }

  func makeBody(configuration: Self.Configuration) -> AnyView {
    bodyClosure(configuration)
  }
}

extension EnvironmentValues {
  enum ButtonStyleKey: EnvironmentKey {
    enum ButtonStyleKeyValue {
      case primitiveButtonStyle(AnyPrimitiveButtonStyle)
      case buttonStyle(AnyButtonStyle)
    }

    public static let defaultValue: ButtonStyleKeyValue = .primitiveButtonStyle(
      .init(DefaultButtonStyle())
    )
  }

  var buttonStyle: ButtonStyleKey.ButtonStyleKeyValue {
    get {
      self[ButtonStyleKey.self]
    }
    set {
      self[ButtonStyleKey.self] = newValue
    }
  }
}

public extension View {
  func buttonStyle<S>(
    _ style: S
  ) -> some View where S: PrimitiveButtonStyle {
    environment(\.buttonStyle, .primitiveButtonStyle(.init(style)))
  }

  func buttonStyle<S>(_ style: S) -> some View where S: ButtonStyle {
    environment(\.buttonStyle, .buttonStyle(.init(style)))
  }
}
