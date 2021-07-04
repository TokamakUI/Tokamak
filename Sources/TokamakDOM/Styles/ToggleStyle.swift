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
//  Created by Jed Fox on 07/04/2020.
//

import TokamakCore
import TokamakStaticHTML

public struct DefaultToggleStyle: ToggleStyle {
  public func makeBody(configuration: Configuration) -> some View {
    CheckboxToggleStyle().makeBody(configuration: configuration)
  }

  public init() {}
}

public struct CheckboxToggleStyle: ToggleStyle {
  public func makeBody(configuration: ToggleStyleConfiguration) -> some View {
    var attrs: [HTMLAttribute: String] = ["type": "checkbox"]
    if configuration.isOn {
      attrs[.checked] = "checked"
    }
    return HTML("label") {
      DynamicHTML("input", attrs, listeners: [
        "change": { event in
          let checked = event.target.object?.checked.boolean ?? false
          configuration.isOn = checked
        },
      ])
      configuration.label
    }
  }
}

// FIXME: implement properly
public struct SwitchToggleStyle: ToggleStyle {
  public func makeBody(configuration: Configuration) -> some View {
    CheckboxToggleStyle().makeBody(configuration: configuration)
  }
}
