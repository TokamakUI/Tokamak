//
//  File.swift
//
//
//  Created by Carson Katri on 6/16/22.
//

import Foundation

/// Walk the current tree, recomputing at each step to check for discrepancies.
///
/// Parent-first depth-first traversal.
/// Take this `View` tree for example.
/// ```swift
/// VStack {
///   HStack {
///     Text("A")
///     Text("B")
///   }
///   Text("C")
/// }
/// ```
/// Basically, we read it like this:
/// 1. `VStack` has children, so we go to it's first child, `HStack`.
/// 2. `HStack` has children, so we go further to it's first child, `Text`.
/// 3. `Text` has no child, but has a sibling, so we go to that.
/// 4. `Text` has no child and no sibling, so we return to the `HStack`.
/// 5. We've already read the children, so we look for a sibling, `Text`.
/// 6. `Text` has no children and no sibling, so we return to the `VStack.`
/// We finish once we've returned to the root element.
/// ```
///    ┌──────┐
///    │VStack│
///    └──┬───┘
///   ▲ 1 │
///   │   └──►┌──────┐
///   │       │HStack│
///   │     ┌─┴───┬──┘
///   │     │   ▲ │ 2
///   │     │   │ │  ┌────┐
///   │     │   │ └─►│Text├─┐
/// 6 │     │ 4 │    └────┘ │
///   │     │   │           │ 3
///   │   5 │   │    ┌────┐ │
///   │     │   └────┤Text│◄┘
///   │     │        └────┘
///   │     │
///   │     └►┌────┐
///   │       │Text│
///   └───────┴────┘
/// ```
struct ReconcilePass: FiberReconcilerPass {
  func run<R>(
    in reconciler: FiberReconciler<R>,
    root: FiberReconciler<R>.TreeReducer.Result,
    reconcileRoot: FiberReconciler<R>.Fiber,
    caches: FiberReconciler<R>.Caches
  ) where R: FiberRenderer {
    var node = root

    /// Enabled when we reach the `reconcileRoot`.
    var shouldReconcile = false

    while true {
      if node.fiber === reconcileRoot || node.fiber?.alternate === reconcileRoot {
        shouldReconcile = true
      }

      // If this fiber has an element, set its `elementIndex`
      // and increment the `elementIndices` value for its `elementParent`.
      if node.fiber?.element != nil,
         let elementParent = node.fiber?.elementParent
      {
        node.fiber?.elementIndex = caches.elementIndex(for: elementParent, increment: true)
      }

      // Perform work on the node.
      if shouldReconcile,
         let mutation = reconcile(node, in: reconciler, caches: caches)
      {
        caches.mutations.append(mutation)
      }

      // Ensure the TreeReducer can access the `elementIndices`.
      node.elementIndices = caches.elementIndices

      // Compute the children of the node.
      let reducer = FiberReconciler<R>.TreeReducer.SceneVisitor(initialResult: node)
      node.visitChildren(reducer)

      if reconciler.renderer.useDynamicLayout,
         let fiber = node.fiber
      {
        if let element = fiber.element,
           let elementParent = fiber.elementParent
        {
          caches.appendChild(parent: elementParent, child: fiber)
          let parentKey = ObjectIdentifier(elementParent)
          var subviews = caches.layoutSubviews[parentKey, default: .init(elementParent)]
          subviews.storage.append(LayoutSubview(
            id: ObjectIdentifier(node),
            sizeThatFits: { [weak fiber, unowned caches] proposal in
              guard let fiber = fiber else { return .zero }
              return caches.updateLayoutCache(for: fiber) { cache in
                if let size = cache.sizeThatFits[.init(proposal)] {
                  return size
                } else {
                  let size = fiber.sizeThatFits(
                    proposal: proposal,
                    subviews: caches.layoutSubviews(for: fiber),
                    cache: &cache.cache
                  )
                  cache.sizeThatFits[.init(proposal)] = size
                  if let alternate = fiber.alternate {
                    caches.updateLayoutCache(for: alternate) { cache in
                      cache.sizeThatFits[.init(proposal)] = size
                    }
                  }
                  return size
                }
              }
            },
            dimensions: { sizeThatFits in
              // TODO: Add `alignmentGuide` modifier and pass into `ViewDimensions`
              ViewDimensions(size: sizeThatFits, alignmentGuides: [:])
            },
            place: { [weak fiber, weak element, unowned caches] dimensions, position, anchor in
              guard let fiber = fiber, let element = element else { return }
              let geometry = ViewGeometry(
                // Shift to the anchor point in the parent's coordinate space.
                origin: .init(origin: .init(
                  x: position.x - (dimensions.width * anchor.x),
                  y: position.y - (dimensions.height * anchor.y)
                )),
                dimensions: dimensions
              )
              // Push a layout mutation if needed.
              if geometry != fiber.alternate?.geometry {
                caches.mutations.append(.layout(element: element, geometry: geometry))
              }
              // Update ours and our alternate's geometry
              fiber.geometry = geometry
              fiber.alternate?.geometry = geometry
            },
            spacing: { [weak fiber, unowned caches] in
              guard let fiber = fiber else { return .init() }

              return caches.updateLayoutCache(for: fiber) { cache in
                fiber.spacing(
                  subviews: caches.layoutSubviews(for: fiber),
                  cache: &cache.cache
                )
              }
            }
          ))
          caches.layoutSubviews[parentKey] = subviews
        }
      }

      // Setup the alternate if it doesn't exist yet.
      if node.fiber?.alternate == nil {
        _ = node.fiber?.createAndBindAlternate?()
      }

      // Walk all down all the way into the deepest child.
      if let child = reducer.result.child {
        node = child
        continue
      } else if let alternateChild = node.fiber?.alternate?.child {
        // The alternate has a child that no longer exists.
        if let parent = node.fiber {
          invalidateCache(for: parent, in: reconciler, caches: caches)
        }
        walk(alternateChild) { node in
          if let element = node.element,
             let parent = node.elementParent?.element
          {
            // Removals must happen in reverse order, so a child element
            // is removed before its parent.
            caches.mutations.insert(.remove(element: element, parent: parent), at: 0)
          }
          return true
        }
      }
      if reducer.result.child == nil {
        // Make sure we clear the child if there was none
        node.fiber?.child = nil
        node.fiber?.alternate?.child = nil
      }

      // If we've made it back to the root, then exit.
      if node === root {
        return
      }

      // Now walk back up the tree until we find a sibling.
      while node.sibling == nil {
        // Update the layout cache so it's ready for this render.
        updateCache(for: node, in: reconciler, caches: caches)

        var alternateSibling = node.fiber?.alternate?.sibling
        // The alternate had siblings that no longer exist.
        while alternateSibling != nil {
          if let fiber = alternateSibling?.parent {
            invalidateCache(for: fiber, in: reconciler, caches: caches)
          }
          if let element = alternateSibling?.element,
             let parent = alternateSibling?.elementParent?.element
          {
            // Removals happen in reverse order, so a child element is removed before
            // its parent.
            caches.mutations.insert(.remove(element: element, parent: parent), at: 0)
          }
          alternateSibling = alternateSibling?.sibling
        }
        guard let parent = node.parent else { return }
        // When we walk back to the root, exit
        guard parent !== root.fiber?.alternate else { return }
        node = parent
      }

      updateCache(for: node, in: reconciler, caches: caches)

      // Walk across to the sibling, and repeat.
      node = node.sibling!
    }
  }

