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

public protocol TextFieldStyle {}

public struct DefaultTextFieldStyle: TextFieldStyle {
  public init() {}
}

public struct PlainTextFieldStyle: TextFieldStyle {
  public init() {}
}

public struct RoundedBorderTextFieldStyle: TextFieldStyle {
  public init() {}
}

public struct SquareBorderTextFieldStyle: TextFieldStyle {
  public init() {}
}

enum TextFieldStyleKey: EnvironmentKey {
  static let defaultValue: TextFieldStyle = DefaultTextFieldStyle()
}

extension EnvironmentValues {
  var textFieldStyle: TextFieldStyle {
    get {
      self[TextFieldStyleKey.self]
    }
    set {
      self[TextFieldStyleKey.self] = newValue
    }
  }
}

public extension View {
  func textFieldStyle(_ style: TextFieldStyle) -> some View {
    environment(\.textFieldStyle, style)
  }
}
