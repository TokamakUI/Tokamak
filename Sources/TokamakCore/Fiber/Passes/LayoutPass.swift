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
    changedFibers: Set<ObjectIdentifier>,
    caches: FiberReconciler<R>.Caches
  ) where R: FiberRenderer {
    guard let root = root.fiber else { return }
    var fiber = root

    while true {
      // Place subviews for each element fiber as we walk the tree.
      if fiber.element != nil {
        caches.updateLayoutCache(for: fiber) { cache in
          fiber.layout?.placeSubviews(
            in: .init(
              origin: .zero,
              size: fiber.geometry?.dimensions.size ?? reconciler.renderer.sceneSize.value
            ),
            proposal: fiber.geometry?.proposal ?? .unspecified,
            subviews: caches.layoutSubviews(for: fiber),
            cache: &cache.cache
          )
        }
      }

      if let child = fiber.child {
        // Continue down the tree.
        fiber = child
        continue
      }

      while fiber.sibling == nil {
        // Exit at the top of the `View` tree
        guard let parent = fiber.parent else { return }
        guard parent !== root else { return }
        // Walk up to the next parent.
        fiber = parent
      }

      // Walk across to the next sibling.
      fiber = fiber.sibling!
    }
  }
}

extension FiberReconcilerPass where Self == LayoutPass {
  static var layout: LayoutPass { .init() }
}
