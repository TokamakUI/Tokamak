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
    var layoutCaches = [ObjectIdentifier: Any]()
    var layoutSubviews = [ObjectIdentifier: LayoutSubviews]()
    var elementChildren = [ObjectIdentifier: [Fiber]]()
    var mutations = [Mutation<Renderer>]()

    @inlinable
    func updateLayoutCache<R>(for fiber: Fiber, _ action: (inout Any) -> R) -> R {
      let key = ObjectIdentifier(fiber)
      var cache = layoutCaches[
        key,
        default: fiber.makeCache(subviews: layoutSubviews(for: fiber))
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
      let key = ObjectIdentifier(parent)
      elementChildren[key] = elementChildren[key, default: []] + [child]
    }
  }
}

protocol FiberReconcilerPass {
  func run<R: FiberRenderer>(
    in reconciler: FiberReconciler<R>,
    root: FiberReconciler<R>.TreeReducer.Result,
    caches: FiberReconciler<R>.Caches
  )
}
