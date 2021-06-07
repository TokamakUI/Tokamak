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

extension ScrollView: GTKPrimitive {
  @_spi(TokamakCore)
  public var renderedBody: AnyView {
    AnyView(WidgetView(build: { _ in
      gtk_scrolled_window_new(nil, nil)
    }) {
      if children.count > 1 {
        VStack {
          ForEach(Array(children.enumerated()), id: \.offset) { _, view in
            view
          }
        }
      } else {
        ForEach(Array(children.enumerated()), id: \.offset) { _, view in
          view
        }
      }
    })
  }
}
