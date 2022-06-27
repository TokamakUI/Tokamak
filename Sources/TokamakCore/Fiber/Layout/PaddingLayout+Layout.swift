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
//  Created by Carson Katri on 5/28/22.
//

import Foundation

private extension EdgeInsets {
  init(applying edges: Edge.Set, to insets: EdgeInsets) {
    self.init(
      top: edges.contains(.top) ? insets.top : 0,
      leading: edges.contains(.leading) ? insets.leading : 0,
      bottom: edges.contains(.bottom) ? insets.bottom : 0,
      trailing: edges.contains(.trailing) ? insets.trailing : 0
    )
  }
}

private struct PaddingLayout: Layout {
  let edges: Edge.Set
  let insets: EdgeInsets?

  func spacing(subviews: Subviews, cache: inout ()) -> ViewSpacing {
    .init()
  }

  public func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) -> CGSize {
    let proposal = proposal.replacingUnspecifiedDimensions()
    let insets = EdgeInsets(applying: edges, to: insets ?? .init(_all: 10))
    let subviewSize = subviews.first?.sizeThatFits(
      .init(
        width: proposal.width - insets.leading - insets.trailing,
        height: proposal.height - insets.top - insets.bottom
      )
    ) ?? .zero
    return .init(
      width: subviewSize.width + insets.leading + insets.trailing,
      height: subviewSize.height + insets.top + insets.bottom
    )
  }

  public func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) {
    let insets = EdgeInsets(applying: edges, to: insets ?? .init(_all: 10))
    let proposal = proposal.replacingUnspecifiedDimensions()
    for subview in subviews {
      subview.place(
        at: .init(x: bounds.minX + insets.leading, y: bounds.minY + insets.top),
        proposal: .init(
          width: proposal.width - insets.leading - insets.trailing,
          height: proposal.height - insets.top - insets.bottom
        )
      )
    }
  }
}

public extension _PaddingLayout {
  func _visitChildren<V>(_ visitor: V, content: Content) where V: ViewVisitor {
    visitor.visit(PaddingLayout(edges: edges, insets: insets).callAsFunction {
      content
    })
  }
}
