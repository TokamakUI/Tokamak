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
//  Created by Jed Fox on 06/28/2020.
//

import TokamakCore
import TokamakStaticHTML

extension TextField: ViewDeferredToRenderer where Label == Text {
  func css(for style: TextFieldStyle) -> String {
    if style is PlainTextFieldStyle {
      return """
      background: transparent;
      border: none;
      """
    } else {
      return ""
    }
  }

  func className(for style: TextFieldStyle) -> String {
    switch style {
    case is DefaultTextFieldStyle:
      return "_tokamak-textfield-default"
    case is RoundedBorderTextFieldStyle:
      return "_tokamak-textfield-roundedborder"
    default:
      return ""
    }
  }

  public var deferredBody: AnyView {
    let proxy = _TextFieldProxy(self)

    return AnyView(DynamicHTML("input", [
      "type": proxy.textFieldStyle is RoundedBorderTextFieldStyle ? "search" : "text",
      HTMLAttribute("value", isUpdatedAsProperty: true): proxy.textBinding.wrappedValue,
      "placeholder": proxy.label.rawText,
      "style": css(for: proxy.textFieldStyle),
      "class": className(for: proxy.textFieldStyle),
    ], listeners: [
      "focus": { _ in proxy.onEditingChanged(true) },
      "blur": { _ in proxy.onEditingChanged(false) },
      "keypress": { event in if event.key == "Enter" { proxy.onCommit() } },
      "input": { event in
        if let newValue = event.target.object?.value.string {
          proxy.textBinding.wrappedValue = newValue
        }
      },
    ]))
  }
}
