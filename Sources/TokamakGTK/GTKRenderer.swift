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
//
//  Created by Carson Katri on 10/10/2020.
//

import CGTK
import Dispatch
import TokamakCore

extension EnvironmentValues {
  /// Returns default settings for the GTK environment
  static var defaultEnvironment: Self {
    var environment = EnvironmentValues()
    environment[_ColorSchemeKey] = .light
    // environment._defaultAppStorage = LocalStorage.standard
    // _DefaultSceneStorageProvider.default = SessionStorage.standard

    return environment
  }
}

func layout<T>(_ element: MountedElement<T>) {
  print("ELEMENT", element)
  if let hostView = element as? MountedHostView<T>, let view = mapAnyView(
    hostView.view,
    transform: { (view: View) in view }
  ) {
    view._layout(size: CGSize(width: 200, height: 100), hostView: hostView)
    return
  }
  for child in element.mountedChildren {
    layout(child)
  }
}

final class GTKRenderer: Renderer {
  private(set) var reconciler: StackReconciler<GTKRenderer>?
  private var gtkAppRef: UnsafeMutablePointer<GtkApplication>
  static var sharedWindow: UnsafeMutablePointer<GtkWidget>!

  init<A: App>(
    _ app: A,
    _ rootEnvironment: EnvironmentValues? = nil
  ) {
    gtkAppRef = gtk_application_new(nil, G_APPLICATION_FLAGS_NONE)

    gtkAppRef.withMemoryRebound(to: GApplication.self, capacity: 1) { gApp in
      gApp.connect(signal: "activate") {
        let window: UnsafeMutablePointer<GtkWidget>
        window = gtk_application_window_new(self.gtkAppRef)
        window.withMemoryRebound(to: GtkWindow.self, capacity: 1) {
          gtk_window_set_default_size($0, 200, 100)
        }
        let fixed = gtk_fixed_new()!
        window.withMemoryRebound(to: GtkContainer.self, capacity: 1) {
          gtk_container_add($0, fixed)
        }
        gtk_widget_show_all(window)
//        gtk_widget_show(fixed)
        GTKRenderer.sharedWindow = window

        var rootWidget: Widget!
        fixed.withMemoryRebound(to: GtkFixed.self, capacity: 1) {
          rootWidget = Widget(fixed, fixed: $0)
        }

        self.reconciler = StackReconciler(
          app: app,
          target: rootWidget,
          environment: .defaultEnvironment,
          renderer: self,
          scheduler: { next in
            DispatchQueue.main.async {
              next()
              gtk_widget_show_all(window)
            }
          },
          afterRenderCallback: { elm in
            layout(elm)
          }
        )

      }

      let status = g_application_run(gApp, 0, nil)
      exit(status)
    }
  }

  public func mountTarget(
    before sibling: Widget?,
    to parent: Widget,
    with host: MountedHost
  ) -> Widget? {
    print("HOST", host)
    guard let builtinView = mapAnyView(
      host.view,
      transform: { (view: BuiltinView) in view }
    ) else {
      // handle cases like `TupleView`
      if mapAnyView(host.view, transform: { (view: ParentView) in view }) != nil {
        return parent
      }

      print("HOSTVIEW", host.view)
      return nil
    }

    // TODO: GET PROPOSED SIZE FROM PARENT
//    let size = anyWidget.size(for: CGSize(width: 100, height: 100))


    let ctor: ((UnsafeMutablePointer<GtkApplication>) -> UnsafeMutablePointer<GtkWidget>?)

    if let anyWidget = builtinView as? AnyWidget {
      ctor = anyWidget.new
    } else {
      ctor = { _ in return nil }
    }

//    print("PARENT", parent)
//    print("ANYWIDGET", anyWidget)
//    print("HOST", host.view)
    let widget: UnsafeMutablePointer<GtkWidget>?
    let context: WidgetContext = parent.context as! WidgetContext
    switch parent.storage {
    case let .application(app):
      widget = ctor(app)
//      print("SKOOO")
    case let .widget(parentWidget):
      widget = ctor(gtkAppRef)
    case .dummy:
      widget = ctor(gtkAppRef)
    }

    if let w = widget {
        context.parent.withMemoryRebound(to: GtkFixed.self, capacity: 1) {
          gtk_fixed_put($0, w, 0, 0)
          gtk_widget_set_size_request(w, 10, 10)
        }
        gtk_widget_show(w)
    }

    return Widget(host.view, widget, context: context)
  }

  func update(target: Widget, with host: MountedHost) {
    guard let widget = mapAnyView(host.view, transform: { (widget: AnyWidget) in widget })
    else { return }

    widget.update(widget: target)
  }

  func unmount(
    target: Widget,
    from parent: Widget,
    with host: MountedHost,
    completion: @escaping () -> ()
  ) {
    defer { completion() }

    guard mapAnyView(host.view, transform: { (widget: AnyWidget) in widget }) != nil
    else { return }

    target.destroy()
  }
}
