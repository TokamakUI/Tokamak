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
@_spi(TokamakCore) import TokamakCore

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
        gtk_widget_show_all(window)

        GTKRenderer.sharedWindow = window

        self.reconciler = StackReconciler(
          app: app,
          target: Widget(window),
          environment: .defaultEnvironment.merging(rootEnvironment),
          renderer: self,
          scheduler: { next in
            DispatchQueue.main.async {
              next()
              gtk_widget_show_all(window)
            }
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
    guard let anyWidget = mapAnyView(
      host.view,
      transform: { (widget: AnyWidget) in widget }
    ) else {
      // handle cases like `TupleView`
      if mapAnyView(host.view, transform: { (view: ParentView) in view }) != nil {
        return parent
      }

      return nil
    }

    let ctor = anyWidget.new

    let widget: UnsafeMutablePointer<GtkWidget>
    switch parent.storage {
    case let .application(app):
      widget = ctor(app)
    case let .widget(parentWidget):
      widget = ctor(gtkAppRef)
      parentWidget.withMemoryRebound(to: GtkContainer.self, capacity: 1) {
        gtk_container_add($0, widget)
        if let stack = mapAnyView(parent.view, transform: { (view: StackProtocol) in view }) {
          gtk_widget_set_valign(widget, stack.alignment.vertical.gtkValue)
          gtk_widget_set_halign(widget, stack.alignment.horizontal.gtkValue)
          if anyWidget.expand {
            gtk_widget_set_hexpand(widget, gtk_true())
            gtk_widget_set_vexpand(widget, gtk_true())
          }
        }
      }
    }
    gtk_widget_show(widget)
    return Widget(host.view, widget)
  }

  func update(target: Widget, with host: MountedHost) {
    guard let widget = mapAnyView(host.view, transform: { (widget: AnyWidget) in widget })
    else { return }

    widget.update(widget: target)
  }

  func unmount(
    target: Widget,
    from parent: Widget,
    with task: UnmountHostTask<GTKRenderer>
  ) {
    defer { task.finish() }

    guard mapAnyView(task.host.view, transform: { (widget: AnyWidget) in widget }) != nil
    else { return }

    target.destroy()
  }

  public func isPrimitiveView(_ type: Any.Type) -> Bool {
    type is GTKPrimitive.Type
  }

  public func primitiveBody(for view: Any) -> AnyView? {
    (view as? GTKPrimitive)?.renderedBody
  }
}

protocol GTKPrimitive {
  var renderedBody: AnyView { get }
}