  /// Compare `node` with its alternate, and add any mutations to the list.
  func reconcile<R: FiberRenderer>(
    _ node: FiberReconciler<R>.TreeReducer.Result,
    in reconciler: FiberReconciler<R>,
    caches: FiberReconciler<R>.Caches
  ) -> Mutation<R>? {
    if let element = node.fiber?.element,
       let index = node.fiber?.elementIndex,
       let parent = node.fiber?.elementParent?.element
    {
      if node.fiber?.alternate == nil { // This didn't exist before (no alternate)
        if let fiber = node.fiber {
          invalidateCache(for: fiber, in: reconciler, caches: caches)
        }
        return .insert(element: element, parent: parent, index: index)
      } else if node.fiber?.typeInfo?.type != node.fiber?.alternate?.typeInfo?.type,
                let previous = node.fiber?.alternate?.element
      {
        if let fiber = node.fiber {
          invalidateCache(for: fiber, in: reconciler, caches: caches)
        }
        // This is a completely different type of view.
        return .replace(parent: parent, previous: previous, replacement: element)
      } else if let newContent = node.newContent,
                newContent != element.content
      {
        if let fiber = node.fiber {
          invalidateCache(for: fiber, in: reconciler, caches: caches)
        }
        // This is the same type of view, but its backing data has changed.
        return .update(
          previous: element,
          newContent: newContent,
          geometry: node.fiber?.geometry ?? .init(
            origin: .init(origin: .zero),
            dimensions: .init(size: .zero, alignmentGuides: [:])
          )
        )
      }
    }
    return nil
  }

  /// Update the layout cache for a `Fiber`.
  func updateCache<R: FiberRenderer>(
    for node: FiberReconciler<R>.TreeReducer.Result,
    in reconciler: FiberReconciler<R>,
    caches: FiberReconciler<R>.Caches
  ) {
    guard reconciler.renderer.useDynamicLayout,
          let fiber = node.fiber
    else { return }
    caches.updateLayoutCache(for: fiber) { cache in
      fiber.updateCache(&cache.cache, subviews: caches.layoutSubviews(for: fiber))
      var sibling = fiber.child
      while let fiber = sibling {
        sibling = fiber.sibling
        if let childCache = caches.layoutCaches[.init(fiber)],
           childCache.isDirty
        {
          cache.sizeThatFits.removeAll()
          cache.isDirty = true
          if let alternate = fiber.alternate {
            caches.updateLayoutCache(for: alternate) { cache in
              cache.sizeThatFits.removeAll()
              cache.isDirty = true
            }
          }
          return
        }
      }
    }
  }

  /// Remove cached size values if something changed.
  func invalidateCache<R: FiberRenderer>(
    for fiber: FiberReconciler<R>.Fiber,
    in reconciler: FiberReconciler<R>,
    caches: FiberReconciler<R>.Caches
  ) {
    guard reconciler.renderer.useDynamicLayout else { return }
    caches.updateLayoutCache(for: fiber) { cache in
      cache.sizeThatFits.removeAll()
      cache.isDirty = true
    }
    if let alternate = fiber.alternate {
      caches.updateLayoutCache(for: alternate) { cache in
        cache.sizeThatFits.removeAll()
        cache.isDirty = true
      }
    }
  }
}

extension FiberReconcilerPass where Self == ReconcilePass {
  static var reconcile: ReconcilePass { ReconcilePass() }
}
