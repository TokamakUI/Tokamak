// Copyright 2020-2021 Tokamak contributors
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

import Foundation
import TokamakCore

public enum SpacerContainerAxis {
  case horizontal, vertical
}

public protocol SpacerContainer {
  var hasSpacer: Bool { get }
  var axis: SpacerContainerAxis { get }
  var fillCrossAxis: Bool { get }
}

public extension SpacerContainer where Self: ParentView {
  var hasSpacer: Bool {
    children
      .compactMap {
        mapAnyView($0) { (v: Spacer) in
          v
        }
      }
      .count > 0 ||
      children.compactMap {
        mapAnyView($0) { (v: SpacerContainer) in
          v
        }
      }
      .filter { $0.axis == axis && $0.hasSpacer }
      .count > 0
  }

  // Does a child SpacerContainer along the opposite axis have a spacer?
  // (e.g., an HStack with a child VStack which contains a spacer)
  // If so, we need to fill the cross-axis so the child can show the correct layout.
  var fillCrossAxis: Bool {
    children
      .compactMap {
        mapAnyView($0) { (v: SpacerContainer) in v }
      }
      .filter { $0.axis != axis && $0.hasSpacer }
      .count > 0
  }
}

extension Spacer: _HTMLPrimitive {
  @_spi(TokamakStaticHTML)
  public var renderedBody: AnyView {
    AnyView(HTML("div", [
      "style": "flex-grow: 1; \(minLength != nil ? "min-width: \(minLength!);" : "")",
    ]))
  }
}
