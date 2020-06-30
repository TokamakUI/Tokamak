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

_ = document.head.object!.insertAdjacentHTML!("beforeend", #"""
<link
  rel="stylesheet"
  href="https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.4.1/semantic.min.css">
"""#)

struct CustomModifier: ViewModifier {
  func body(content: Content) -> some View {
    Text("Whole new body!")
  }
}

let div = document.createElement!("div").object!
let renderer = DOMRenderer(
  VStack {
    Counter(count: 5, limit: 15)
    ZStack {
      Text("I'm on bottom")
      Text("I'm forced to the top")
        .zIndex(1)
      Text("I'm on top")
    }
    .padding(20)
    ForEachDemo()
    TextDemo()
    SVGCircle()
      .frame(width: 25, height: 25)
    TextFieldDemo()
    SpacerDemo()
  },
  div
)

_ = document.body.object!.appendChild!(div)
