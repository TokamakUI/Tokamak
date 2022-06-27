// Copyright 2022 Tokamak contributors
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
//  Created by Carson Katri on 2/17/22.
//

import Foundation

public struct ViewGeometry: Equatable {
  @_spi(TokamakCore)
  public let origin: ViewOrigin

  @_spi(TokamakCore)
  public let dimensions: ViewDimensions

  let proposal: ProposedViewSize
}

/// The position of the `View` relative to its parent.
public struct ViewOrigin: Equatable {
  @_spi(TokamakCore)
  public let origin: CGPoint

  @_spi(TokamakCore)
  public var x: CGFloat { origin.x }
  @_spi(TokamakCore)
  public var y: CGFloat { origin.y }
}

public struct ViewDimensions: Equatable {
  @_spi(TokamakCore)
  public let size: CGSize

  @_spi(TokamakCore)
  public let alignmentGuides: [ObjectIdentifier: CGFloat]

  public var width: CGFloat { size.width }
  public var height: CGFloat { size.height }

  public subscript(guide: HorizontalAlignment) -> CGFloat {
    self[explicit: guide] ?? guide.id.defaultValue(in: self)
  }

  public subscript(guide: VerticalAlignment) -> CGFloat {
    self[explicit: guide] ?? guide.id.defaultValue(in: self)
  }

  public subscript(explicit guide: HorizontalAlignment) -> CGFloat? {
    alignmentGuides[.init(guide.id)]
  }

  public subscript(explicit guide: VerticalAlignment) -> CGFloat? {
    alignmentGuides[.init(guide.id)]
  }
}
