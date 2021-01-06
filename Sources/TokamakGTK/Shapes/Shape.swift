//
//  File.swift
//  
//
//  Created by Morten Bek Ditlevsen on 29/12/2020.
//

import CGTK
import CGDK
import TokamakCore

protocol ShapeAttributes {
}

extension _StrokedShape: ShapeAttributes {
}

//extension _ShapeView: ViewDeferredToRenderer {
//  public var deferredBody: AnyView {
//    let path = shape.path(in: .zero).deferredBody
//    if let shapeAttributes = shape as? ShapeAttributes {
//      return AnyView(HTML("div", shapeAttributes.attributes(style)) { path })
//    } else if let color = style as? Color {
//      return AnyView(HTML("div", [
//        "style": "fill: \(color.cssValue(environment));",
//      ]) { path })
//    } else if let foregroundColor = foregroundColor {
//      return AnyView(HTML("div", [
//        "style": "fill: \(foregroundColor.cssValue(environment));",
//      ]) { path })
//    } else {
//      return path
//    }
//  }
//}

extension _ShapeView: ViewDeferredToRenderer {
  public var deferredBody: AnyView {
    dump(self.environment)

    return AnyView(WidgetView(build: { _ in
      let w = gtk_drawing_area_new()
      bindAction(to: w!)
      return w!
    }) {
    })
  }

  func bindAction(to drawingArea: UnsafeMutablePointer<GtkWidget>) {
    drawingArea.connect2(signal: "draw", closure: { widget, cr in
//      dump(widget)
//      dump(cr)

      let width = gtk_widget_get_allocated_width (widget)
      let height = gtk_widget_get_allocated_height (widget)
//      print("W", width, "H", height)

      let c = (style as? Color) ?? foregroundColor ?? Color.black
//      dump(c)

      // XXX TODO, don't know why my environment doesn't work.
      var environment = EnvironmentValues()
      environment[_ColorSchemeKey] = .light

      dump(environment)
      let rgba = _ColorProxy(c).resolve(in: environment)
      dump(rgba)

      var color = GdkRGBA(red: Double(rgba.red),
                          green: Double(rgba.green),
                          blue: Double(rgba.blue),
                          alpha: Double(rgba.opacity))
      
      gdk_cairo_set_source_rgba (cr, &color)

      let path = shape.path(in: CGRect(origin: .zero, size: CGSize(width: Double(width), height: Double(height))))
//      let transform = CGAffineTransform(scaleX: Double(width), y: Double(height))
      let elements: [Path.Element]
      let stroke: Bool
      if case let .stroked(strokedPath) = path.storage {
        elements = strokedPath.path.elements
        stroke = true
        let style = strokedPath.style

        cairo_set_line_width(cr, style.lineWidth)
        cairo_set_line_join(cr, style.lineJoin.cairo)
        cairo_set_line_cap(cr, style.lineCap.cairo)
        cairo_set_miter_limit(cr, style.miterLimit)
        cairo_set_dash(cr, style.dash, Int32(style.dash.count), style.dashPhase)

      } else {
        elements = path.elements
        stroke = false
      }

      if fillStyle.isEOFilled {
        cairo_set_fill_rule(cr, cairo_fill_rule_t(rawValue: 1) /* CAIRO_FILL_RULE_EVEN_ODD */)
      } else {
        // This is already the default
//        cairo_set_fill_rule(cr, cairo_fill_rule_t(rawValue: 0) /* CAIRO_FILL_RULE_WINDING */)
      }

      dump(elements)

      var current: CGPoint = .zero
      var start: CGPoint = .zero
      for element in elements {
        switch element {
        case let .move(to: p):
          cairo_move_to(cr, p.x, p.y)
          current = p
          start = p

        case let .line(to: p):
          cairo_line_to(cr, p.x, p.y)
          current = p

        case .closeSubpath:
          cairo_close_path(cr)
          current = start

        case let .curve(to: p, control1: c1, control2: c2):
          cairo_curve_to(cr, c1.x, c1.y, c2.x, c2.y, p.x, p.y)
          current = p

        case let .quadCurve(to: p, control: c):
          let c1 = CGPoint(x: (current.x + 2 * c.x) / 3, y: (current.y + 2 * c.y) / 3)
          let c2 = CGPoint(x: (p.x + 2 * c.x) / 3, y: (p.y + 2 * c.y) / 3)
          cairo_curve_to(cr, c1.x, c1.y, c2.x, c2.y, p.x, p.y)
          current = p
        }
      }

//      switch (path.storage) {
//      case .rect(let rect):
//        cairo_rectangle(cr, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
//      case .ellipse(let rect):
//        guard rect.size.width > 0, rect.size.height > 0 else { return }
//        let size = min(rect.size.width, rect.size.height)
//        var xScale: Double = 1
//        var yScale: Double = 1
//        if rect.size.width < rect.size.height {
//          yScale = rect.size.height / rect.size.width
//        } else if rect.size.height < rect.size.width {
//          xScale = rect.size.width / rect.size.height
//        }
//        cairo_scale(cr, xScale, yScale)
//        cairo_arc(cr, rect.size.width / (2 * xScale), rect.size.height / (2 * yScale), size / 2, 0, 2 * Double.pi)
//
//      case .empty:
//        return
//
//      case .roundedRect(let rect):
////        dump(rect)
//        // TODO: Respect style
//        // TODO: Respect cornerSize instead of just a single radius. SwiftUI appears to draw 'skewed' arcs...
//
//        let radius = rect.cornerSize?.width ?? 10
//        let degrees = Double.pi / 180
//        let x = rect.rect.origin.x
//        let y = rect.rect.origin.y
//        let width = rect.rect.size.width
//        let height = rect.rect.size.height
//
//        cairo_new_sub_path (cr)
//        cairo_arc (cr, x + width - radius, y + radius, radius, -90 * degrees, 0 * degrees)
//        cairo_arc (cr, x + width - radius, y + height - radius, radius, 0 * degrees, 90 * degrees)
//        cairo_arc (cr, x + radius, y + height - radius, radius, 90 * degrees, 180 * degrees)
//        cairo_arc (cr, x + radius, y + radius, radius, 180 * degrees, 270 * degrees)
//        cairo_close_path (cr)
//
//
//      case .path(let box):
//
//
//      default:
//
//        fatalError("Not implemented")
//      }

      if stroke {
        cairo_stroke(cr)
      } else {
        cairo_fill(cr)
      }
//      dump(self)
//      let sko = shape.path(in: .zero)
//      dump(width)
//
//      let lineWidth: Double = 0.5
//
//      cairo_set_line_width (cr,
//                            lineWidth)
//
//      cairo_rectangle(cr, lineWidth / 2, lineWidth / 2, Double(width) - lineWidth, Double(height) - lineWidth)
////      cairo_arc (cr,
////                 20, 20,
////                 20,
////                 0, 2 * Double.pi);
//
//      cairo_stroke(cr)



    })
  }
}

extension CGLineJoin {
  var cairo: cairo_line_join_t {
    switch self {
    case .miter:
      return cairo_line_join_t(rawValue: 0)
    case .round:
      return cairo_line_join_t(rawValue: 1)
    case .bevel:
      return cairo_line_join_t(rawValue: 2)
    }
  }
}

extension CGLineCap {
  var cairo: cairo_line_cap_t {
    switch self {
    case .butt:
      return cairo_line_cap_t(rawValue: 0)
    case .round:
      return cairo_line_cap_t(rawValue: 1)
    case .square:
      return cairo_line_cap_t(rawValue: 2)
    }
  }
}
