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

extension _Button: ViewDeferredToRenderer where Label == Text {
  public var deferredBody: AnyView {
    let attributes: [String: String]
    if buttonStyle.type == DefaultButtonStyle.self {
      attributes = ["class": "_tokamak-buttonstyle-default"]
    } else {
      attributes = ["class": "_tokamak-buttonstyle-reset"]
    }

    return AnyView(DynamicHTML("button", attributes, listeners: [
      "click": { _ in action() },
      "pointerdown": { _ in isPressed = true },
      "pointerup": { _ in isPressed = false },
    ]) {
      buttonStyle.makeBody(
        configuration: _ButtonStyleConfigurationProxy(
          label: AnyView(label),
          isPressed: isPressed
        ).subject
      )
    })
  }
}
