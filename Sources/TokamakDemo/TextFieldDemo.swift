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

import TokamakDOM

struct TextFieldDemo: View {
  @State var text = ""
  @State var numCommits = 0
  var body: some View {
    VStack {
      HStack {
        TextField("Basic text field", text: $text)
        TextField(text, text: $text, onCommit: { numCommits += 1 })
      }
      Text("Commits: \(numCommits)")
      Text("Text: “\(text)”")
    }
  }
}
