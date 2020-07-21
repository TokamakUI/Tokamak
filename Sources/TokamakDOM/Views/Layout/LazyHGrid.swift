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
//  Created by Carson Katri on 7/13/20.
//

import TokamakCore

extension LazyHGrid: SpacerContainer {
  var axis: SpacerContainerAxis { .horizontal }
  var hasSpacer: Bool { false }
  var fillCrossAxis: Bool {
    _LazyHGridProxy(self).rows.contains {
      if case .adaptive(minimum: _, maximum: _) = $0.size {
        return true
      } else {
        return false
      }
    }
  }
}

extension LazyHGrid: ViewDeferredToRenderer {
  var lastRow: GridItem? {
    _LazyHGridProxy(self).rows.last
  }

  public var deferredBody: AnyView {
    var styles = """
    display: grid;
    grid-template-rows: \(_LazyHGridProxy(self)
      .rows
      .map(\.description)
      .joined(separator: " "));
    grid-auto-flow: column;
    """
    if fillCrossAxis {
      styles += "height: 100%;"
    }
    // CSS Grid doesn't let these be specified for specific rows
    if let lastRow = lastRow {
      styles += "justify-items: \(lastRow.alignment.horizontal.cssValue);"
      styles += "align-items: \(lastRow.alignment.vertical.cssValue);"
    }
    styles += "grid-gap: \(_LazyHGridProxy(self).spacing)px;"
    return AnyView(HTML("div", ["style": styles]) {
      _LazyHGridProxy(self).content
    })
  }
}
