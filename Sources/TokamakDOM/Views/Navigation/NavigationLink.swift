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

import TokamakCore
import TokamakStaticHTML

extension NavigationLink: DOMPrimitive {
  var renderedBody: AnyView {
    let proxy = _NavigationLinkProxy(self)
    return AnyView(
      DynamicHTML("a", [
        "href": "javascript:void%200",
        "style": proxy.style.type == _SidebarNavigationLinkStyle.self ?
          "width: 100%; text-decoration: none;"
          : "",
      ], listeners: [
        // FIXME: Focus destination or something so assistive
        // technology knows where to look when clicking the link.
        "click": { _ in proxy.activate() },
      ]) {
        proxy.label
      }
    )
  }
}
