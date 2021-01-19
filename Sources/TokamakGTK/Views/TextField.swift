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

extension TextField: ViewDeferredToRenderer where Label == Text {
  public var deferredBody: AnyView {
    AnyView(WidgetView(build: { _ in
      let proxy = _TextFieldProxy(self)
      let entry = gtk_entry_new()!
      entry.withMemoryRebound(to: GtkEntry.self, capacity: 1) {
        gtk_entry_set_text($0, proxy.textBinding.wrappedValue)
        gtk_entry_set_placeholder_text($0, proxy.label.rawText)
      }
      bindAction(to: entry)
      return entry
    }, update: { a in
      guard case let .widget(widget) = a.storage else { return }

      let proxy = _TextFieldProxy(self)
      widget.withMemoryRebound(to: GtkEntry.self, capacity: 1) {
        gtk_entry_set_text($0, proxy.textBinding.wrappedValue)
        gtk_entry_set_placeholder_text($0, proxy.label.rawText)
      }

    }) {})
  }

  func bindAction(to entry: UnsafeMutablePointer<GtkWidget>) {
    entry.connect(signal: "changed", closure: { _ in
      entry.withMemoryRebound(to: GtkEntry.self, capacity: 1) {
        let proxy = _TextFieldProxy(self)
        let updated = String(cString: gtk_entry_get_text($0))
        proxy.textBinding.wrappedValue = updated
      }
    })
  }
}
