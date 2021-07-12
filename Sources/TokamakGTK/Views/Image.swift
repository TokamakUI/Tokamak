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
//  Created by Morten Bek Ditlevsen on 14/12/2020.
//

import CGTK
import Foundation
import TokamakCore

extension Image: AnyWidget {
  func new(_ application: UnsafeMutablePointer<GtkApplication>) -> UnsafeMutablePointer<GtkWidget> {
    let proxy = _ImageProxy(self)
    let img = gtk_image_new_from_file(imagePath(for: proxy))!
    return img
  }

  func update(widget: Widget) {
    if case let .widget(w) = widget.storage {
      let proxy = _ImageProxy(self)
      w.withMemoryRebound(to: GtkImage.self, capacity: 1) {
        gtk_image_set_from_file($0, imagePath(for: proxy))
      }
    }
  }

  func imagePath(for proxy: _ImageProxy) -> String {
    let resolved = proxy.provider.resolve(in: proxy.environment)
    switch resolved.storage {
    case let .named(name, bundle),
         let .resizable(.named(name, bundle), _, _):
      return bundle?.path(forResource: name, ofType: nil) ?? name
    default: return ""
    }
  }
}
