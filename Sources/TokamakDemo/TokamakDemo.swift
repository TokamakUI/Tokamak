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
//
//  Created by Jed Fox on 07/01/2020.
//

#if canImport(SwiftUI)
import SwiftUI
#else
import TokamakDOM
#endif

struct NavItem: Identifiable {
  var id: String
  var destination: AnyView

  init<V>(_ id: String, destination: V) where V: View {
    self.id = id
    self.destination = AnyView(
      destination
        .frame(minWidth: 300)
        .navigationBarTitle(id)
    )
  }
}

var outlineGroupDemo: AnyView {
  if #available(OSX 10.16, iOS 14.0, *) {
    return AnyView(OutlineGroupDemo())
  } else {
    return AnyView(Text("OutlineGroup Unavailable"))
  }
}

#if canImport(TokamakDOM)
var svgDemo = SVGCircle()
#else
var svgDemo = Text("SVG is unavailable")
#endif

#if !os(macOS)
var listDemo: AnyView {
  if #available(iOS 14.0, *) {
    return AnyView(ListDemo().listStyle(InsetGroupedListStyle()))
  } else {
    return AnyView(ListDemo())
  }
}
#else
var listDemo = ListDemo()
#endif

var links: [NavItem] {
  [
    NavItem("Counter", destination:
      Counter(count: 5, limit: 15)
        .padding()
        .background(Color(red: 0.9, green: 0.9, blue: 0.9, opacity: 1.0))
        .border(Color.red, width: 3)),
    NavItem("ZStack", destination: ZStack {
      Text("I'm on bottom")
      Text("I'm forced to the top")
        .zIndex(1)
      Text("I'm on top")
    }.padding(20)),
    NavItem("ForEach", destination: ForEachDemo()),
    NavItem("Text", destination: TextDemo()),
    NavItem("SVG", destination: svgDemo),
    NavItem("TextField", destination: TextFieldDemo()),
    NavItem("Spacer", destination: SpacerDemo()),
    NavItem("Environment", destination: EnvironmentDemo().font(.system(size: 8))),
    NavItem("List", destination: listDemo),
    NavItem("OutlineGroup", destination: outlineGroupDemo),
  ]
}

struct TokamakDemoView: View {
  var body: some View {
    NavigationView { () -> AnyView in
      let list = List(links) { link in
        NavigationLink(link.id, destination: link.destination)
      }
      .frame(minHeight: 300)
      .navigationBarTitle("Demos")
      #if os(WASI)
      return AnyView(list)
      #else
      if #available(iOS 14.0, *) {
        return AnyView(list.listStyle(SidebarListStyle()))
      } else {
        return AnyView(list)
      }
      #endif
    }
  }
}
