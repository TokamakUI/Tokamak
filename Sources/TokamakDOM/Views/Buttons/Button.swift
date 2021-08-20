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
import TokamakStaticHTML

extension _Button: DOMPrimitive {
  @_spi(TokamakCore)
  public var renderedBody: AnyView {
    let listeners: [String: Listener] = [
      "pointerdown": { _ in isPressed = true },
      "pointerup": { _ in
        isPressed = false
        action()
      },
    ]
    return AnyView(DynamicHTML(
      "button",
      ["class": "_tokamak-buttonstyle-reset"],
      listeners: listeners
    ) {
      self.makeStyleBody()
    })
  }
}

extension _PrimitiveButtonStyleBody: DOMPrimitive {
  @_spi(TokamakCore)
  public var renderedBody: AnyView {
    let listeners: [String: Listener] = [
      "pointerup": { _ in
        action()
      },
    ]
    let isResetStyle = style is PlainButtonStyle.Type
      || style is BorderlessButtonStyle.Type
      || style is LinkButtonStyle.Type
    let isBorderedProminent = style is BorderedProminentButtonStyle.Type
    var attributes = [HTMLAttribute: String]()
    if isResetStyle {
      attributes["class"] = "_tokamak-buttonstyle-reset"
    } else if isBorderedProminent {
      attributes["class"] = "_tokamak-button-prominence-increased"
    }
    let font: Font?
    switch controlSize {
    case .mini: font = .caption2
    case .small: font = .caption
    case .regular: font = .body
    case .large: font = .title3
    }
    return AnyView(DynamicHTML(
      "button",
      attributes,
      listeners: listeners
    ) {
      if !isResetStyle {
        if isBorderedProminent {
          self.label
            .foregroundColor(.white)
        } else {
          self.label
            .colorScheme(.light)
        }
      } else {
        self.label
      }
    }.font(font))
  }
}
