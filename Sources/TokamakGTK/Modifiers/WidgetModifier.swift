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

protocol WidgetModifier {
  func modify(widget: UnsafeMutablePointer<GtkWidget>)
}

extension ModifiedContent: ViewDeferredToRenderer where Content: View {
  public var deferredBody: AnyView {
    if let widgetModifier = modifier as? WidgetModifier {
      if let anyView = content as? ViewDeferredToRenderer,
         let anyWidget = mapAnyView(
           anyView.deferredBody,
           transform: { (widget: AnyWidget) in widget }
         )
      {
        return AnyView(WidgetView {
          let contentWidget = anyWidget.new($0)
          widgetModifier.modify(widget: contentWidget)
          return contentWidget
        } content: {
          if let parentView = anyWidget as? ParentView {
            ForEach(Array(parentView.children.enumerated()), id: \.offset) { _, view in
              view
            }
          }
        })
      } else if let anyWidget = content as? AnyWidget {
        return AnyView(WidgetView {
          let contentWidget = anyWidget.new($0)
          widgetModifier.modify(widget: contentWidget)
          return contentWidget
        } content: {
          if let parentView = anyWidget as? ParentView {
            ForEach(Array(parentView.children.enumerated()), id: \.offset) { _, view in
              view
            }
          }
        })
      }
    }
    return AnyView(content)
  }
}
