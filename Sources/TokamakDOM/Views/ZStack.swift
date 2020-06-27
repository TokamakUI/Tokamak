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

import TokamakCore

public typealias ZStack = TokamakCore.ZStack

extension VerticalAlignment {
  var cssValue: String {
    switch self {
    case .top:
      return "start"
    case .center:
      return "center"
    case .bottom:
      return "end"
    }
  }
}

struct _ZStack_ContentGridItem : ViewModifier, DOMViewModifier {
  func attributes() -> [String : String] {
    ["style": "grid-area: a;"]
  }
  
  func body(content: Content) -> some View {
    content
  }
}

extension ZStack: ViewDeferredToRenderer {
  public var deferredBody: AnyView {
    AnyView(HTML("div", [
      "style": "display: grid; grid-template-columns: 1fr; width: fit-content; justify-items: \(alignment.horizontal.cssValue); align-items: \(alignment.vertical.cssValue)"
    ]) {
      TupleView(children, children: children.map { AnyView($0.modifier(_ZStack_ContentGridItem())) })
    })
  }
}
