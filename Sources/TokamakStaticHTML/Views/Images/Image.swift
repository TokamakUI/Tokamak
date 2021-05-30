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
//  Created by Max Desiatov on 11/04/2020.
//

import TokamakCore

public typealias Image = TokamakCore.Image

extension Image: HTMLPrimitive {
  var renderedBody: AnyView {
    AnyView(_HTMLImage(proxy: _ImageProxy(self)))
  }
}

struct _HTMLImage: View {
  let proxy: _ImageProxy
  public var body: some View {
    var attributes: [HTMLAttribute: String] = [
      "src": proxy.path ?? proxy.name,
      "style": "max-width: 100%; max-height: 100%",
    ]
    if let label = proxy.labelString {
      attributes["alt"] = label
    }
    return AnyView(HTML("img", attributes))
  }
}
