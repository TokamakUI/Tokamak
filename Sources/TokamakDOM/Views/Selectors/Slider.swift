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

extension Slider: ViewDeferredToRenderer {
  public var deferredBody: AnyView {
    let proxy = _SliderProxy(self)
    let step: String
    switch proxy.step {
    case .any:
      step = "any"
    case let .discrete(value):
      step = String(value)
    }
    let attributes = [
      "type": "range",
      "min": String(proxy.bounds.lowerBound),
      "max": String(proxy.bounds.upperBound),
      "step": step,
      "value": String(proxy.valueBinding.wrappedValue),
      "style": """
        display: block;
        width: 100%;
      """,
    ]
    return AnyView(
      HStack {
        proxy.minValueLabel
        DynamicHTML(
          "input",
          attributes,
          listeners: [
            "input": { event in
              proxy.valueBinding.wrappedValue = Double(event.target.object!.value.string!)!
            },
            "pointerdown": { _ in proxy.onEditingChanged(true) },
            "pointerup": { _ in proxy.onEditingChanged(false) },
            "pointercancel": { _ in proxy.onEditingChanged(false) },
          ]
        )
        proxy.maxValueLabel
      }
    )
  }
}
