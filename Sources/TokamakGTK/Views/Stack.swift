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
//  Created by Carson Katri on 10/10/20.
//

import CGTK
import Foundation
import TokamakCore

protocol StackProtocol {
  var alignment: Alignment { get }
}

struct Box<Content: View>: View, ParentView, AnyWidget, StackProtocol {
  let content: Content
  let orientation: GtkOrientation
  let spacing: CGFloat
  let alignment: Alignment

  let expand = true

  func new(_ application: UnsafeMutablePointer<GtkApplication>) -> UnsafeMutablePointer<GtkWidget> {
    let grid = gtk_grid_new()!
    gtk_orientable_set_orientation(OpaquePointer(grid), orientation)
    grid.withMemoryRebound(to: GtkGrid.self, capacity: 1) {
      gtk_grid_set_row_spacing($0, UInt32(spacing))
      gtk_grid_set_column_spacing($0, UInt32(spacing))
    }
    return grid
  }

  func update(widget: Widget) {}

  var body: Never {
    neverBody("Box")
  }

  public var children: [AnyView] {
    [AnyView(content)]
  }
}

extension VStack: GTKPrimitive {
  @_spi(TokamakCore)
  public var renderedBody: AnyView {
    AnyView(
      Box(
        content: content,
        orientation: GTK_ORIENTATION_VERTICAL,
        spacing: _VStackProxy(self).spacing,
        alignment: .init(horizontal: alignment, vertical: .center)
      )
    )
  }
}

extension HStack: GTKPrimitive {
  @_spi(TokamakCore)
  public var renderedBody: AnyView {
    AnyView(
      Box(
        content: content,
        orientation: GTK_ORIENTATION_HORIZONTAL,
        spacing: _HStackProxy(self).spacing,
        alignment: .init(horizontal: .center, vertical: alignment)
      )
    )
  }
}

extension HorizontalAlignment {
  var gtkValue: GtkAlign {
    switch self {
    case .center: return GTK_ALIGN_CENTER
    case .leading: return GTK_ALIGN_START
    case .trailing: return GTK_ALIGN_END
    default: return GTK_ALIGN_CENTER
    }
  }
}

extension VerticalAlignment {
  var gtkValue: GtkAlign {
    switch self {
    case .center: return GTK_ALIGN_CENTER
    case .top: return GTK_ALIGN_START
    case .bottom: return GTK_ALIGN_END
    default: return GTK_ALIGN_CENTER
    }
  }
}
