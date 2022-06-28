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
//  Created by Carson Katri on 6/27/22.
//

import Foundation

private struct AspectRatioLayout: Layout {
  let aspectRatio: CGFloat?
  let contentMode: ContentMode

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    let proposal = proposal.replacingUnspecifiedDimensions()
    let aspectRatio: CGFloat
    if let ratio = self.aspectRatio {
      aspectRatio = ratio
    } else {
      let idealSubviewSize = subviews.first?.sizeThatFits(.unspecified) ?? .zero
      if idealSubviewSize.height == 0 {
        aspectRatio = 0
      } else {
        aspectRatio = idealSubviewSize.width / idealSubviewSize.height
      }
    }
    let maxAxis: Axis
    switch contentMode {
    case .fit:
      if proposal.width == proposal.height {
        if aspectRatio >= 1 {
          maxAxis = .vertical
        } else {
          maxAxis = .horizontal
        }
      } else if proposal.width > proposal.height {
        maxAxis = .horizontal
      } else {
        maxAxis = .vertical
      }
    case .fill:
      if proposal.width == proposal.height {
        if aspectRatio >= 1 {
          maxAxis = .horizontal
        } else {
          maxAxis = .vertical
        }
      } else if proposal.width > proposal.height {
        maxAxis = .vertical
      } else {
        maxAxis = .horizontal
      }
    }
    switch maxAxis {
    case .horizontal:
      return .init(
        width: aspectRatio * proposal.height,
        height: proposal.height
      )
    case .vertical:
      return .init(
        width: proposal.width,
        height: (1 / aspectRatio) * proposal.width
      )
    }
  }

  func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) {
    for subview in subviews {
      subview.place(
        at: .init(x: bounds.midX, y: bounds.midY),
        anchor: .center,
        proposal: .init(bounds.size)
      )
    }
  }
}

public extension _AspectRatioLayout {
  func _visitChildren<V>(_ visitor: V, content: Content) where V: ViewVisitor {
    visitor.visit(
      AspectRatioLayout(
        aspectRatio: aspectRatio,
        contentMode: contentMode
      )
      .callAsFunction {
        content
      }
    )
  }
}
