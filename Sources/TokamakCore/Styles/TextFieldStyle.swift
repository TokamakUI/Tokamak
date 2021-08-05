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
//  Created by Jed Fox on 06/30/2020.
//

public struct _TextFieldStyleLabel: View {
  public let body: AnyView
}

public protocol TextFieldStyle: _AnyTextFieldStyle {
  associatedtype _Body: View
  typealias _Label = _TextFieldStyleLabel
  func _body(configuration: TextField<Self._Label>) -> Self._Body
}

public struct DefaultTextFieldStyle: TextFieldStyle {
  public init() {}
  public func _body(configuration: TextField<_Label>) -> some View {
    configuration
  }
}

public struct PlainTextFieldStyle: TextFieldStyle {
  public init() {}
  public func _body(configuration: TextField<_Label>) -> some View {
    configuration
  }
}

public struct RoundedBorderTextFieldStyle: TextFieldStyle {
  public init() {}
  public func _body(configuration: TextField<_Label>) -> some View {
    configuration
  }
}

public struct SquareBorderTextFieldStyle: TextFieldStyle {
  public init() {}
  public func _body(configuration: TextField<_Label>) -> some View {
    configuration
  }
}

public protocol _AnyTextFieldStyle {
  func _anyBody(configuration: TextField<_TextFieldStyleLabel>) -> AnyView
}

public extension TextFieldStyle {
  func _anyBody(configuration: TextField<_TextFieldStyleLabel>) -> AnyView {
    .init(_body(configuration: configuration))
  }
}

enum TextFieldStyleKey: EnvironmentKey {
  static let defaultValue: _AnyTextFieldStyle = DefaultTextFieldStyle()
}

extension EnvironmentValues {
  var textFieldStyle: _AnyTextFieldStyle {
    get {
      self[TextFieldStyleKey.self]
    }
    set {
      self[TextFieldStyleKey.self] = newValue
    }
  }
}

public extension View {
  func textFieldStyle<S>(_ style: S) -> some View where S: TextFieldStyle {
    environment(\.textFieldStyle, style)
  }
}
