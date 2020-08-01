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

import TokamakShim

func title<V>(_ view: V, title: String) -> AnyView where V: View {
  if #available(OSX 10.16, iOS 14.0, *) {
    return AnyView(view.navigationTitle(title))
  } else {
    #if !os(macOS)
    return AnyView(view.navigationBarTitle(title))
    #else
    return AnyView(view)
    #endif
  }
}

struct NavItem: Identifiable {
  var id: String
  var destination: AnyView?

  init<V>(_ id: String, destination: V) where V: View {
    self.id = id
    self.destination = title(destination.frame(minWidth: 300), title: id)
  }

  init(unavailable id: String) {
    self.id = id
  }
}

var outlineGroupDemo: NavItem {
  if #available(OSX 10.16, iOS 14.0, *) {
    return NavItem("OutlineGroup", destination: OutlineGroupDemo())
  } else {
    return NavItem(unavailable: "OutlineGroup")
  }
}

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

var sidebarDemo: NavItem {
  if #available(iOS 14.0, *) {
    return NavItem("Sidebar", destination: SidebarListDemo().listStyle(SidebarListStyle()))
  } else {
    return NavItem(unavailable: "Sidebar")
  }
}

var gridDemo: NavItem {
  if #available(OSX 10.16, iOS 14.0, *) {
    return NavItem("Grid", destination: GridDemo())
  } else {
    return NavItem(unavailable: "Grid")
  }
}

var appStorageDemo: NavItem {
  if #available(OSX 11.0, iOS 14.0, *) {
    return NavItem("AppStorage", destination: AppStorageDemo())
  } else {
    return NavItem(unavailable: "AppStorage")
  }
}

var links: [NavItem] {
  [
    NavItem("Counter", destination:
      Counter(count: Count(value: 5), limit: 15)
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
    NavItem("Toggle", destination: ToggleDemo()),
    NavItem("Path", destination: PathDemo()),
    NavItem("TextField", destination: TextFieldDemo()),
    NavItem("Spacer", destination: SpacerDemo()),
    NavItem("Environment", destination: EnvironmentDemo().font(.system(size: 8))),
    NavItem("Picker", destination: PickerDemo()),
    NavItem("Slider", destination: SliderDemo()),
    NavItem("List", destination: listDemo),
    sidebarDemo,
    outlineGroupDemo,
    NavItem("Color", destination: ColorDemo()),
    appStorageDemo,
    gridDemo,
  ]
}

struct TokamakDemoView: View {
  var body: some View {
    NavigationView { () -> AnyView in
      let list = title(
        List(links) { link in
          if let dest = link.destination {
            NavigationLink(link.id, destination: HStack {
              Spacer(minLength: 0)
              dest
              Spacer(minLength: 0)
            })
          } else {
            #if os(WASI)
            Text(link.id)
            #elseif os(macOS)
            Text(link.id).opacity(0.5)
            #else
            HStack {
              Text(link.id)
              Spacer()
              Text("unavailable").opacity(0.5)
            }
            #endif
          }
        }
        .frame(minHeight: 300),
        title: "Demos"
      )
      if #available(iOS 14.0, *) {
        return AnyView(list.listStyle(SidebarListStyle()))
      } else {
        return AnyView(list)
      }
    }
    .environmentObject(TestEnvironment())
  }
}
