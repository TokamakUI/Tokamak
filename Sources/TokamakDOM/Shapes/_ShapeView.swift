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

protocol ShapeAttributes {
  func attributes(_ style: ShapeStyle) -> [String: String]
}

extension _StrokedShape: ShapeAttributes {
  func attributes(_ style: ShapeStyle) -> [String: String] {
    if let color = style as? Color {
      return ["style": "stroke: \(color); fill: none;"]
    } else {
      return ["style": "stroke: black; fill: none;"]
    }
  }
}

extension _ShapeView: ViewDeferredToRenderer {
  public var deferredBody: AnyView {
    let path = shape.path(in: .zero).deferredBody
    if let shapeAttributes = shape as? ShapeAttributes {
      return AnyView(HTML("div", shapeAttributes.attributes(style)) { path })
    } else if let color = style as? Color {
      return AnyView(HTML("div", ["style": "fill: \(color);"]) { path })
    } else {
      return path
    }
  }
}
