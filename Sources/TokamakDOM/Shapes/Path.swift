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

public typealias Path = TokamakCore.Path

extension Path: ViewDeferredToRenderer {
  func svgFrom(storage: Storage,
               strokeStyle: StrokeStyle = .init(lineWidth: 0, lineCap: .butt, lineJoin: .miter, miterLimit: 0, dash: [], dashPhase: 0)) -> AnyView {
    // These are a bit less "reactive" than the other types, since we want them to fill the SVG container.
    // Since we don't have direct access to drawing or the sizes of parent components like SwifTUI does,
    // we can't really use the values if we want to keep using Shape for things like background
    let stroke = [
      "stroke-width": "\(strokeStyle.lineWidth)",
      "stroke": "black", // TODO: Use the environment variable "foregroundColor"
    ]
    let uniqueKeys = { (first: String, _: String) in first }
    switch storage {
    case .empty:
      return AnyView(EmptyView())
    case let .rect(rect):
      return AnyView(AnyView(HTML("rect", ["width": "\(rect.size.width)",
                                           "height": "\(rect.size.height)"]
          .merging(stroke, uniquingKeysWith: uniqueKeys))))
    case .ellipse:
      return AnyView(HTML("ellipse", ["cx": "50%", "cy": "50%", "rx": "50%", "ry": "50%"]
          .merging(stroke, uniquingKeysWith: uniqueKeys)))
    case let .roundedRect(roundedRect):
      return AnyView(HTML("rect", [
        "width": "\(roundedRect.rect.size.width)",
        "height": "\(roundedRect.rect.size.height)",
        "rx": "\(roundedRect.cornerRadius)",
        "rx": "\(roundedRect.cornerRadius)",
      ]
        .merging(stroke, uniquingKeysWith: uniqueKeys)))
    case let .stroked(stroked):
      return stroked.path.svgFrom(storage: stroked.path.storage, strokeStyle: stroked.style)
    case let .trimmed(trimmed):
      return trimmed.path.svgFrom(storage: trimmed.path.storage, strokeStyle: strokeStyle) // TODO: Trim the path
    }
  }

  public var deferredBody: AnyView {
    AnyView(HTML("svg", ["style": "width: 100%; height: 100%;"]) {
      svgFrom(storage: storage)
        })
  }
}
