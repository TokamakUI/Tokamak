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
//  Created by Morten Bek Ditlevsen on 27/12/2020.
//

import CGTK
import Foundation
import TokamakCore

private func build(
  textBinding: Binding<String>,
  label: _TextProxy,
  visible: Bool = true
) -> UnsafeMutablePointer<GtkWidget> {
  let entry = gtk_entry_new()!
  entry.withMemoryRebound(to: GtkEntry.self, capacity: 1) {
    gtk_entry_set_text($0, textBinding.wrappedValue)
    gtk_entry_set_placeholder_text($0, label.rawText)
    if !visible {
      gtk_entry_set_visibility($0, gtk_false())
    }
  }
  bindAction(to: entry, textBinding: textBinding)
  return entry
}

private func update(
  entry: UnsafeMutablePointer<GtkWidget>,
  textBinding: Binding<String>,
  label: _TextProxy
) {
  entry.withMemoryRebound(to: GtkEntry.self, capacity: 1) {
    gtk_entry_set_text($0, textBinding.wrappedValue)
    gtk_entry_set_placeholder_text($0, label.rawText)
  }
}

private func bindAction(to entry: UnsafeMutablePointer<GtkWidget>, textBinding: Binding<String>) {
  entry.connect(signal: "changed", closure: { _ in
    entry.withMemoryRebound(to: GtkEntry.self, capacity: 1) {
      let updated = String(cString: gtk_entry_get_text($0))
      textBinding.wrappedValue = updated
    }
  })
}

extension SecureField: GTKPrimitive where Label == Text {
  @_spi(TokamakCore)
  public var renderedBody: AnyView {
    let proxy = _SecureFieldProxy(self)
    return AnyView(WidgetView(
      build: { _ in
        build(textBinding: proxy.textBinding, label: proxy.label, visible: false)
      },
      update: { w in
        guard case let .widget(entry) = w.storage else { return }
        update(entry: entry, textBinding: proxy.textBinding, label: proxy.label)
      }
    ) {})
  }
}

extension TextField: GTKPrimitive where Label == Text {
  @_spi(TokamakCore)
  public var renderedBody: AnyView {
    let proxy = _TextFieldProxy(self)
    return AnyView(WidgetView(
      build: { _ in
        build(textBinding: proxy.textBinding, label: _TextProxy(proxy.label))
      },
      update: { a in
        guard case let .widget(widget) = a.storage else { return }
        update(entry: widget, textBinding: proxy.textBinding, label: _TextProxy(proxy.label))
      }
    ) {})
  }
}
