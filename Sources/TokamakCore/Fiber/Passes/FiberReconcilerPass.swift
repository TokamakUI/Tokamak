//
//  File.swift
//
//
//  Created by Carson Katri on 6/16/22.
//

import Foundation

extension FiberReconciler {
  final class Caches {
    var elementIndices = [ObjectIdentifier: Int]()
    var layoutCaches = [ObjectIdentifier: LayoutCache]()
    var layoutSubviews = [ObjectIdentifier: LayoutSubviews]()
    var elementChildren = [ObjectIdentifier: [Fiber]]()
    var mutations = [Mutation<Renderer>]()

    struct LayoutCache {
      var cache: Any
      var sizeThatFits: [SizeThatFitsRequest: CGSize]
      var dimensions: [SizeThatFitsRequest: ViewDimensions]
      var isDirty: Bool

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

    @inlinable
    func clear() {
      elementIndices = [:]
      layoutSubviews = [:]
      elementChildren = [:]
      mutations = []
    }

    @inlinable
    func updateLayoutCache<R>(for fiber: Fiber, _ action: (inout LayoutCache) -> R) -> R {
      let key = ObjectIdentifier(fiber)
      var cache = layoutCaches[
        key,
        default: .init(
          cache: fiber.makeCache(subviews: layoutSubviews(for: fiber)),
          sizeThatFits: [:],
          dimensions: [:],
          isDirty: false
        )
      ]
      defer { layoutCaches[key] = cache }
      return action(&cache)
    }

    @inlinable
    func layoutSubviews(for fiber: Fiber) -> LayoutSubviews {
      layoutSubviews[ObjectIdentifier(fiber), default: .init(fiber)]
    }

    @inlinable
    func elementIndex(for fiber: Fiber, increment: Bool = false) -> Int {
      let key = ObjectIdentifier(fiber)
      let result = elementIndices[key, default: 0]
      if increment {
        elementIndices[key] = result + 1
      }
      return result
    }

    @inlinable
    func appendChild(parent: Fiber, child: Fiber) {
      elementChildren[ObjectIdentifier(parent), default: []].append(child)
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
  /// - Parameter reconcileRoot: The topmost node that needs reconciliation.
  ///                            When `useDynamicLayout` is enabled, this can be used to limit
  ///                            the number of operations performed during reconciliation.
  /// - Parameter caches: The shared cache data for this and other passes.
  func run<R: FiberRenderer>(
    in reconciler: FiberReconciler<R>,
    root: FiberReconciler<R>.TreeReducer.Result,
    reconcileRoot: FiberReconciler<R>.Fiber,
    caches: FiberReconciler<R>.Caches
  )
}
