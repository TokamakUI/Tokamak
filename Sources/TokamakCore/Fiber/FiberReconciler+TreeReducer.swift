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
//  Created by Carson Katri on 5/28/22.
//

import Foundation

extension FiberReconciler {
  /// Convert the first level of children of a `View` into a linked list of `Fiber`s.
  struct TreeReducer: SceneReducer {
    final class Result {
      // For references
      let fiber: Fiber?
      let visitChildren: (TreeReducer.SceneVisitor) -> ()
      unowned var parent: Result?
      var child: Result?
      var sibling: Result?
      var nextTraits: _ViewTraitStore

      // For reducing
      var lastSibling: Result?
      var processedChildCount: Int
      var unclaimedCurrentChildren: [Int: Fiber]

      // Side-effects
      var didInsert: Bool
      var newContent: Renderer.ElementType.Content?

      init(
        fiber: Fiber?,
        currentChildren: [Int: Fiber],
        visitChildren: @escaping (TreeReducer.SceneVisitor) -> (),
        parent: Result?,
        newContent: Renderer.ElementType.Content? = nil,
        nextTraits: _ViewTraitStore
      ) {
        self.fiber = fiber
        self.visitChildren = visitChildren
        self.parent = parent
        self.nextTraits = nextTraits

        processedChildCount = 0
        unclaimedCurrentChildren = currentChildren

        didInsert = false
        self.newContent = nil
      }
    }

    static func reduce<S>(into partialResult: inout Result, nextScene: S) where S: Scene {
      Self.reduce(
        into: &partialResult,
        nextValue: nextScene,
        createFiber: { scene, element, parent, elementParent, preferenceParent, _, _, reconciler in
          Fiber(
            &scene,
            element: element,
            parent: parent,
            elementParent: elementParent,
            preferenceParent: preferenceParent,
            environment: nil,
            reconciler: reconciler
          )
        },
        update: { fiber, scene, _, _ in
          fiber.update(with: &scene)
        },
        visitChildren: { $1._visitChildren },
        isPrimitive: { _ in false }
      )
    }

    static func reduce<V>(into partialResult: inout Result, nextView: V) where V: View {
      Self.reduce(
        into: &partialResult,
        nextValue: nextView,
        createFiber: {
          view, element,
            parent, elementParent, preferenceParent, elementIndex,
            traits, reconciler in
          Fiber(
            &view,
            element: element,
            parent: parent,
            elementParent: elementParent,
            preferenceParent: preferenceParent,
            elementIndex: elementIndex,
            traits: traits,
            reconciler: reconciler
          )
        },
        update: { fiber, view, elementIndex, traits in
          fiber.update(
            with: &view,
            elementIndex: elementIndex,
            traits: fiber.element != nil ? traits : nil
          )
        },
        visitChildren: { reconciler, view in
          reconciler?.renderer.viewVisitor(for: view) ?? view._visitChildren
        },
        isPrimitive: { view in
          Renderer.isPrimitive(view)
        }
      )
    }

    static func reduce<T>(
      into partialResult: inout Result,
      nextValue: T,
      createFiber: (
        inout T,
        Renderer.ElementType?,
        Fiber?,
        Fiber?,
        Fiber?,
        Int?,
        _ViewTraitStore,
        FiberReconciler?
      ) -> Fiber,
      update: (Fiber, inout T, Int?, _ViewTraitStore) -> Renderer.ElementType.Content?,
      visitChildren: (FiberReconciler?, T) -> (TreeReducer.SceneVisitor) -> (),
      isPrimitive: (T) -> Bool
    ) {
      // Create the node and its element.
      var nextValue = nextValue

      let explicitId = (nextValue as? _AnyIDView)?.anyId
      let childIndex = partialResult.processedChildCount

      let resultChild: Result
      if let existing = partialResult.unclaimedCurrentChildren[childIndex],
         existing.typeInfo?.type == typeInfo(of: T.self)?.type,
         existing.explicitId == explicitId
      {
        partialResult.unclaimedCurrentChildren.removeValue(forKey: childIndex)
        existing.sibling = nil
        let traits = isPrimitive(nextValue) ? .init() : partialResult.nextTraits
        let c = update(existing, &nextValue, nil, traits)
        resultChild = Result(
          fiber: existing,
          currentChildren: existing.mappedChildren,
          visitChildren: visitChildren(partialResult.fiber?.reconciler, nextValue),
          parent: partialResult,
          nextTraits: traits
        )
        resultChild.newContent = c
      } else {
        let elementParent = partialResult.fiber?.element != nil
          ? partialResult.fiber
          : partialResult.fiber?.elementParent
        let preferenceParent = partialResult.fiber?.preferences != nil
          ? partialResult.fiber
          : partialResult.fiber?.preferenceParent
        let fiber = createFiber(
          &nextValue,
          nil,
          partialResult.fiber,
          elementParent,
          preferenceParent,
          nil,
          partialResult.nextTraits,
          partialResult.fiber?.reconciler
        )
        let traits: _ViewTraitStore
        if isPrimitive(nextValue) {
          traits = .init()
        } else {
          traits = partialResult.nextTraits
        }

        resultChild = Result(
          fiber: fiber,
          currentChildren: [:],
          visitChildren: visitChildren(partialResult.fiber?.reconciler, nextValue),
          parent: partialResult,
          nextTraits: traits
        )

        resultChild.didInsert = true
      }

      partialResult.processedChildCount += 1

      // Get the last child element we've processed, and add the new child as its sibling.
      if let lastSibling = partialResult.lastSibling {
        lastSibling.fiber?.sibling = resultChild.fiber
        lastSibling.sibling = resultChild
      } else {
        // Otherwise setup the first child
        partialResult.fiber?.child = resultChild.fiber
        partialResult.child = resultChild
      }
      partialResult.lastSibling = resultChild
    }
  }
}
