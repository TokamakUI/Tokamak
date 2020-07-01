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

import JavaScriptKit
import TokamakDOM

let document = JSObjectRef.global.document.object!

struct CustomModifier: ViewModifier {
  func body(content: Content) -> some View {
    Text("Whole new body!")
  }
}

let div = document.createElement!("div").object!
let renderer = DOMRenderer(
  NavigationView {
    VStack(alignment: .leading, spacing: 16) {
      Spacer()
      NavigationLink("Counter", destination:
        Counter(count: 5, limit: 15)
          .padding()
          .background(Color(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0))
          .border(Color.red, width: 3))

      NavigationLink("ZStack", destination: ZStack {
        Text("I'm on bottom")
        Text("I'm forced to the top")
          .zIndex(1)
        Text("I'm on top")
      }.padding(20))
      NavigationLink("ForEach", destination: ForEachDemo())
      NavigationLink("Text", destination: TextDemo())
      NavigationLink("SVG", destination: SVGCircle().frame(width: 25, height: 25))
      NavigationLink("TextField", destination: TextFieldDemo())
      NavigationLink("Spacer", destination: SpacerDemo())
      NavigationLink("Environment", destination: EnvironmentDemo().font(.system(size: 21)))
      Spacer()
    }.padding()
  },
  div
)

_ = document.body.object!.appendChild!(div)
