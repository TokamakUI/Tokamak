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
//  Created by Carson Katri on 6/16/22.
//

import Foundation

extension FiberReconciler {
  final class Caches {
    var elementIndices = [ObjectIdentifier: Int]()
    var layoutCaches = [ObjectIdentifier: LayoutCache]()
    var layoutSubviews = [ObjectIdentifier: LayoutSubviews]()
    var mutations = [Mutation<Renderer>]()

    struct LayoutCache {
      /// The erased `Layout.Cache` value.
      var cache: AnyLayout.Cache

      /// Cached values for `sizeThatFits` calls.
      var sizeThatFits: [SizeThatFitsRequest: CGSize]

      /// Cached values for `dimensions(in:)` calls.
      var dimensions: [SizeThatFitsRequest: ViewDimensions]

      /// Does this cache need to be updated before using?
      /// Set to `true` whenever the subviews or the container changes.
      var isDirty: Bool

      /// Empty the cached values and flag the cache as dirty.
      mutating func markDirty() {
        isDirty = true
        sizeThatFits.removeAll()
        dimensions.removeAll()
      }

      struct SizeThatFitsRequest: Hashable {
        let proposal: ProposedViewSize

        @inlinable
        init(_ proposal: ProposedViewSize) {
          self.proposal = proposal
        }

        func hash(into hasher: inout Hasher) {
          hasher.combine(proposal.width)
          hasher.combine(proposal.height)
        }
      }
    }

    func clear() {
      elementIndices.removeAll()
      layoutSubviews.removeAll()
      mutations.removeAll()
    }

    func layoutCache(for fiber: Fiber) -> LayoutCache? {
      guard let layout = fiber.layout else { return nil }
      return layoutCaches[
        ObjectIdentifier(fiber),
        default: .init(
          cache: layout.makeCache(subviews: layoutSubviews(for: fiber)),
          sizeThatFits: [:],
          dimensions: [:],
          isDirty: false
        )
      ]
    }

    func updateLayoutCache<R>(for fiber: Fiber, _ action: (inout LayoutCache) -> R) -> R? {
      guard let layout = fiber.layout else { return nil }
      let subviews = layoutSubviews(for: fiber)
      let key = ObjectIdentifier(fiber)
      var cache = layoutCaches[
        key,
        default: .init(
          cache: layout.makeCache(subviews: subviews),
          sizeThatFits: [:],
          dimensions: [:],
          isDirty: false
        )
      ]
      // If the cache is dirty, update it before calling `action`.
      if cache.isDirty {
        layout.updateCache(&cache.cache, subviews: subviews)
        cache.isDirty = false
      }
      defer { layoutCaches[key] = cache }
      return action(&cache)
    }

    func layoutSubviews(for fiber: Fiber) -> LayoutSubviews {
      layoutSubviews[ObjectIdentifier(fiber), default: .init(fiber)]
    }

    func elementIndex(for fiber: Fiber, increment: Bool = false) -> Int {
      let key = ObjectIdentifier(fiber)
      let result = elementIndices[key, default: 0]
      if increment {
        elementIndices[key] = result + 1
      }
      return result
    }
  }
}

protocol FiberReconcilerPass {
  /// Run this pass with the given inputs.
  ///
  /// - Parameter reconciler: The `FiberReconciler` running this pass.
  /// - Parameter root: The node to start the pass from.
  ///                   The top of the `View` hierarchy when `useDynamicLayout` is enabled.
  ///                   Otherwise, the same as `reconcileRoot`.
  /// - Parameter reconcileRoot: A list of topmost nodes that need reconciliation.
  ///                            When `useDynamicLayout` is enabled, this can be used to limit
  ///                            the number of operations performed during reconciliation.
  /// - Parameter caches: The shared cache data for this and other passes.
  func run<R: FiberRenderer>(
    in reconciler: FiberReconciler<R>,
    root: FiberReconciler<R>.TreeReducer.Result,
    changedFibers: Set<ObjectIdentifier>,
    caches: FiberReconciler<R>.Caches
  )
}
