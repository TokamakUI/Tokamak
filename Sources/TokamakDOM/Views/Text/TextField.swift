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

import Foundation

@_spi(TokamakCore)
import TokamakCore

@_spi(TokamakStaticHTML)
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

  var attributes: [HTMLAttribute: String] {
    let proxy = _TextFieldProxy(self)
    return [
      "type": proxy.textFieldStyle is RoundedBorderTextFieldStyle ? "search" : "text",
      .value: proxy.textBinding.wrappedValue,
      "placeholder": _TextProxy(proxy.label).rawText,
    ]
  }

  var listeners: [String: Listener] {
    let proxy = _TextFieldProxy(self)
    return [
      "focus": { _ in proxy.onEditingChanged(true) },
      "blur": { _ in proxy.onEditingChanged(false) },
      "keypress": { event in if event.key == "Enter" { proxy.onCommit() } },
      "input": { event in
        if let newValue = event.target.object?.value.string {
          proxy.textBinding.wrappedValue = newValue
        }
      },
    ]
  }

  var renderedBody: AnyView {
    let proxy = _TextFieldProxy(self)
    return AnyView(DynamicHTML(
      "input",
      attributes.merging([
        "style": """
        \(css(for: proxy.textFieldStyle)) \
        \(proxy.foregroundColor.map { "color: \($0.cssValue);" } ?? "")
        """,
        "class": className(for: proxy.textFieldStyle),
      ], uniquingKeysWith: { $1 }),
      listeners: listeners
    ))
  }
}

@_spi(TokamakStaticHTML)
extension TextField: HTMLConvertible, DOMNodeConvertible, Layout, _AnyLayout, Animatable
  where Label == Text
{
  public typealias AnimatableData = EmptyAnimatableData
  public var tag: String { "input" }
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    if useDynamicLayout {
      return attributes
        .merging(["style": "padding: 0; border: none;"], uniquingKeysWith: { $0 + $1 })
    } else {
      return attributes
    }
  }

  public func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) -> CGSize {
    let proxy = _TextFieldProxy(self)
    var content = Text(proxy.textBinding.wrappedValue)
    content.environmentOverride = proxy.environment
    let contentSize = proxy.environment.measureText(
      content,
      proposal,
      proxy.environment
    )
    var label = proxy.label
    label.environmentOverride = proxy.environment
    let labelSize = proxy.environment.measureText(
      label,
      proposal,
      proxy.environment
    )
    let proposal = proposal.replacingUnspecifiedDimensions()
    return .init(
      width: max(proposal.width, max(contentSize.width, labelSize.width)),
      height: max(contentSize.height, labelSize.height)
    )
  }

  public func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) {
    for subview in subviews {
      subview.place(at: bounds.origin, proposal: proposal)
    }
  }
}
