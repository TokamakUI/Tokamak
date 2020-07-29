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
//  Created by Carson Katri on 7/19/20.
//

import OpenCombine
import Runtime

// This is very similar to `MountedCompositeView`. However, the `mountedBody`
// is the computed content of the specified `Scene`, instead of having child
// `View`s
final class MountedApp<R: Renderer>: MountedCompositeElement<R> {
  override func mount(with reconciler: StackReconciler<R>) {
    let childBody = reconciler.render(mountedApp: self)

    let child: MountedElement<R> = mountChild(childBody)
    mountedChildren = [child]
    child.mount(with: reconciler)
  }

  override func unmount(with reconciler: StackReconciler<R>) {
    mountedChildren.forEach { $0.unmount(with: reconciler) }
  }

  private func mountChild(_ childBody: _AnyScene) -> MountedElement<R> {
    let mountedScene: MountedScene<R> = childBody.makeMountedScene(parentTarget, environmentValues)
    if let title = mountedScene.title {
      // swiftlint:disable force_cast
      (app.type as! _TitledApp.Type)._setTitle(title)
    }
    return mountedScene
  }

  override func update(with reconciler: StackReconciler<R>) {
    let element = reconciler.render(mountedApp: self)
    reconciler.reconcile(
      self,
      with: element,
      getElementType: { $0.type },
      updateChild: {
        $0.environmentValues = environmentValues
        $0.scene = _AnyScene(element)
      },
      mountChild: { mountChild($0) }
    )
  }
}

extension _AnyApp {
  func makeMountedApp<R>(
    _ parentTarget: R.TargetType,
    _ environmentValues: EnvironmentValues
  ) -> MountedApp<R> where R: Renderer {
    // swiftlint:disable:next force_try
    let info = try! typeInfo(of: type)

    var modifiedApp = app
    let modifiedEnv = info.injectEnvironment(from: environmentValues, into: &modifiedApp)

    var result = self
    result.app = modifiedApp
    return MountedApp(result, parentTarget, modifiedEnv)
  }
}
