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
//  Created by Carson Katri on 7/3/20.
//

import TokamakCore
import TokamakStaticHTML

extension DisclosureGroup: DOMPrimitive {
  var chevron: some View {
    DynamicHTML(
      "div",
      ["class": "_tokamak-disclosuregroup-chevron-container"],
      listeners: [
        "click": { _ in
          _DisclosureGroupProxy(self).toggleIsExpanded()
        },
      ]
    ) {
      HTML("div", ["class": "_tokamak-disclosuregroup-chevron"])
        .rotationEffect(
          _DisclosureGroupProxy(self).isExpanded ?
            .degrees(90) :
            .degrees(0)
        )
    }
  }

  var label: some View {
    HTML("div", ["class": "_tokamak-disclosuregroup-label"]) { () -> AnyView in
      switch _DisclosureGroupProxy(self).style {
      case is _ListOutlineGroupStyle:
        return AnyView(HStack {
          _DisclosureGroupProxy(self).label
          Spacer()
          chevron
        })
      default:
        return AnyView(HStack {
          chevron
          _DisclosureGroupProxy(self).label
        })
      }
    }
  }

  var content: some View {
    HTML("div", [
      "class": "_tokamak-disclosuregroup-content",
      "role": "treeitem",
      "aria-expanded": _DisclosureGroupProxy(self).isExpanded ? "true" : "false",
    ]) { () -> AnyView in
      if _DisclosureGroupProxy(self).isExpanded {
        return AnyView(_DisclosureGroupProxy(self).content())
      } else {
        return AnyView(EmptyView())
      }
    }
  }

  var renderedBody: AnyView {
    AnyView(HTML("div", [
      "class": "_tokamak-disclosuregroup",
      "role": "tree",
    ]) { () -> AnyView in
      switch _DisclosureGroupProxy(self).style {
      case is _ListOutlineGroupStyle:
        return AnyView(VStack(alignment: .leading) {
          label
          Divider()
          content
        })
      default:
        return AnyView(VStack(alignment: .leading) {
          label
          content
        })
      }
    })
  }
}
