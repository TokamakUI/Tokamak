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
//  Created by Carson Katri on 7/19/20.
//

import OpenCombineShim

// This is very similar to `MountedCompositeView`. However, the `mountedBody`
// is the computed content of the specified `Scene`, instead of having child
// `View`s
final class MountedApp<R: Renderer>: MountedCompositeElement<R> {
  override func mount(
    before sibling: R.TargetType? = nil,
    on parent: MountedElement<R>? = nil,
    in reconciler: StackReconciler<R>,
    with transaction: Transaction
  ) {
    super.prepareForMount(with: transaction)

    // `App` elements have no siblings, hence the `before` argument is discarded.
    // They also have no parents, so the `parent` argument is discarded as well.
    let childBody = reconciler.render(mountedApp: self)

    let child: MountedElement<R> = mountChild(reconciler.renderer, childBody)
    mountedChildren = [child]
    child.transaction = transaction
    child.mount(before: nil, on: self, in: reconciler, with: transaction)

    super.mount(before: sibling, on: parent, in: reconciler, with: transaction)
  }

  override func unmount(
    in reconciler: StackReconciler<R>,
    with transaction: Transaction,
    parentTask: UnmountTask<R>?
  ) {
    super.unmount(in: reconciler, with: transaction, parentTask: parentTask)
    mountedChildren
      .forEach { $0.unmount(in: reconciler, with: transaction, parentTask: parentTask) }
  }

  /// Mounts a child scene within the app.
  /// - Parameters:
  ///   - renderer: An instance conforming to the `Renderer` protocol to render the mounted
  ///   scene with.
  ///   - childBody: The body of the child scene to mount for this app.
  /// - Returns: Returns an instance of the `MountedScene` class that's already mounted in this app.
  private func mountChild(_ renderer: R, _ childBody: _AnyScene) -> MountedScene<R> {
    let mountedScene: MountedScene<R> = childBody
      .makeMountedScene(renderer, parentTarget, environmentValues, self)
    if let title = mountedScene.title {
      // swiftlint:disable force_cast
      (app.type as! _TitledApp.Type)._setTitle(title)
    }
    return mountedScene
  }

  override func update(in reconciler: StackReconciler<R>, with transaction: Transaction) {
    let element = reconciler.render(mountedApp: self)
    reconciler.reconcile(
      self,
      with: element,
      transaction: transaction,
      getElementType: { $0.type },
      updateChild: {
        $0.environmentValues = environmentValues
        $0.scene = _AnyScene(element)
        $0.transaction = transaction
      },
      mountChild: { mountChild(reconciler.renderer, $0) }
    )
  }
}
