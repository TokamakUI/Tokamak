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

  // FIXME: this should be internal
  public let textBinding: Binding<String>
  public let editingChangedAction: (Bool) -> ()
  public let commitAction: () -> ()
  public var _textFieldStyle: TextFieldStyle = DefaultTextFieldStyle()

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
    editingChangedAction = onEditingChanged
    commitAction = onCommit
  }

  // FIXME: this should be internal
  public init(
    _from textField: TextField,
    textFieldStyle: TextFieldStyle
  ) {
    label = textField.label
    textBinding = textField.textBinding
    editingChangedAction = textField.editingChangedAction
    commitAction = textField.commitAction
    _textFieldStyle = textFieldStyle
  }

  // FIXME: implement this method, which uses a Formatter to control the value of the TextField
  // public init<S, T>(
  //     _ title: S, value: Binding<T>, formatter: Formatter,
  //     onEditingChanged: @escaping (Bool) -> Void = { _ in },
  //     onCommit: @escaping () -> Void = {}
  // ) where S : StringProtocol
}

public func textFieldLabel(_ textField: TextField<Text>) -> String {
  textField.label.content
}
