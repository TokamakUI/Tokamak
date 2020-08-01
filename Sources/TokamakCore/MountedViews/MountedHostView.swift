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

import Runtime

/* A representation of a `View`, which has a `body` of type `Never`, stored in the tree of mounted
 views by `StackReconciler`.
 */
public final class MountedHostView<R: Renderer>: MountedElement<R> {
  /** Target of a closest ancestor host view. As a parent of this view
   might not be a host view, but a composite view, we need to pass
   around the target of a host view to its closests descendant host
   views. Thus, a parent target is not always the same as a target of
   a parent view. */
  private let parentTarget: R.TargetType

  /// Target of this host view supplied by a renderer after mounting has completed.
  private var target: R.TargetType?

  init(_ view: AnyView, _ parentTarget: R.TargetType, _ environmentValues: EnvironmentValues) {
    self.parentTarget = parentTarget

    super.init(view, environmentValues)
  }

  override func mount(with reconciler: StackReconciler<R>) {
    guard let target = reconciler.renderer?.mountTarget(to: parentTarget, with: self)
    else { return }

    self.target = target

    guard !view.children.isEmpty else { return }

    mountedChildren = view.children.map {
      $0.makeMountedView(target, environmentValues)
    }
    mountedChildren.forEach { $0.mount(with: reconciler) }
  }

  override func unmount(with reconciler: StackReconciler<R>) {
    guard let target = target else { return }

    reconciler.renderer?.unmount(
      target: target,
      from: parentTarget,
      with: self
    ) {
      self.mountedChildren.forEach { $0.unmount(with: reconciler) }
    }
  }

  override func update(with reconciler: StackReconciler<R>) {
    guard let target = target else { return }

    updateEnvironment()
    target.view = view
    reconciler.renderer?.update(target: target, with: self)

    var childrenViews = view.children

    switch (mountedChildren.isEmpty, childrenViews.isEmpty) {
    // if existing children present and new children array is empty
    // then unmount all existing children
    case (false, true):
      mountedChildren.forEach { $0.unmount(with: reconciler) }
      mountedChildren = []

    // if no existing children then mount all new children
    case (true, false):
      mountedChildren = childrenViews.map { $0.makeMountedView(target, environmentValues) }
      mountedChildren.forEach { $0.mount(with: reconciler) }

    // if both arrays have items then reconcile by types and keys
    case (false, false):
      var newChildren = [MountedElement<R>]()

      // iterate through every `mountedChildren` element and compare with
      // a corresponding `childrenViews` element, remount if type differs, otherwise
      // run simple update
      while let child = mountedChildren.first, let firstChild = childrenViews.first {
        let newChild: MountedElement<R>
        if firstChild.typeConstructorName == mountedChildren[0].view.typeConstructorName {
          child.view = firstChild
          child.updateEnvironment()
          child.update(with: reconciler)
          newChild = child
        } else {
          child.unmount(with: reconciler)
          newChild = firstChild.makeMountedView(target, environmentValues)
          newChild.mount(with: reconciler)
        }
        newChildren.append(newChild)
        mountedChildren.removeFirst()
        childrenViews.removeFirst()
      }

      // more mounted views left than views were to be rendered:
      // unmount remaining `mountedChildren`
      if !mountedChildren.isEmpty {
        for child in mountedChildren {
          child.unmount(with: reconciler)
        }
      } else {
        // more views left than children were mounted,
        // mount remaining views
        for firstChild in childrenViews {
          let newChild: MountedElement<R> =
            firstChild.makeMountedView(target, environmentValues)
          newChild.mount(with: reconciler)
          newChildren.append(newChild)
        }
      }

      mountedChildren = newChildren

    // both arrays are empty, nothing to reconcile
    case (true, true): ()
    }
  }
}
