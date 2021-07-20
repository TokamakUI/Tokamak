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

class MountedCompositeElement<R: Renderer>: MountedElement<R> {
  let parentTarget: R.TargetType

  /** An array that stores type-erased values captured with the `@State` and `@StateObject` property
    wrappers used in declarations of this element.
   */
  var storage = [Any]()

  /** An array that stores subscriptions to updates on `@ObservableObject` property wrappers used
    in declarations of this element. These subscriptions are transient and may be cleaned up on
    every re-render of this composite element.
   */
  var transientSubscriptions = [AnyCancellable]()

  /** An array that stores subscriptions to updates on `@StateObject` property wrappers and renderer
    observers. These subscriptions are persistent and are only cleaned up when this composite
    element is deallocated.
   */
  var persistentSubscriptions = [AnyCancellable]()

  init<A: App>(
    _ app: A,
    _ parentTarget: R.TargetType,
    _ environmentValues: EnvironmentValues,
    _ parent: MountedElement<R>?
  ) {
    self.parentTarget = parentTarget
    super.init(_AnyApp(app), environmentValues, parent)
  }

  init(
    _ scene: _AnyScene,
    _ parentTarget: R.TargetType,
    _ environmentValues: EnvironmentValues,
    _ parent: MountedElement<R>?
  ) {
    self.parentTarget = parentTarget
    super.init(scene, environmentValues, parent)
  }

  init(
    _ view: AnyView,
    _ parentTarget: R.TargetType,
    _ environmentValues: EnvironmentValues,
    _ viewTraits: _ViewTraitStore,
    _ parent: MountedElement<R>?
  ) {
    self.parentTarget = parentTarget
    super.init(view, environmentValues, viewTraits, parent)
  }
}

extension MountedCompositeElement: Hashable {
  static func == (lhs: MountedCompositeElement<R>, rhs: MountedCompositeElement<R>) -> Bool {
    lhs === rhs
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }
}
