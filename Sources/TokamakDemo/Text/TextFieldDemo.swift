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

import TokamakShim

struct TextFieldDemo: View {
  @State
  var text = ""

  @State
  var numCommits = 0

  @State
  var isFocused = false

  @State
  var password = ""

  @State
  var committedPassword = ""
  // Uncomment this line and build to verify the
  // textFieldStyle environment variable is inaccessible
  // @Environment(\.textFieldStyle) var textFieldStyle: TextFieldStyle

  var emptyString = Binding(get: { "" }, set: { _ in })
  var body: some View {
    VStack {
      HStack {
        TextField("Basic text field", text: $text)
        TextField("Press enter to commit", text: $text, onCommit: { numCommits += 1 })
      }
      TextField(
        isFocused ? "Focused" : "Not focused",
        text: emptyString,
        onEditingChanged: { editing in isFocused = editing }
      ).textFieldStyle(RoundedBorderTextFieldStyle())
      Text("Commits: \(numCommits)")
      Text("Text: “\(text)”")

      TextField("Plain style", text: $text).textFieldStyle(PlainTextFieldStyle())

      HStack {
        TextField("Rounded style, inherited", text: $text)
        VStack {
          TextField("Plain style, overridden", text: $text)
        }.textFieldStyle(PlainTextFieldStyle())
      }.textFieldStyle(RoundedBorderTextFieldStyle())

      HStack {
        SecureField(
          "Password",
          text: $password,
          onCommit: { committedPassword = password }
        )
        Text("Your password is \(committedPassword)")
      }
    }
  }
}
