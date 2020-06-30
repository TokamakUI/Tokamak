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

final class MountedCompositeView<R: Renderer>: MountedView<R>, Hashable {
  static func == (lhs: MountedCompositeView<R>,
                  rhs: MountedCompositeView<R>) -> Bool {
    lhs === rhs
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }

  private var mountedChildren = [MountedView<R>]()
  private let parentTarget: R.TargetType

  var state = [Any]()
  var environmentValues: EnvironmentValues

  init(_ view: AnyView, _ parentTarget: R.TargetType,
       environmentValues: EnvironmentValues) {
    self.parentTarget = parentTarget
    self.environmentValues = environmentValues

    super.init(view)
  }

  override func mount(with reconciler: StackReconciler<R>) {
    let childBody = reconciler.render(compositeView: self)

    let child: MountedView<R> = childBody.makeMountedView(parentTarget, withEnvironment: environmentValues)
    mountedChildren = [child]
    child.mount(with: reconciler)
  }

  override func unmount(with reconciler: StackReconciler<R>) {
    mountedChildren.forEach { $0.unmount(with: reconciler) }
  }

  override func update(with reconciler: StackReconciler<R>) {
    // FIXME: for now without properly handling `Group` mounted composite views have only
    // a single element in `mountedChildren`, but this will change when
    // fragments are implemented and this switch should be rewritten to compare
    // all elements in `mountedChildren`
    switch (mountedChildren.last, reconciler.render(compositeView: self)) {
    // no mounted children, but children available now
    case let (nil, childBody):
      let child: MountedView<R> = childBody.makeMountedView(parentTarget, withEnvironment: environmentValues)
      mountedChildren = [child]
      child.mount(with: reconciler)

    // some mounted children
    case let (wrapper?, childBody):
      let childBodyType = (childBody as? AnyView)?.type ?? type(of: childBody)

      // FIXME: no idea if using `mangledName` is reliable, but seems to be the only way to get
      // a name of a type constructor in runtime. Should definitely check if these are different
      // across modules, otherwise can cause problems with views with same names in different
      // modules.

      // new child has the same type as existing child
      // swiftlint:disable:next force_try
      if try! wrapper.view.typeConstructorName == typeInfo(of: childBodyType).mangledName {
        wrapper.view = AnyView(childBody)
        wrapper.update(with: reconciler)
      } else {
        // new child is of a different type, complete rerender, i.e. unmount the old
        // wrapper, then mount a new one with the new `childBody`
        wrapper.unmount(with: reconciler)

        let child: MountedView<R> = childBody.makeMountedView(parentTarget, withEnvironment: environmentValues)
        mountedChildren = [child]
        child.mount(with: reconciler)
      }
    }
  }
}
