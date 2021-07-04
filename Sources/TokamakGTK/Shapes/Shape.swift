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
//  Created by Morten Bek Ditlevsen on 29/12/2020.
//

import CGDK
import CGTK
import Foundation
import TokamakCore

func createPath(from elements: [Path.Element], in cr: OpaquePointer) {
  var current: CGPoint = .zero
  var start: CGPoint = .zero
  for element in elements {
    switch element {
    case let .move(to: p):
      cairo_move_to(cr, Double(p.x), Double(p.y))
      current = p
      start = p

    case let .line(to: p):
      cairo_line_to(cr, Double(p.x), Double(p.y))
      current = p

    case .closeSubpath:
      cairo_close_path(cr)
      current = start

    case let .curve(to: p, control1: c1, control2: c2):
      cairo_curve_to(
        cr,
        Double(c1.x),
        Double(c1.y),
        Double(c2.x),
        Double(c2.y),
        Double(p.x),
        Double(p.y)
      )
      current = p

    case let .quadCurve(to: p, control: c):
      let c1 = CGPoint(x: (current.x + 2 * c.x) / 3, y: (current.y + 2 * c.y) / 3)
      let c2 = CGPoint(x: (p.x + 2 * c.x) / 3, y: (p.y + 2 * c.y) / 3)
      cairo_curve_to(
        cr,
        Double(c1.x),
        Double(c1.y),
        Double(c2.x),
        Double(c2.y),
        Double(p.x),
        Double(p.y)
      )
      current = p
    }
  }
}

extension _ShapeView: GTKPrimitive {
  @_spi(TokamakCore)
  public var renderedBody: AnyView {
    AnyView(WidgetView(build: { _ in
      let w = gtk_drawing_area_new()
      bindAction(to: w!)
      return w!
    }) {})
  }

  func bindAction(to drawingArea: UnsafeMutablePointer<GtkWidget>) {
    drawingArea.connect(signal: "draw", closure: { widget, cr in
      cairo_save(cr)

      let width = gtk_widget_get_allocated_width(widget)
      let height = gtk_widget_get_allocated_height(widget)

      let c = (style as? Color) ?? foregroundColor ?? Color.black

      var color = c.resolveToCairo(in: environment)

      gdk_cairo_set_source_rgba(cr, &color)

      let path = shape.path(in: CGRect(
        origin: .zero,
        size: CGSize(
          width: Double(width),
          height: Double(height)
        )
      ))
      let elements: [Path.Element]
      let stroke: Bool
      if case let .stroked(strokedPath) = path.storage {
        elements = strokedPath.path.elements
        stroke = true
        let style = strokedPath.style

        cairo_set_line_width(cr, Double(style.lineWidth))
        cairo_set_line_join(cr, style.lineJoin.cairo)
        cairo_set_line_cap(cr, style.lineCap.cairo)
        cairo_set_miter_limit(cr, Double(style.miterLimit))
        let dash = style.dash.map(Double.init)
        cairo_set_dash(cr, dash, Int32(dash.count), Double(style.dashPhase))
      } else {
        elements = path.elements
        stroke = false
      }

      cairo_set_fill_rule(cr, fillStyle.cairo)

      createPath(from: elements, in: cr)

      // It kind of appears to be ok to reset the clip (in order to draw outside the frame)...
      // This could be error prone, however, and a source of future bugs...
      cairo_reset_clip(cr)

      if stroke {
        cairo_stroke(cr)
      } else {
        cairo_fill(cr)
      }

      cairo_restore(cr)
    })
  }
}

extension CGLineJoin {
  var cairo: cairo_line_join_t {
    switch self {
    case .miter:
      return cairo_line_join_t(rawValue: 0) /* CAIRO_LINE_JOIN_MITER */
    case .round:
      return cairo_line_join_t(rawValue: 1) /* CAIRO_LINE_JOIN_ROUND */
    case .bevel:
      return cairo_line_join_t(rawValue: 2) /* CAIRO_LINE_JOIN_BEVEL */
    }
  }
}

extension CGLineCap {
  var cairo: cairo_line_cap_t {
    switch self {
    case .butt:
      return cairo_line_cap_t(rawValue: 0) /* CAIRO_LINE_CAP_BUTT */
    case .round:
      return cairo_line_cap_t(rawValue: 1) /* CAIRO_LINE_CAP_ROUND */
    case .square:
      return cairo_line_cap_t(rawValue: 2) /* CAIRO_LINE_CAP_SQUARE */
    }
  }
}

extension FillStyle {
  var cairo: cairo_fill_rule_t {
    if isEOFilled {
      return cairo_fill_rule_t(rawValue: 1) /* CAIRO_FILL_RULE_EVEN_ODD */
    } else {
      return cairo_fill_rule_t(rawValue: 0) /* CAIRO_FILL_RULE_WINDING */
    }
  }
}

extension AnyColorBox.ResolvedValue {
  var cairo: GdkRGBA {
    GdkRGBA(
      red: Double(red),
      green: Double(green),
      blue: Double(blue),
      alpha: Double(opacity)
    )
  }
}

extension Color {
  func resolveToCairo(in environment: EnvironmentValues) -> GdkRGBA {
    _ColorProxy(self).resolve(in: environment).cairo
  }
}
