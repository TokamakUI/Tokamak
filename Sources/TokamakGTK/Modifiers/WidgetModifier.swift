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

protocol WidgetAttributeModifier: WidgetModifier {
  var attributes: [String: String] { get }
}

extension WidgetAttributeModifier {
  func modify(widget: UnsafeMutablePointer<GtkWidget>) {
    let context = gtk_widget_get_style_context(widget)
    let provider = gtk_css_provider_new()

    let renderedStyle = attributes.reduce("") { $0 + "\($1.0):\($1.1);" }

    gtk_css_provider_load_from_data(
      provider,
      "* { \(renderedStyle) }",
      -1,
      nil
    )

    gtk_style_context_add_provider(
      context,
      OpaquePointer(provider),
      1 /* GTK_STYLE_PROVIDER_PRIORITY_FALLBACK */
    )

    g_object_unref(provider)
  }
}

extension ModifiedContent: GTKPrimitive where Content: View {
  @_spi(TokamakCore)
  public var renderedBody: AnyView {
    guard let widgetModifier = modifier as? WidgetModifier else {
      return AnyView(content)
    }
    let anyWidget: AnyWidget
    if let anyView = content as? GTKPrimitive,
       let _anyWidget = mapAnyView(
         anyView.renderedBody,
         transform: { (widget: AnyWidget) in widget }
       )
    {
      anyWidget = _anyWidget
    } else if let _anyWidget = content as? AnyWidget {
      anyWidget = _anyWidget
    } else {
      return AnyView(content)
    }

    let build: (UnsafeMutablePointer<GtkApplication>) -> UnsafeMutablePointer<GtkWidget> = {
      let contentWidget = anyWidget.new($0)
      widgetModifier.modify(widget: contentWidget)
      return contentWidget
    }

    let update: (Widget) -> () = { widget in
      anyWidget.update(widget: widget)

      // Is it correct to apply the modifier again after updating?
      // I assume so since the modifier parameters may have changed.
      if case let .widget(w) = widget.storage {
        widgetModifier.modify(widget: w)
      }
    }

    // All this could be done using a single result builder for the content parameter,
    // but since we are already wrapping in an AnyView, there's no reason to also
    // wrap the contents in the inferred _ConditionalContent wrappers too.
    // So instead, the conditional logic is moved out of the result builder world.
    // This gives slightly lighter View type hierarchies.
    if let parentView = anyWidget as? ParentView, parentView.children.count > 1 {
      return AnyView(
        WidgetView(
          build: build,
          update: update,
          content: {
            ForEach(Array(parentView.children.enumerated()), id: \.offset) { _, view in
              view
            }
          }
        )
      )
    } else if let parentView = anyWidget as? ParentView, parentView.children.count == 1 {
      return AnyView(
        WidgetView(
          build: build,
          update: update,
          content: {
            parentView.children[0]
          }
        )
      )
    } else {
      return AnyView(
        WidgetView(
          build: build,
          update: update,
          content: {
            EmptyView()
          }
        )
      )
    }
  }
}
