// Copyright 2021 Tokamak contributors
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
  struct TreeReducer: ViewReducer {
    final class Result {
      // For references
      let fiber: Fiber?
      let visitChildren: (TreeReducer.Visitor) -> ()
      unowned var parent: Result?
      var child: Result?
      var sibling: Result?
      var newContent: Renderer.ElementType.Content?
      var elementIndices: [ObjectIdentifier: Int]
      var layoutContexts: [ObjectIdentifier: LayoutContext]

      // For reducing
      var lastSibling: Result?
      var nextExisting: Fiber?
      var nextExistingAlternate: Fiber?

      init(
        fiber: Fiber?,
        visitChildren: @escaping (TreeReducer.Visitor) -> (),
        parent: Result?,
        child: Fiber?,
        alternateChild: Fiber?,
        newContent: Renderer.ElementType.Content? = nil,
        elementIndices: [ObjectIdentifier: Int],
        layoutContexts: [ObjectIdentifier: LayoutContext]
      ) {
        self.fiber = fiber
        self.visitChildren = visitChildren
        self.parent = parent
        nextExisting = child
        nextExistingAlternate = alternateChild
        self.newContent = newContent
        self.elementIndices = elementIndices
        self.layoutContexts = layoutContexts
      }
    }

    static func reduce<V>(into partialResult: inout Result, nextView: V) where V: View {
      // Create the node and its element.
      var nextView = nextView
      let resultChild: Result
      if let existing = partialResult.nextExisting {
        // If a fiber already exists, simply update it with the new view.
        let key: ObjectIdentifier?
        if let elementParent = existing.elementParent {
          key = ObjectIdentifier(elementParent)
        } else {
          key = nil
        }
        let newContent = existing.update(
          with: &nextView,
          elementIndex: key.map { partialResult.elementIndices[$0, default: 0] }
        )
        resultChild = Result(
          fiber: existing,
          visitChildren: nextView._visitChildren,
          parent: partialResult,
          child: existing.child,
          alternateChild: existing.alternate?.child,
          newContent: newContent,
          elementIndices: partialResult.elementIndices,
          layoutContexts: partialResult.layoutContexts
        )
        partialResult.nextExisting = existing.sibling

        // If this fiber has an element, increment the elementIndex for its parent.
        if let key = key,
           existing.element != nil
        {
          partialResult.elementIndices[key] = partialResult.elementIndices[key, default: 0] + 1
        }
      } else {
        let elementParent = partialResult.fiber?.element != nil
          ? partialResult.fiber
          : partialResult.fiber?.elementParent
        let key: ObjectIdentifier?
        if let elementParent = elementParent {
          key = ObjectIdentifier(elementParent)
        } else {
          key = nil
        }
        // Otherwise, create a new fiber for this child.
        let fiber = Fiber(
          &nextView,
          element: partialResult.nextExistingAlternate?.element,
          parent: partialResult.fiber,
          elementParent: elementParent,
          elementIndex: key.map { partialResult.elementIndices[$0, default: 0] },
          reconciler: partialResult.fiber?.reconciler
        )
        // If a fiber already exists for an alternate, link them.
        if let alternate = partialResult.nextExistingAlternate {
          fiber.alternate = alternate
          partialResult.nextExistingAlternate = alternate.sibling
        }
        // If this fiber has an element, increment the elementIndex for its parent.
        if let key = key,
           fiber.element != nil
        {
          partialResult.elementIndices[key] = partialResult.elementIndices[key, default: 0] + 1
        }
        resultChild = Result(
          fiber: fiber,
          visitChildren: nextView._visitChildren,
          parent: partialResult,
          child: nil,
          alternateChild: fiber.alternate?.child,
          elementIndices: partialResult.elementIndices,
          layoutContexts: partialResult.layoutContexts
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
