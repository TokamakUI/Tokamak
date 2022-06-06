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
//  Created by Carson Katri on 5/24/22.
//

import Foundation

/// A `LayoutComputer` that shrinks to the size of its children.
@_spi(TokamakCore)
public struct ShrinkWrapLayoutComputer: LayoutComputer {
  let proposedSize: CGSize

  public init(proposedSize: CGSize) {
    self.proposedSize = proposedSize
  }

  public func proposeSize<V>(for child: V, at index: Int, in context: LayoutContext) -> CGSize
    where V: View
  {
    proposedSize
  }

  public func position(_ child: LayoutContext.Child, in context: LayoutContext) -> CGPoint {
    .zero
  }

  public func requestSize(in context: LayoutContext) -> CGSize {
    context.children.reduce(CGSize.zero) {
      .init(
        width: max($0.width, $1.dimensions.width),
        height: max($0.height, $1.dimensions.height)
      )
    }
  }
}
