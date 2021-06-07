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

/// A control that displays a secure editable text interface.
///
/// `SecureField` is similar to `TextField`, but specifically designed for entering secure
/// text, such as passwords.
///
/// Available when `Label` conforms to `View`
///
///     @State private var password: String = ""
///     var body: some View {
///       SecureField("Password", text: $password)
///     }
///
/// You can also set a callback for when the enter key is pressed:
///
///     @State private var password: String = ""
///     var body: some View {
///       SecureField("Password", text: $password, onCommit: {
///         print("Set password")
///       })
///     }
public struct SecureField<Label>: _PrimitiveView where Label: View {
  let label: Label
  let textBinding: Binding<String>
  let onCommit: () -> ()
}

public extension SecureField where Label == Text {
  init<S>(
    _ title: S, text: Binding<String>,
    onCommit: @escaping () -> () = {}
  ) where S: StringProtocol {
    label = Text(title)
    textBinding = text.projectedValue
    self.onCommit = onCommit
  }
}

extension SecureField: ParentView {
  @_spi(TokamakCore)
  public var children: [AnyView] {
    (label as? GroupView)?.children ?? [AnyView(label)]
  }
}

/// This is a helper type that works around absence of "package private" access control in Swift
public struct _SecureFieldProxy {
  public let subject: SecureField<Text>

  public init(_ subject: SecureField<Text>) { self.subject = subject }

  public var label: _TextProxy { _TextProxy(subject.label) }
  public var textBinding: Binding<String> { subject.textBinding }
  public var onCommit: () -> () { subject.onCommit }
}
