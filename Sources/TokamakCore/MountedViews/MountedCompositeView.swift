// Copyright 2018-2020 Tokamak contributors
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

import CombineShim
import Runtime

final class MountedCompositeView<R: Renderer>: MountedCompositeElement<R> {
  override func mount(with reconciler: StackReconciler<R>) {
    let childBody = reconciler.render(compositeView: self)

    if let appearanceAction = view.view as? AppearanceActionType {
      appearanceAction.appear?()
    }

    let child: MountedElement<R> = childBody.makeMountedView(parentTarget, environmentValues)
    mountedChildren = [child]
    child.mount(with: reconciler)

    // `_TargetRef` is a composite view, so it's enough to check for it only here
    if var targetRef = view.view as? TargetRefType {
      // `_TargetRef` body is not always a host view that has a target, need to travers
      // all descendants to find a `MountedHostView<R>` instance.
      var descendant: MountedElement<R>? = child
      while descendant != nil && !(descendant is MountedHostView<R>) {
        descendant = descendant?.mountedChildren.first
      }

      guard let hostDescendant = descendant as? MountedHostView<R> else { return }

      targetRef.target = hostDescendant.target
      view.view = targetRef
    }
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
      mountChild: { $0.makeMountedView(parentTarget, environmentValues) }
    )
  }
}
