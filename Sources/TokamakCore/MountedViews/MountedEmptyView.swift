// Copyright 2019-2020 Tokamak contributors
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
//  Created by Max Desiatov on 05/01/2019.
//

final class MountedEmptyView<R: Renderer>: MountedElement<R> {
  override func mount(
    before sibling: R.TargetType? = nil,
    on parent: MountedElement<R>? = nil,
    in reconciler: StackReconciler<R>,
    with transaction: Transaction
  ) {
    super.prepareForMount(with: transaction)
    super.mount(before: sibling, on: parent, in: reconciler, with: transaction)
  }

  override func unmount(
    in reconciler: StackReconciler<R>,
    with transaction: Transaction,
    parentTask: UnmountTask<R>?
  ) {
    super.unmount(in: reconciler, with: transaction, parentTask: parentTask)
  }

  override func update(in reconciler: StackReconciler<R>, with transaction: Transaction?) {}
}
