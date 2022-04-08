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

import CGTK
import TokamakCore

protocol AnyWidget {
  var expand: Bool { get }
  func new(_ application: UnsafeMutablePointer<GtkApplication>) -> UnsafeMutablePointer<GtkWidget>
  func update(widget: Widget)
}

extension AnyWidget {
  var expand: Bool { false }
}

struct WidgetView<Content: View>: View, AnyWidget, ParentView {
  let build: (UnsafeMutablePointer<GtkApplication>) -> UnsafeMutablePointer<GtkWidget>
  let update: (Widget) -> ()
  let content: Content
  let expand: Bool

  init(
    build: @escaping (UnsafeMutablePointer<GtkApplication>) -> UnsafeMutablePointer<GtkWidget>,
    update: @escaping (Widget) -> () = { _ in },
    expand: Bool = false,
    @ViewBuilder content: () -> Content
  ) {
    self.build = build
    self.expand = expand
    self.content = content()
    self.update = update
  }

  func new(_ application: UnsafeMutablePointer<GtkApplication>) -> UnsafeMutablePointer<GtkWidget> {
    build(application)
  }

  func update(widget: Widget) {
    if case .widget = widget.storage {
      update(widget)
    }
  }

  var body: Never {
    neverBody("WidgetView")
  }

  var children: [AnyView] {
    [AnyView(content)]
  }
}

extension WidgetView where Content == EmptyView {
  init(
    build: @escaping (UnsafeMutablePointer<GtkApplication>) -> UnsafeMutablePointer<GtkWidget>,
    expand: Bool = false
  ) {
    self.init(build: build, expand: expand) { EmptyView() }
  }
}

final class Widget: Target {
  enum Storage {
    case application(UnsafeMutablePointer<GtkApplication>)
    case widget(UnsafeMutablePointer<GtkWidget>)
  }

  let storage: Storage
  var view: AnyView

  /*
   let window: UnsafeMutablePointer<GtkWidget>
   window = gtk_application_window_new(app)
   label = gtk_label_new("Hello GNOME!")
   window.withMemoryRebound(to: GtkContainer.self, capacity: 1) {
       gtk_container_add($0, label)
   }
   window.withMemoryRebound(to: GtkWindow.self, capacity: 1) {
       gtk_window_set_title($0, "Welcome to GNOME")
       gtk_window_set_default_size($0, 200, 100)
   }
   gtk_widget_show_all(window)
   */

  init<V: View>(_ view: V, _ ref: UnsafeMutablePointer<GtkWidget>) {
    storage = .widget(ref)
    self.view = AnyView(view)
  }

  init(_ ref: UnsafeMutablePointer<GtkWidget>) {
    storage = .widget(ref)
    view = AnyView(EmptyView())
  }

  init(_ ref: UnsafeMutablePointer<GtkApplication>) {
    storage = .application(ref)
    view = AnyView(EmptyView())
  }

  func destroy() {
    switch storage {
    case .application:
      fatalError("Attempt to destroy root Application.")
    case let .widget(widget):
      gtk_widget_destroy(widget)
    }
  }
}
