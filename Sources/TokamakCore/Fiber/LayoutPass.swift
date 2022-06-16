//
//  File.swift
//
//
//  Created by Carson Katri on 6/16/22.
//

import Foundation

// Layout from the top down.
struct LayoutPass: FiberReconcilerPass {
  func run<R>(
    in reconciler: FiberReconciler<R>,
    root: FiberReconciler<R>.TreeReducer.Result,
    caches: FiberReconciler<R>.Caches
  ) where R: FiberRenderer {
    if let root = root.fiber {
      var fiber = root

      func layoutLoop() {
        while true {
          sizeThatFits(
            fiber,
            caches: caches,
            proposal: .init(
              fiber.elementParent?.geometry?.dimensions.size ?? reconciler.renderer.sceneSize
            )
          )

          if let child = fiber.child {
            fiber = child
            continue
          }

          while fiber.sibling == nil {
            // Before we walk back up, place our children in our bounds.
            caches.updateLayoutCache(for: fiber) { cache in
              fiber.placeSubviews(
                in: .init(
                  origin: .zero,
                  size: fiber.geometry?.dimensions.size ?? reconciler.renderer.sceneSize
                ),
                proposal: .init(
                  fiber.elementParent?.geometry?.dimensions.size ?? reconciler.renderer
                    .sceneSize
                ),
                subviews: caches.layoutSubviews(for: fiber),
                cache: &cache
              )
            }
            // Exit at the top of the View tree
            guard let parent = fiber.parent else { return }
            guard parent !== root.alternate else { return }
            // Walk up to the next parent.
            fiber = parent
          }

          caches.updateLayoutCache(for: fiber) { cache in
            fiber.placeSubviews(
              in: .init(
                origin: .zero,
                size: fiber.geometry?.dimensions.size ?? reconciler.renderer.sceneSize
              ),
              proposal: .init(
                fiber.elementParent?.geometry?.dimensions.size ?? reconciler.renderer
                  .sceneSize
              ),
              subviews: caches.layoutSubviews(for: fiber),
              cache: &cache
            )
          }

          fiber = fiber.sibling!
        }
      }
      layoutLoop()

      var layoutNode: FiberReconciler<R>.Fiber? = fiber
      while let fiber = layoutNode {
        caches.updateLayoutCache(for: fiber) { cache in
          fiber.placeSubviews(
            in: .init(
              origin: .zero,
              size: fiber.geometry?.dimensions.size ?? reconciler.renderer.sceneSize
            ),
            proposal: .init(
              fiber.elementParent?.geometry?.dimensions.size ?? reconciler.renderer
                .sceneSize
            ),
            subviews: caches.layoutSubviews(for: fiber),
            cache: &cache
          )
        }

        layoutNode = fiber.parent
      }
    }
  }

  /// Request a size from the fiber's `elementParent`.
  func sizeThatFits<R: FiberRenderer>(
    _ node: FiberReconciler<R>.Fiber,
    caches: FiberReconciler<R>.Caches,
    proposal: ProposedViewSize
  ) {
    guard node.element != nil
    else { return }

    // Compute our required size.
    // This does not have to respect the elementParent's proposed size.
    let size = caches.updateLayoutCache(for: node) { cache in
      node.sizeThatFits(
        proposal: proposal,
        subviews: caches.layoutSubviews(for: node),
        cache: &cache
      )
    }
    let dimensions = ViewDimensions(size: size, alignmentGuides: [:])

    // Update our geometry
    node.geometry = .init(
      origin: node.geometry?.origin ?? .init(origin: .zero),
      dimensions: dimensions
    )
  }
}

extension FiberReconcilerPass where Self == LayoutPass {
  static var layout: LayoutPass { .init() }
}
