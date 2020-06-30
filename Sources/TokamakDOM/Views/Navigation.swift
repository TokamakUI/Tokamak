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

import JavaScriptKit
import TokamakCore

public typealias NavigationView = TokamakCore.NavigationView
public typealias NavigationLink = TokamakCore.NavigationLink

extension NavigationView: ViewDeferredToRenderer {
  public var deferredBody: AnyView {
    AnyView(HTML("div", [
      "style": """
      display: flex; flex-direction: row; align-items: stretch;
      width: 100%; height: 100%;
      """,
    ], listeners: [
      "navlink:click": { event in
          if let id = event.detail.object?.id.number {
            selectedId = id
          }
        },
    ]) {
      Text("\(selectedId)")
      navigationViewContent(self)
    })
  }
}

extension NavigationLink: ViewDeferredToRenderer {
  public var deferredBody: AnyView {
    AnyView(HTML("div", listeners: [
      "click": { event in
        if let customEvent = JSObjectRef.global.CustomEvent.function?.new(
          "navlink:click", [
            "bubbles": true,
            "detail": ["id": 42],
          ]
        ), let dispatch = event.target.object?.dispatchEvent.function {
          _ = dispatch.apply(this: event.target.object!, arguments: customEvent)
        }
      },
    ]) { navigationLinkContent(self) })
  }
}
