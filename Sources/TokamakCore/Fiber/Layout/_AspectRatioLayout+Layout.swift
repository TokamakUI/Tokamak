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
    let aspectRatio: CGFloat
    let maxAxis: Axis
    if let ratio = self.aspectRatio {
      aspectRatio = ratio
      maxAxis = ratio > 1 ? .horizontal : .vertical
    } else {
      let idealSubviewSize = subviews.first?.sizeThatFits(.unspecified) ?? .zero
      if idealSubviewSize.height == 0 {
        aspectRatio = 0
      } else {
        aspectRatio = idealSubviewSize.width / idealSubviewSize.height
      }
      maxAxis = idealSubviewSize.width > idealSubviewSize.height ? .horizontal : .vertical
    }
    let proposal = proposal.replacingUnspecifiedDimensions()
    let widthRatio = aspectRatio
    let heightRatio = 1 / aspectRatio
    switch contentMode {
    case .fit:
      if maxAxis == .horizontal {
        return .init(
          width: proposal.width,
          height: heightRatio * proposal.width
        )
      } else {
        return .init(
          width: widthRatio * proposal.width,
          height: proposal.height
        )
      }
    case .fill:
      if maxAxis == .horizontal {
        return .init(
          width: widthRatio * proposal.width,
          height: proposal.width
        )
      } else {
        return .init(
          width: proposal.width,
          height: heightRatio * proposal.height
        )
      }
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
