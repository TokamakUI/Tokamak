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
  func new(_ application: UnsafeMutablePointer<GtkApplication>)
    -> UnsafeMutablePointer<GtkWidget>?
  {
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

  public func size<T>(for proposedSize: ProposedSize, hostView: MountedHostView<T>) -> CGSize {
    print("OVERRIDE SIZE FOR TEXT")
    guard let widget = hostView.target as? Widget else { return proposedSize.orDefault }
    guard case let .widget(w) = widget.storage else { return proposedSize.orDefault }

    var minSize = GtkRequisition()
    var naturalSize = GtkRequisition()
    gtk_widget_get_preferred_size(w, &minSize, &naturalSize)

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
