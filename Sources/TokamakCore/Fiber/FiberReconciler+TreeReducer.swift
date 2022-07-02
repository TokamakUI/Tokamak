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
      var newContent: Renderer.ElementType.Content?
      var elementIndices: [ObjectIdentifier: Int]
      var nextTraits: _ViewTraitStore

      // For reducing
      var lastSibling: Result?
      var nextExisting: Fiber?
      var nextExistingAlternate: Fiber?

      init(
        fiber: Fiber?,
        visitChildren: @escaping (TreeReducer.SceneVisitor) -> (),
        parent: Result?,
        child: Fiber?,
        alternateChild: Fiber?,
        newContent: Renderer.ElementType.Content? = nil,
        elementIndices: [ObjectIdentifier: Int],
        nextTraits: _ViewTraitStore
      ) {
        self.fiber = fiber
        self.visitChildren = visitChildren
        self.parent = parent
        nextExisting = child
        nextExistingAlternate = alternateChild
        self.newContent = newContent
        self.elementIndices = elementIndices
        self.nextTraits = nextTraits
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
        visitChildren: { $1._visitChildren }
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
      visitChildren: (FiberReconciler?, T) -> (TreeReducer.SceneVisitor) -> ()
    ) {
      // Create the node and its element.
      var nextValue = nextValue

      let resultChild: Result
      if let existing = partialResult.nextExisting {
        // If a fiber already exists, simply update it with the new view.
        let key: ObjectIdentifier?
        if let elementParent = existing.elementParent {
          key = ObjectIdentifier(elementParent)
        } else {
          key = nil
        }
        let newContent = update(
          existing,
          &nextValue,
          key.map { partialResult.elementIndices[$0, default: 0] },
          partialResult.nextTraits
        )
        resultChild = Result(
          fiber: existing,
          visitChildren: visitChildren(partialResult.fiber?.reconciler, nextValue),
          parent: partialResult,
          child: existing.child,
          alternateChild: existing.alternate?.child,
          newContent: newContent,
          elementIndices: partialResult.elementIndices,
          nextTraits: existing.element != nil ? .init() : partialResult.nextTraits
        )
        partialResult.nextExisting = existing.sibling
        partialResult.nextExistingAlternate = partialResult.nextExistingAlternate?.sibling
      } else {
        let elementParent = partialResult.fiber?.element != nil
          ? partialResult.fiber
          : partialResult.fiber?.elementParent
        let preferenceParent = partialResult.fiber?.preferences != nil
          ? partialResult.fiber
          : partialResult.fiber?.preferenceParent
        let key: ObjectIdentifier?
        if let elementParent = elementParent {
          key = ObjectIdentifier(elementParent)
        } else {
          key = nil
        }
        // Otherwise, create a new fiber for this child.
        let fiber = createFiber(
          &nextValue,
          partialResult.nextExistingAlternate?.element,
          partialResult.fiber,
          elementParent,
          preferenceParent,
          key.map { partialResult.elementIndices[$0, default: 0] },
          partialResult.nextTraits,
          partialResult.fiber?.reconciler
        )

        // If a fiber already exists for an alternate, link them.
        if let alternate = partialResult.nextExistingAlternate {
          fiber.alternate = alternate
          partialResult.nextExistingAlternate = alternate.sibling
        }
        resultChild = Result(
          fiber: fiber,
          visitChildren: visitChildren(partialResult.fiber?.reconciler, nextValue),
          parent: partialResult,
          child: nil,
          alternateChild: fiber.alternate?.child,
          elementIndices: partialResult.elementIndices,
          nextTraits: fiber.element != nil ? .init() : partialResult.nextTraits
        )
      }
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
