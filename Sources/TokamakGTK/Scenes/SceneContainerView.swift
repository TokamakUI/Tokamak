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
import TokamakCore

struct SceneContainerView<Content: View>: View, AnyWidget {
  let content: Content

  var body: Never {
    neverBody("SceneContainerView")
  }

  func new(_ application: UnsafeMutablePointer<GtkApplication>) -> UnsafeMutablePointer<GtkWidget> {
    print("Making window")
    let window: UnsafeMutablePointer<GtkWidget>
    window = gtk_application_window_new(application)
    print("window.new")
    window.withMemoryRebound(to: GtkWindow.self, capacity: 1) {
      gtk_window_set_title($0, "Welcome to GNOME")
      gtk_window_set_default_size($0, 200, 100)
    }
    print("Window made")
    // gtk_widget_show_all(window)
    return window
  }

  func update(widget: Widget) {}
}
