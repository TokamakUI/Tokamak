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
  public struct Label: View {
    let content: AnyView
    public var body: Never {
      neverBody("ButtonStyleConfiguration.Label")
    }
  }

  public let label: Label
  public let isPressed: Bool
}

/// This is a helper class that works around absence of "package private" access control in Swift
public struct _ButtonStyleConfigurationProxy {
  public struct Label {
    public typealias Subject = ButtonStyleConfiguration.Label
    public let subject: Subject

    public init(_ subject: Subject) { self.subject = subject }

    public var content: AnyView { subject.content }
  }

  public typealias Subject = ButtonStyleConfiguration
  public let subject: Subject

  public init(label: AnyView, isPressed: Bool) {
    subject = .init(label: .init(content: label), isPressed: isPressed)
  }

  public var label: ButtonStyleConfiguration.Label { subject.label }
}

public protocol ButtonStyle {
  associatedtype Body: View

  func makeBody(configuration: Self.Configuration) -> Self.Body

  typealias Configuration = ButtonStyleConfiguration
}

public struct _AnyButtonStyle: ButtonStyle {
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

public enum _ButtonStyleKey: EnvironmentKey {
  public static var defaultValue: _AnyButtonStyle {
    fatalError("\(self) must have a renderer-provided default value")
  }
}

extension EnvironmentValues {
  var buttonStyle: _AnyButtonStyle {
    get {
      self[_ButtonStyleKey.self]
    }
    set {
      self[_ButtonStyleKey.self] = newValue
    }
  }
}

extension View {
  public func buttonStyle<S>(_ style: S) -> some View where S: ButtonStyle {
    environment(\.buttonStyle, _AnyButtonStyle(style))
  }
}
