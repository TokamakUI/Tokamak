// Copyright 2020-2021 Tokamak contributors
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

import CGTK
import TokamakCore

protocol GtkStackProtocol {}

// extension NavigationView: AnyWidget, ParentView, GtkStackProtocol {
//   var expand: Bool { true }

//   func new(
//     _ application: UnsafeMutablePointer<GtkApplication>
//   ) -> UnsafeMutablePointer<GtkWidget> {
//     let box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 0)!
//     let stack = gtk_stack_new()!
//     let sidebar = gtk_stack_sidebar_new()!
//     sidebar.withMemoryRebound(to: GtkStackSidebar.self, capacity: 1) { reboundSidebar in
//       stack.withMemoryRebound(to: GtkStack.self, capacity: 1) { reboundStack in
//         gtk_stack_sidebar_set_stack(reboundSidebar, reboundStack)
//       }
//     }
//     box.withMemoryRebound(to: GtkBox.self, capacity: 1) {
//       gtk_box_pack_start($0, sidebar, gtk_true(), gtk_true(), 0)
//       gtk_box_pack_start($0, stack, gtk_true(), gtk_true(), 0)
//     }
//     return box
//   }

//   func update(widget: Widget) {}

//   // public var deferredBody: AnyView {
//   //   AnyView(HTML("div", [
//   //     "class": "_tokamak-navigationview",
//   //   ]) {
//   //     _NavigationViewProxy(self).content
//   //     HTML("div", [
//   //       "class": "_tokamak-navigationview-content",
//   //     ]) {
//   //       _NavigationViewProxy(self).destination
//   //     }
//   //   })
//   // }

//   public var children: [AnyView] {
//     [AnyView(_NavigationViewProxy(self).content)]
//   }
// }

extension NavigationView: GTKPrimitive {
  @_spi(TokamakCore)
  public var renderedBody: AnyView {
    let proxy = _NavigationViewProxy(self)
    return AnyView(HStack {
      proxy.content
        .environmentObject(proxy.context)
      proxy.destination
    }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity))
  }
}

extension NavigationLink: GTKPrimitive {
  @_spi(TokamakCore)
  public var renderedBody: AnyView {
    let proxy = _NavigationLinkProxy(self)
    return AnyView(Button(action: { proxy.activate() }) {
      proxy.label
    })
  }
}

// extension NavigationLink: AnyWidget, ParentView {
//   func new(
//     _ application: UnsafeMutablePointer<GtkApplication>
//   ) -> UnsafeMutablePointer<GtkWidget> {
//     let btn = gtk_button_new()!
//     bindAction(to: btn)
//     return btn
//   }

//   func bindAction(to btn: UnsafeMutablePointer<GtkWidget>) {
//     btn.connect(signal: "clicked", closure: {
//       _NavigationLinkProxy(self).activate()
//       print("Activated")
//     })
//   }

//   func update(widget: Widget) {
//     if case let .widget(w) = widget.storage {
//       w.disconnect(gtype: gtk_button_get_type(), signal: "clicked")
//       bindAction(to: w)
//     }
//   }

//   public var children: [AnyView] {
//     let proxy = _NavigationLinkProxy(self)
//     print("Making label: \(proxy.label)")
//     return [AnyView(proxy.label)]
//   }
// }

// extension NavigationLink: AnyWidget, ParentView {
//   func new(
//     _ application: UnsafeMutablePointer<GtkApplication>
//   ) -> UnsafeMutablePointer<GtkWidget> {
//     print("Creating NavLink widget")
//     let btn = gtk_button_new()!
//     bindAction(to: btn)
//     return btn
//   }

//   func update(widget: Widget) {
//     if case let .widget(w) = widget.storage {
//       w.disconnect(gtype: gtk_button_get_type(), signal: "clicked")
//       bindAction(to: w)
//     }
//   }

//   func bindAction(to btn: UnsafeMutablePointer<GtkWidget>) {
//     btn.connect(signal: "clicked", closure: {
//       _NavigationLinkProxy(self).activate()
//     })
//   }

//   public var children: [AnyView] {
//     [AnyView(_NavigationLinkProxy(self).label)]
//   }
// }
// extension NavigationLink: GTKPrimitive {
//   public var renderedBody: AnyView {
//     let proxy = _NavigationLinkProxy(self)
//     print("Selected: \(proxy.isSelected)")
//     return AnyView(Button {
//       proxy.activate()
//     } label: {
//       proxy.label
//     })
//   }
// }
