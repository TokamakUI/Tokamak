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

import TokamakShim

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
      #if os(WASI)
      Group {
        Text("<font color='red'>Unsanitized Text</font>")
          ._domTextSanitizer(Sanitizers.HTML.insecure)
        Text("<font color='red'>Sanitized Text</font>")
        VStack {
          Text("<font color='red'>Text in Unsanitized VStack</font>")
          Text("<font color='red'>Sanitized Text in Unsanitized VStack</font>")
            ._domTextSanitizer(Sanitizers.HTML.encode)
        }
        ._domTextSanitizer(Sanitizers.HTML.insecure)
        Text("<font color='red'>Segmented ") + Text("Text</font>")
      }
      #endif
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
      (Text("This text has been ") + Text("concatenated").bold())
        .italic()
      ForEach(TextAlignment.allCases, id: \.hashValue) { alignment in
        Text(
          """
          Multiline
          text
          """
        )
        .multilineTextAlignment(alignment)
      }
      Text("Custom Font")
        .font(.custom("\"Marker Felt\"", size: 17))
      VStack {
        Text("Fallback Font")
          .font(.custom("\"Marker-Felt\"", size: 17))
      }
      .font(.system(.body, design: .serif))
    }
  }
}
