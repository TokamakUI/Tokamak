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
    guard let widgetModifier = modifier as? WidgetModifier else {
        return AnyView(content)
    }
    let anyWidget: AnyWidget
    if let anyView = content as? ViewDeferredToRenderer,
       let _anyWidget = mapAnyView(
        anyView.deferredBody,
        transform: { (widget: AnyWidget) in widget }
       )
    {
        anyWidget = _anyWidget
    } else if let _anyWidget = content as? AnyWidget {
        anyWidget = _anyWidget
    } else {
        return AnyView(content)
    }
    return AnyView(WidgetView {
        let contentWidget = anyWidget.new($0)
        widgetModifier.modify(widget: contentWidget)
        return contentWidget
    }
    update: { widget in
        anyWidget.update(widget: widget)

        // Is it correct to run the modifier again after updating?
        // I assume so since the modifier parameters may have changed.
        if case .widget(let w) = widget.storage {
            widgetModifier.modify(widget: w)
        }
    }
    content: {
        if let parentView = anyWidget as? ParentView, parentView.children.count > 1 {
            ForEach(Array(parentView.children.enumerated()), id: \.offset) { _, view in
                view
            }
        } else if let parentView = anyWidget as? ParentView, parentView.children.count == 1 {
            parentView.children[0]
        }
    })
  }
}
