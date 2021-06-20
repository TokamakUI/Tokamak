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
    with reconciler: StackReconciler<R>
  ) {
    let childBody = reconciler.render(compositeView: self)

    let child: MountedElement<R> = childBody.makeMountedView(
      reconciler.renderer,
      parentTarget,
      environmentValues,
      self
    )
    mountedChildren = [child]
    child.mount(before: sibling, on: self, with: reconciler)

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
        if let parent = parent {
          parent.preferenceStore.merge(with: self.preferenceStore)
        }
      }

      if let preferenceReader = self.view.view as? _PreferenceReadingViewProtocol {
        preferenceReader.preferenceStore(self.preferenceStore)
      }
    })
  }

  override func unmount(with reconciler: StackReconciler<R>) {
    mountedChildren.forEach { $0.unmount(with: reconciler) }

    if let appearanceAction = view.view as? AppearanceActionType {
      appearanceAction.disappear?()
    }
  }

  override func update(with reconciler: StackReconciler<R>) {
    let element = reconciler.render(compositeView: self)
    reconciler.reconcile(
      self,
      with: element,
      getElementType: { $0.type },
      updateChild: {
        $0.environmentValues = environmentValues
        $0.view = AnyView(element)
      },
      mountChild: {
        $0.makeMountedView(reconciler.renderer, parentTarget, environmentValues, self)
      }
    )
  }
}
