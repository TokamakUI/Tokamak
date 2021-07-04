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
//  Created by Carson Katri on 10/13/20.
//

import CGTK
import TokamakCore

extension _FrameLayout: WidgetModifier {
  func modify(widget: UnsafeMutablePointer<GtkWidget>) {
    gtk_widget_set_size_request(widget, Int32(width ?? -1), Int32(height ?? -1))
  }
}

extension _FlexFrameLayout: WidgetModifier {
  func modify(widget: UnsafeMutablePointer<GtkWidget>) {
    gtk_widget_set_halign(widget, alignment.horizontal.gtkValue)
    gtk_widget_set_valign(widget, alignment.vertical.gtkValue)
    if maxWidth == .infinity {
      print("Setting hexpand")
      gtk_widget_set_hexpand(widget, gtk_true())
      gtk_widget_set_halign(widget, GTK_ALIGN_FILL)
    }
    if maxHeight == .infinity {
      print("Setting vexpand")
      gtk_widget_set_vexpand(widget, gtk_true())
      gtk_widget_set_valign(widget, GTK_ALIGN_FILL)
    }
    gtk_widget_set_size_request(widget, Int32(idealWidth ?? -1), Int32(idealHeight ?? -1))
  }
}

extension Color {
  func cssValue(_ environment: EnvironmentValues) -> String {
    let rgba = _ColorProxy(self).resolve(in: environment)
    return "rgba(\(rgba.red * 255), \(rgba.green * 255), \(rgba.blue * 255), \(rgba.opacity))"
  }
}

// Border modifier
extension _OverlayModifier: WidgetAttributeModifier, WidgetModifier
  where Overlay == _ShapeView<_StrokedShape<TokamakCore.Rectangle._Inset>, Color>
{
  var attributes: [String: String] {
    let style = overlay.shape.style.dashPhase == 0 ? "solid" : "dashed"

    return [
      "border-style": style,
      "border-width": "\(overlay.shape.style.lineWidth)px",
      "border-color": overlay.style.cssValue(environment),
      "border-radius": "inherit",
    ]
  }
}

extension _BackgroundModifier: WidgetAttributeModifier, WidgetModifier where Background == Color {
  var attributes: [String: String] {
    let cssValue = background.cssValue(environment)
    return ["background": cssValue]
  }
}
