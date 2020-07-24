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
//  Created by Gene Z. Ragan on 07/22/2020.

public struct ButtonStyleConfiguration {
  public let label: AnyView!
  public let action: () -> ()
  public var isPressed = false
}

public protocol ButtonStyle {
  associatedtype Body: View

  func makeBody(configuration: Self.Configuration) -> Self.Body

  typealias Configuration = ButtonStyleConfiguration
}

public struct AnyButtonStyle: ButtonStyle {
  public typealias Body = AnyView

  private let bodyClosure: (ButtonStyleConfiguration) -> AnyView

  public init<S: ButtonStyle>(_ style: S) {
    bodyClosure = { configuration in
      AnyView(style.makeBody(configuration: configuration))
    }
  }

  public func makeBody(configuration: ButtonStyleConfiguration) -> AnyView {
    bodyClosure(configuration)
  }
}

public enum ButtonStyleKey: EnvironmentKey {
  public static var defaultValue: AnyButtonStyle {
    fatalError("\(self) must have a renderer-provided default value")
  }
}

extension EnvironmentValues {
  var buttonStyle: AnyButtonStyle {
    get {
      self[ButtonStyleKey.self]
    }
    set {
      self[ButtonStyleKey.self] = newValue
    }
  }
}

extension View {
  public func buttonStyle<S>(_ style: S) -> some View where S: ButtonStyle {
    environment(\.buttonStyle, AnyButtonStyle(style))
  }
}
