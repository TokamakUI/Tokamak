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

extension TextField: DOMPrimitive where Label == Text {
  func css(for style: _AnyTextFieldStyle) -> String {
    if style is PlainTextFieldStyle {
      return """
      background: transparent;
      border: none;
      """
    } else {
      return ""
    }
  }

  func className(for style: _AnyTextFieldStyle) -> String {
    switch style {
    case is DefaultTextFieldStyle, is RoundedBorderTextFieldStyle:
      return "_tokamak-formcontrol"
    default:
      return "_tokamak-formcontrol-reset"
    }
  }

  var renderedBody: AnyView {
    let proxy = _TextFieldProxy(self)

    return AnyView(DynamicHTML("input", [
      "type": proxy.textFieldStyle is RoundedBorderTextFieldStyle ? "search" : "text",
      .value: proxy.textBinding.wrappedValue,
      "placeholder": _TextProxy(proxy.label).rawText,
      "style": """
      \(css(for: proxy.textFieldStyle)) \
      \(proxy.foregroundColor.map { "color: \($0.cssValue);" } ?? "")
      """,
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
