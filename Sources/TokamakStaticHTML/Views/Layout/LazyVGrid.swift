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

extension LazyVGrid: SpacerContainer {
  public var axis: SpacerContainerAxis { .vertical }
  public var hasSpacer: Bool { false }
  public var fillCrossAxis: Bool {
    _LazyVGridProxy(self).columns.contains {
      if case .adaptive(minimum: _, maximum: _) = $0.size {
        return true
      } else {
        return false
      }
    }
  }
}

extension LazyVGrid: _HTMLPrimitive {
  var lastColumn: GridItem? {
    _LazyVGridProxy(self).columns.last
  }

  @_spi(TokamakStaticHTML)
  public var renderedBody: AnyView {
    var styles = """
    display: grid;
    grid-template-columns: \(_LazyVGridProxy(self)
      .columns
      .map(\.description)
      .joined(separator: " "));
    grid-auto-flow: row;
    """
    if fillCrossAxis {
      styles += "width: 100%;"
    }
    // CSS Grid doesn't let these be specified for specific columns
    if let lastCol = lastColumn {
      styles += "justify-items: \(lastCol.alignment.horizontal.cssValue);"
      styles += "align-items: \(lastCol.alignment.vertical.cssValue);"
    }
    styles += "grid-gap: \(_LazyVGridProxy(self).spacing)px;"
    return AnyView(HTML("div", ["style": styles]) {
      _LazyVGridProxy(self).content
    })
  }
}
