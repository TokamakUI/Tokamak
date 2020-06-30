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
//  Created by Jed Fox on 06/28/2020.
//

public struct TextField<Label>: View where Label: View {
  let label: Label
  let textBinding: Binding<String>
  let onEditingChanged: (Bool) -> ()
  let onCommit: () -> ()
  let textFieldStyle: TextFieldStyle

  public var body: Never {
    neverBody("TextField")
  }
}

extension TextField where Label == Text {
  public init<S>(
    _ title: S, text: Binding<String>,
    onEditingChanged: @escaping (Bool) -> () = { _ in },
    onCommit: @escaping () -> () = {}
  ) where S: StringProtocol {
    label = Text(title)
    textBinding = text
    self.onEditingChanged = onEditingChanged
    self.onCommit = onCommit
    textFieldStyle = DefaultTextFieldStyle()
  }

  init(
    _from textField: TextField,
    textFieldStyle: TextFieldStyle
  ) {
    label = textField.label
    textBinding = textField.textBinding
    onEditingChanged = textField.onEditingChanged
    onCommit = textField.onCommit
    self.textFieldStyle = textFieldStyle
  }

  // FIXME: implement this method, which uses a Formatter to control the value of the TextField
  // public init<S, T>(
  //     _ title: S, value: Binding<T>, formatter: Formatter,
  //     onEditingChanged: @escaping (Bool) -> Void = { _ in },
  //     onCommit: @escaping () -> Void = {}
  // ) where S : StringProtocol
}

/// This is a helper class that works around absence of "package private" access control in Swift
public struct _TextFieldProxy {
  public let subject: TextField<Text>

  public init(_ subject: TextField<Text>) { self.subject = subject }

  public func with(style: TextFieldStyle) -> Self {
    _TextFieldProxy(TextField(_from: subject, textFieldStyle: style))
  }

  public var label: _TextProxy { _TextProxy(subject.label) }
  public var textBinding: Binding<String> { subject.textBinding }
  public var onCommit: () -> () { subject.onCommit }
  public var onEditingChanged: (Bool) -> () { subject.onEditingChanged }
  public var textFieldStyle: TextFieldStyle { subject.textFieldStyle }
}
