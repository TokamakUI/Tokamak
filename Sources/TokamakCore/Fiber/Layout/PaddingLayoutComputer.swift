// Copyright 2021 Tokamak contributors
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

/// A `LayoutComputer` that fills its parent.
final class PaddingLayoutComputer: LayoutComputer {
  let proposedSize: CGSize
  let insets: EdgeInsets

  init(proposedSize: CGSize, edges: Edge.Set, insets: EdgeInsets?) {
    self.proposedSize = proposedSize
    self.insets = .init(applying: edges, to: insets ?? EdgeInsets(_all: 10))
  }

  func proposeSize<V>(for child: V, at index: Int, in context: LayoutContext) -> CGSize
    where V: View
  {
    .init(
      width: proposedSize.width - insets.leading - insets.trailing,
      height: proposedSize.height - insets.top - insets.bottom
    )
  }

  func position(_ child: LayoutContext.Child, in context: LayoutContext) -> CGPoint {
    .init(
      x: insets.leading,
      y: insets.top
    )
  }

  func requestSize(in context: LayoutContext) -> CGSize {
    let childSize = context.children.reduce(CGSize.zero) {
      .init(
        width: max($0.width, $1.dimensions.width),
        height: max($0.height, $1.dimensions.height)
      )
    }
    return .init(
      width: childSize.width + insets.leading + insets.trailing,
      height: childSize.height + insets.top + insets.bottom
    )
  }
}

public extension _PaddingLayout {
  static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs {
    .init(inputs: inputs, layoutComputer: { PaddingLayoutComputer(
      proposedSize: $0,
      edges: inputs.content.edges,
      insets: inputs.content.insets
    ) })
  }
}
