// Copyright 2018-2021 Tokamak contributors
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
//  Created by Max Desiatov on 03/12/2018.
//

import OpenCombineShim

final class MountedCompositeView<R: Renderer>: MountedCompositeElement<R> {
  override func mount(
    before sibling: R.TargetType? = nil,
    on parent: MountedElement<R>? = nil,
    in reconciler: StackReconciler<R>,
    with transaction: Transaction
  ) {
    super.prepareForMount(with: transaction)

    var transaction = transaction
    (view.view as? _TransactionModifierProtocol)?.modifyTransaction(&transaction)
    // Disable animations on mount so `animation(_:)` doesn't try to animate
    // until the transition finishes.
    transaction.disablesAnimations = true
    self.transaction = transaction

    updateVariadicView()

    let childBody = reconciler.render(compositeView: self)

    if let traitModifier = view.view as? _TraitWritingModifierProtocol {
      traitModifier.modifyViewTraitStore(&viewTraits)
    }
    let child: MountedElement<R> = childBody.makeMountedView(
      reconciler.renderer,
      parentTarget,
      environmentValues,
      viewTraits,
      self
    )
    mountedChildren = [child]
    child.mount(before: sibling, on: self, in: reconciler, with: transaction)

    // `_TargetRef` (and `TargetRefType` generic eraser protocol it conforms to) is a composite
    // view, so it's enough check for it only here.
    if var targetRef = view.view as? TargetRefType {
      // `_TargetRef` body is not always a host view that has a target, need to traverse
      // all descendants to find a `MountedHostView<R>` instance.
      var descendant: MountedElement<R>? = child
      while descendant != nil && !(descendant is MountedHostView<R>) {
        descendant = descendant?.mountedChildren.first
      }

      guard let hostDescendant = descendant as? MountedHostView<R> else { return }

      targetRef.target = hostDescendant.target
      view.view = targetRef
    }

    reconciler.afterCurrentRender(perform: { [weak self] in
      guard let self = self else { return }

      // FIXME: this has to be implemented in a renderer-specific way, otherwise it's equivalent to
      // `_onMount` and `_onUnmount` at the moment,
      // see https://github.com/swiftwasm/Tokamak/issues/175 for more details
      if let appearanceAction = self.view.view as? AppearanceActionType {
        appearanceAction.appear?()
      }

      if let preferenceModifier = self.view.view as? _PreferenceWritingViewProtocol {
        self.view = preferenceModifier.modifyPreferenceStore(&self.preferenceStore)
      }

      if let preferenceReader = self.view.view as? _PreferenceReadingViewProtocol {
        preferenceReader.preferenceStore(self.preferenceStore)
      }
    })

    super.mount(before: sibling, on: parent, in: reconciler, with: transaction)
  }

  override func unmount(
    in reconciler: StackReconciler<R>,
    with transaction: Transaction,
    parentTask: UnmountTask<R>?
  ) {
    super.unmount(in: reconciler, with: transaction, parentTask: parentTask)

    var transaction = transaction
    transaction.disablesAnimations = false
    (view.view as? _TransactionModifierProtocol)?.modifyTransaction(&transaction)

    mountedChildren.forEach {
      $0.viewTraits = self.viewTraits
      $0.unmount(in: reconciler, with: transaction, parentTask: parentTask)
    }

    if let appearanceAction = view.view as? AppearanceActionType {
      appearanceAction.disappear?()
    }
  }

  override func update(in reconciler: StackReconciler<R>, with transaction: Transaction) {
    var transaction = transaction
    transaction.disablesAnimations = false
    (view.view as? _TransactionModifierProtocol)?.modifyTransaction(&transaction)
    updateVariadicView()
    let element = reconciler.render(compositeView: self)
    reconciler.reconcile(
      self,
      with: element,
      transaction: transaction,
      getElementType: { $0.type },
      updateChild: {
        $0.environmentValues = environmentValues
        $0.view = AnyView(element)
        $0.transaction = transaction
      },
      mountChild: {
        $0.makeMountedView(
          reconciler.renderer,
          parentTarget,
          environmentValues,
          viewTraits,
          self
        )
      }
    )

    if let lifecycleActions = view.view as? LifecycleActionType {
      lifecycleActions.update?()
    }
  }

  private func updateVariadicView() {
    if var tree = view.view as? _VariadicView_AnyTree {
      let elements = ((tree.anyContent.view as? GroupView)?.recursiveChildren ?? [tree.anyContent])
        .enumerated()
        .map { (pair: EnumeratedSequence<[AnyView]>.Element) -> _VariadicView_Children.Element in
          var viewTraits = _ViewTraitStore(values: [:])
          if let traitModifier = pair.element.view as? _TraitWritingModifierProtocol {
            traitModifier.modifyViewTraitStore(&viewTraits)
          }
          return _VariadicView_Children.Element(
            view: pair.element,
            id: AnyHashable(pair.offset),
            // TODO: Retrieve the ID from the `IDView`. Maybe this should use traits too.
            viewTraits: viewTraits,
            onTraitsUpdated: { _ in }
          )
        }
      tree.children = _VariadicView_Children(elements: elements)
      view.view = tree
    }
  }
}

private extension GroupView {
  var recursiveChildren: [AnyView] {
    var allChildren = [AnyView]()
    for child in children {
      if !(child.view is ModifiedContentProtocol),
         let group = child.view as? GroupView
      {
        allChildren.append(contentsOf: group.recursiveChildren)
      } else {
        allChildren.append(child)
      }
    }
    return allChildren
  }
}
