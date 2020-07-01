// Copyright 2019-2020 Tokamak contributors
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

struct CustomModifier: ViewModifier {
  func body(content: Content) -> some View {
    Text("Whole new body!")
  }
}

struct TextDemo: View {
  var body: some View {
    VStack {
      Text("This is the inital text")
        .modifier(CustomModifier())
      Text("I'm all fancy")
        .font(.system(size: 16, weight: .regular, design: .serif))
        .italic()
      HStack {
        ForEach([
          Font.Weight.ultraLight,
          .thin,
          .light,
          .regular,
          .semibold,
          .bold,
          .heavy,
          .black,
        ], id: \.self) { weight in
          Text("a")
            .fontWeight(weight)
        }
      }
      VStack {
        Text("This is super important")
          .bold()
          .underline(true, color: .red)
        Text("This was super important")
          .bold()
          .strikethrough(true, color: .red)
        Text("THICK TEXT")
          .kerning(0.5)
      }
    }
  }
}
