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
//  Created by Carson Katri on 6/15/22.
//

import Foundation

extension FiberReconciler.Fiber: Layout {
  public func makeCache(subviews: Subviews) -> Any {
    layout.makeCache(subviews)
  }

  public func updateCache(_ cache: inout Any, subviews: Subviews) {
    layout.updateCache(&cache, subviews)
  }

  public func spacing(subviews: Subviews, cache: inout Any) -> ViewSpacing {
    if case let .view(view, _) = content,
       view is Text
    {
      let spacing = ViewSpacing(
        viewType: Text.self,
        top: { $0.viewType == Text.self ? 0 : ViewSpacing.defaultValue },
        leading: { _ in ViewSpacing.defaultValue },
        bottom: { $0.viewType == Text.self ? 0 : ViewSpacing.defaultValue },
        trailing: { _ in ViewSpacing.defaultValue }
      )
      return spacing
    } else {
      return layout.spacing(subviews, &cache)
    }
  }

  public func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout Any
  ) -> CGSize {
    if case let .view(view, _) = content,
       let text = view as? Text
    {
      return self.reconciler?.renderer.measureText(
        text, proposal: proposal, in: self.outputs.environment.environment
      ) ?? .zero
    } else {
      return layout.sizeThatFits(proposal, subviews, &cache)
    }
  }

  public func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout Any
  ) {
    layout.placeSubviews(bounds, proposal, subviews, &cache)
  }

  public func explicitAlignment(
    of guide: HorizontalAlignment,
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout Any
  ) -> CGFloat? {
    layout.explicitHorizontalAlignment(guide, bounds, proposal, subviews, &cache)
  }

  public func explicitAlignment(
    of guide: VerticalAlignment,
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout Any
  ) -> CGFloat? {
    layout.explicitVerticalAlignment(guide, bounds, proposal, subviews, &cache)
  }
}

public struct LayoutActions {
  let makeCache: (LayoutSubviews) -> Any
  let updateCache: (inout Any, LayoutSubviews) -> ()
  let spacing: (LayoutSubviews, inout Any) -> ViewSpacing
  let sizeThatFits: (ProposedViewSize, LayoutSubviews, inout Any) -> CGSize
  let placeSubviews: (CGRect, ProposedViewSize, LayoutSubviews, inout Any) -> ()
  let explicitHorizontalAlignment: (
    HorizontalAlignment, CGRect, ProposedViewSize, LayoutSubviews, inout Any
  ) -> CGFloat?
  let explicitVerticalAlignment: (
    VerticalAlignment, CGRect, ProposedViewSize, LayoutSubviews, inout Any
  ) -> CGFloat?

  private static func useCache<C, R>(_ cache: inout Any, _ action: (inout C) -> R) -> R {
    guard var typedCache = cache as? C else { fatalError("Cache mismatch") }
    let result = action(&typedCache)
    cache = typedCache
    return result
  }

  init<L: Layout>(_ layout: L) {
    makeCache = { layout.makeCache(subviews: $0) }
    updateCache = { cache, subviews in
      Self.useCache(&cache) { layout.updateCache(&$0, subviews: subviews) }
    }
    spacing = { subviews, cache in
      Self.useCache(&cache) { layout.spacing(subviews: subviews, cache: &$0) }
    }
    sizeThatFits = { proposal, subviews, cache in
      Self
        .useCache(&cache) {
          layout.sizeThatFits(proposal: proposal, subviews: subviews, cache: &$0)
        }
    }
    placeSubviews = { bounds, proposal, subviews, cache in
      Self.useCache(&cache) {
        layout.placeSubviews(in: bounds, proposal: proposal, subviews: subviews, cache: &$0)
      }
    }
    explicitHorizontalAlignment = { alignment, bounds, proposal, subviews, cache in
      Self.useCache(&cache) {
        layout.explicitAlignment(
          of: alignment, in: bounds, proposal: proposal, subviews: subviews, cache: &$0
        )
      }
    }
    explicitVerticalAlignment = { alignment, bounds, proposal, subviews, cache in
      Self.useCache(&cache) {
        layout.explicitAlignment(
          of: alignment, in: bounds, proposal: proposal, subviews: subviews, cache: &$0
        )
      }
    }
  }
}
