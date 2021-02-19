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

extension Text: AnyWidget {
  func new(_ application: UnsafeMutablePointer<GtkApplication>) -> UnsafeMutablePointer<GtkWidget>? {
    let proxy = _TextProxy(self)
    return gtk_label_new(proxy.rawText)
  }

  func update(widget: Widget) {
    if case let .widget(w) = widget.storage {
      w.withMemoryRebound(to: GtkLabel.self, capacity: 1) {
        gtk_label_set_text($0, _TextProxy(self).rawText)
      }
    }
  }

  public func layout<T>(size: CGSize, element: MountedHostView<T>) {
    print("OVERRIDE LAYOUT FOR TEXT")
    if let widget = element.target as? Widget {
      let resolvedTransform = widget.context.resolvedTransform
      if case let .widget(w) = widget.storage {
        gtk_fixed_move(widget.context.parent, w, Int32(resolvedTransform.x), Int32(resolvedTransform.y))
        gtk_widget_set_size_request(w, Int32(size.width), Int32(size.height))
      }
    }
  }

  public func size<T>(for proposedSize: ProposedSize, element: MountedHostView<T>) -> CGSize {
    print("OVERRIDE SIZE FOR TEXT", self, element)
    guard let widget = element.target as? Widget else { return proposedSize.orDefault }
    print("WIDGET", widget.storage)
    guard case let .widget(w) = widget.storage else { return proposedSize.orDefault }
    print("STORAGE", w)

    var minSize = GtkRequisition()
    var naturalSize = GtkRequisition()
    gtk_widget_get_preferred_size (w, &minSize, &naturalSize)
    print("MIN", minSize)

    var width: TokamakCore.CGFloat = 0
    var height: TokamakCore.CGFloat = 0
    if let proposedWidth = proposedSize.width {
      if proposedWidth < TokamakCore.CGFloat(minSize.width) {
        width = TokamakCore.CGFloat(minSize.width)
      } else if proposedWidth > TokamakCore.CGFloat(naturalSize.width) {
        width = TokamakCore.CGFloat(naturalSize.width)
      } else {
        width = proposedWidth
      }
    } else {
      width = TokamakCore.CGFloat(naturalSize.width)
    }
    if let proposedHeight = proposedSize.height {
      if proposedHeight < TokamakCore.CGFloat(minSize.height) {
        height = TokamakCore.CGFloat(minSize.height)
      } else if proposedHeight > TokamakCore.CGFloat(naturalSize.height) {
        height = TokamakCore.CGFloat(naturalSize.height)
      } else {
        height = proposedHeight
      }
    } else {
      height = TokamakCore.CGFloat(naturalSize.height)
    }

    return CGSize(width: width, height: height)
  }
    
}
