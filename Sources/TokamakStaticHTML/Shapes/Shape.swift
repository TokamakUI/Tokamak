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
//  Created by Carson Katri on 6/29/20.
//

import TokamakCore

// Border modifier
extension _OverlayModifier: DOMViewModifier
  where Overlay == _ShapeView<_StrokedShape<TokamakCore.Rectangle._Inset>, Color>
{
  public var attributes: [HTMLAttribute: String] {
    let style = overlay.shape.style.dashPhase == 0 ? "solid" : "dashed"
    return ["style": """
    border-style: \(style);
    border-width: \(overlay.shape.style.lineWidth);
    border-color: \(overlay.style.cssValue(environment));
    border-radius: inherit;
    """]
  }
}

// TODO: Implement arbitrary clip paths with CSS `clip-path`
extension _ClipEffect: DOMViewModifier {
  public var isOrderDependent: Bool { true }
  public var attributes: [HTMLAttribute: String] {
    if let roundedRect = shape as? RoundedRectangle {
      return ["style": "border-radius: \(roundedRect.cornerSize.width)px; overflow: hidden;"]
    } else if shape is Circle {
      return ["style": "clip-path: circle(50%);"]
    }
    return [:]
  }
}
