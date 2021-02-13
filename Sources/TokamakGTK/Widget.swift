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

struct ProposedSize {
    var width: CGFloat?
    var height: CGFloat?

    var orDefault: CGSize {
        CGSize(width: width ?? 10, height: height ?? 10)
    }
}

protocol AnyWidget {
  var expand: Bool { get }
  func new(_ application: UnsafeMutablePointer<GtkApplication>) -> UnsafeMutablePointer<GtkWidget>?
  func update(widget: Widget)
  func size<T>(for proposedSize: ProposedSize, element: MountedHostView<T>) -> CGSize
    func layout<T>(size: CGSize, element: MountedHostView<T>)
}

extension AnyWidget {
  var expand: Bool { false }
  func size<T>(for proposedSize: ProposedSize, element: MountedHostView<T>) -> CGSize {
    print("USING DEFAULT SIZE FOR", self)
    return proposedSize.orDefault
  }
    func layout<T>(size: CGSize, element: MountedHostView<T>) {
        print("LAYING OUT", self, size)
        print("TARGET", element.target)
        if let widget = element.target as? Widget {
            if case let .widget(w) = widget.storage {
                gtk_widget_set_size_request(w, Int32(size.width), Int32(size.height))
                print("SIZE SET")
            }
        }
    }
}

struct WidgetView<Content: View>: View, AnyWidget, ParentView {
  let build: (UnsafeMutablePointer<GtkApplication>) -> UnsafeMutablePointer<GtkWidget>?
  let update: (Widget) -> ()
  let content: Content
  let expand: Bool

  init(build: @escaping (UnsafeMutablePointer<GtkApplication>) -> UnsafeMutablePointer<GtkWidget>?,
       update: @escaping (Widget) -> () = { _ in },
       expand: Bool = false,
       @ViewBuilder content: () -> Content)
  {
    print("SKO")
    self.build = build
    self.expand = expand
    self.content = content()
    self.update = update
  }

  func new(_ application: UnsafeMutablePointer<GtkApplication>) -> UnsafeMutablePointer<GtkWidget>? {
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
  init(build: @escaping (UnsafeMutablePointer<GtkApplication>) -> UnsafeMutablePointer<GtkWidget>,
       expand: Bool = false)
  {
    self.init(build: build, expand: expand) { EmptyView() }
  }
}

class WidgetContext {
  let parent: UnsafeMutablePointer<GtkWidget> // GtkFixed
  var transformStack: [CGAffineTransform] = []

  var resolvedTransform: CGAffineTransform {
    transformStack.reduce(CGAffineTransform.identity) { (a, b) -> CGAffineTransform in
      a.concatenating(b)
    }
  }
  init(parent: UnsafeMutablePointer<GtkWidget>) {
    self.parent = parent
  }
}

final class Widget: Target {
  enum Storage {
    case application(UnsafeMutablePointer<GtkApplication>)
    case widget(UnsafeMutablePointer<GtkWidget>)
    case dummy
  }

  let storage: Storage
  let context: WidgetContext
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

  init<V: View>(_ view: V, _ ref: UnsafeMutablePointer<GtkWidget>?, context: WidgetContext) {
    if let ref = ref {
        storage = .widget(ref)
    } else {
        storage = .dummy
    }
    self.view = AnyView(view)
    self.context = context
  }

  init(_ ref: UnsafeMutablePointer<GtkWidget>, fixed: UnsafeMutablePointer<GtkWidget>) {
    storage = .widget(ref)
    view = AnyView(EmptyView())
    self.context = WidgetContext(parent: fixed)
  }

  init(_ ref: UnsafeMutablePointer<GtkApplication>, context: WidgetContext) {
    storage = .application(ref)
    view = AnyView(EmptyView())
    self.context = context
  }

  func destroy() {
    switch storage {
    case .application:
      fatalError("Attempt to destroy root Application.")
    case let .widget(widget):
      gtk_widget_destroy(widget)
    case .dummy:
        ()
    }
  }
}
