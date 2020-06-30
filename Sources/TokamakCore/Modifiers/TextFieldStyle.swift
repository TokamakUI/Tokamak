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

public protocol TextFieldStyle {
  // FIXME: Should properties be internal?
  var type: String { get }
  var style: String { get }
  init()
}

public struct DefaultTextFieldStyle: TextFieldStyle {
  public init() {}
  public let type = "text"
  public let style = """
      -webkit-appearance: textfield;
      appearance: textfield;
  """
}

public struct PlainTextFieldStyle: TextFieldStyle {
  public init() {}
  public let type = "text"
  public let style = """
      background: transparent;
      border: none;
  """
}

public struct RoundedBorderTextFieldStyle: TextFieldStyle {
  public init() {}
  public let type = "search"
  public let style = """
      -webkit-appearance: searchfield;
      appearance: searchfield;
  """
}

public struct SquareBorderTextFieldStyle: TextFieldStyle {
  public init() {}
  public let type = "text"
  public let style = """
      -webkit-appearance: textfield;
      appearance: textfield;
  """
}

public struct _TextFieldStyle: ViewModifier {
  public var style: TextFieldStyle

  public init(style: TextFieldStyle) {
    self.style = style
  }

  public func body(content: Content) -> some View {
    content
  }
}

extension TextField where Label == Text {
  // FIXME: should be internal
  public func textFieldStyle(_ style: TextFieldStyle) -> Self {
    TextField(_from: self, textFieldStyle: style)
  }
}
