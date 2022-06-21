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

// Layout from the top down.
struct LayoutPass: FiberReconcilerPass {
  func run<R>(
    in reconciler: FiberReconciler<R>,
    root: FiberReconciler<R>.TreeReducer.Result,
    reconcileRoot: FiberReconciler<R>.Fiber,
    caches: FiberReconciler<R>.Caches
  ) where R: FiberRenderer {
    guard let root = root.fiber else { return }
    var fiber = root

    func layoutLoop() {
      while true {
        // As we walk down the tree, ask each `View` for its ideal size.
        sizeThatFits(
          fiber,
          in: reconciler,
          caches: caches
        )
        clean(fiber, caches: caches)

        if let child = fiber.child {
          // Continue down the tree.
          fiber = child
          continue
        }

        while fiber.sibling == nil {
          // After collecting all of our subviews, place them in our bounds on the way
          // back up the tree.
          placeSubviews(fiber, in: reconciler, caches: caches)
          // Exit at the top of the `View` tree
          guard let parent = fiber.parent else { return }
          guard parent !== root else { return }
          // Walk up to the next parent.
          fiber = parent
        }

        // We also place our subviews when moving across to a new sibling.
        placeSubviews(fiber, in: reconciler, caches: caches)

        fiber = fiber.sibling!
      }
    }
    layoutLoop()

    // Continue past the root element to the top of the View hierarchy
    // to ensure everything is placed correctly.
    var layoutNode: FiberReconciler<R>.Fiber? = fiber
    while let fiber = layoutNode {
      caches.updateLayoutCache(for: fiber) { cache in
        fiber.updateCache(&cache.cache, subviews: caches.layoutSubviews(for: fiber))
      }
      sizeThatFits(fiber, in: reconciler, caches: caches)
      placeSubviews(fiber, in: reconciler, caches: caches)
      layoutNode = fiber.parent
    }
  }

  /// Mark any `View`s that are dirty as clean after laying them out.
  func clean<R: FiberRenderer>(
    _ fiber: FiberReconciler<R>.Fiber,
    caches: FiberReconciler<R>.Caches
  ) {
    caches.updateLayoutCache(for: fiber) { cache in
      cache.isDirty = false
    }
    if let alternate = fiber.alternate {
      caches.updateLayoutCache(for: alternate) { cache in
        cache.isDirty = false
      }
    }
  }

  /// Request a size from the fiber's `elementParent`.
  func sizeThatFits<R: FiberRenderer>(
    _ fiber: FiberReconciler<R>.Fiber,
    in reconciler: FiberReconciler<R>,
    caches: FiberReconciler<R>.Caches
  ) {
    guard fiber.element != nil
    else { return }

    // Compute our required size.
    // This does not have to respect the elementParent's proposed size.
    let size = caches.updateLayoutCache(for: fiber) { cache -> CGSize in
      fiber.sizeThatFits(
        proposal: .init(
          fiber.elementParent?.geometry?.dimensions.size ?? reconciler.renderer.sceneSize
        ),
        subviews: caches.layoutSubviews(for: fiber),
        cache: &cache.cache
      )
    }
    let dimensions = ViewDimensions(size: size, alignmentGuides: [:])

    // Update our geometry
    fiber.geometry = .init(
      origin: fiber.geometry?.origin ?? .init(origin: .zero),
      dimensions: dimensions
    )
  }

  func placeSubviews<R: FiberRenderer>(
    _ fiber: FiberReconciler<R>.Fiber,
    in reconciler: FiberReconciler<R>,
    caches: FiberReconciler<R>.Caches
  ) {
    caches.updateLayoutCache(for: fiber) { cache in
      fiber.placeSubviews(
        in: .init(
          origin: .zero,
          size: fiber.geometry?.dimensions.size ?? reconciler.renderer.sceneSize
        ),
        proposal: .init(
          fiber.elementParent?.geometry?.dimensions.size ?? reconciler.renderer.sceneSize
        ),
        subviews: caches.layoutSubviews(for: fiber),
        cache: &cache.cache
      )
    }
  }
}

extension FiberReconcilerPass where Self == LayoutPass {
  static var layout: LayoutPass { .init() }
}
