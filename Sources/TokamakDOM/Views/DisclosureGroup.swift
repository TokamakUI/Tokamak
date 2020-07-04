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

public typealias DisclosureGroup = TokamakCore.DisclosureGroup
public typealias OutlineGroup = TokamakCore.OutlineGroup

extension DisclosureGroup: ViewDeferredToRenderer {
  public var deferredBody: AnyView {
    AnyView(HTML("div", ["class": "_tokamak-disclosuregroup"]) {
      HTML("div",
           ["class": "_tokamak-disclosuregroup-label"],
           listeners: [
             "click": { _ in
               self.isExpanded.toggle()
               self.isExpandedBinding?.wrappedValue.toggle()
             },
           ]) {
        HStack {
          HTML("div", ["class": "_tokamak-disclosuregroup-chevron"])
            .rotationEffect((isExpandedBinding?.wrappedValue ?? isExpanded) ? .degrees(90) : .degrees(0))
          _DisclosureGroupProxy(self).label
        }
      }
      HTML("div", ["class": "_tokamak-disclosuregroup-content"]) { () -> AnyView in
        if isExpandedBinding?.wrappedValue ?? isExpanded {
          return AnyView(_DisclosureGroupProxy(self).content())
        } else {
          return AnyView(EmptyView())
        }
      }
    })
  }
}
