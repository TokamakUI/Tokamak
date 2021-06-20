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
import TokamakStaticHTML

extension _PickerContainer: DOMPrimitive {
  var renderedBody: AnyView {
    AnyView(HTML("label") {
      label
      Text(" ")
      DynamicHTML("select", ["class": "_tokamak-formcontrol"], listeners: ["change": {
        guard
          let valueString = $0.target.object!.value.string,
          let value = Int(valueString) as? SelectionValue
        else { return }
        selection = value
      }]) {
        content
      }
    })
  }
}

extension _PickerElement: DOMPrimitive {
  var renderedBody: AnyView {
    let attributes: [HTMLAttribute: String]
    if let value = valueIndex {
      attributes = [.value: "\(value)"]
    } else {
      attributes = [:]
    }

    return AnyView(HTML("option", attributes) {
      content
    })
  }
}
