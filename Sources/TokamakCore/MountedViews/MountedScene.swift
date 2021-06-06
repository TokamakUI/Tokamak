// Copyright 2020-2021 Tokamak contributors
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

final class MountedScene<R: Renderer>: MountedCompositeElement<R> {
  let title: String?

  init(
    _ scene: _AnyScene,
    _ title: String?,
    _ children: [MountedElement<R>],
    _ parentTarget: R.TargetType,
    _ environmentValues: EnvironmentValues,
    _ parent: MountedElement<R>?
  ) {
    self.title = title
    super.init(scene, parentTarget, environmentValues, parent)
    mountedChildren = children
  }

  override func mount(
    before sibling: R.TargetType? = nil,
    on parent: MountedElement<R>? = nil,
    with reconciler: StackReconciler<R>
  ) {
    let childBody = reconciler.render(mountedScene: self)

    let child: MountedElement<R> = childBody
      .makeMountedElement(parentTarget, environmentValues, self)
    mountedChildren = [child]
    child.mount(before: sibling, on: self, with: reconciler)
  }

  override func unmount(with reconciler: StackReconciler<R>) {
    mountedChildren.forEach { $0.unmount(with: reconciler) }
  }

  override func update(with reconciler: StackReconciler<R>) {
    let element = reconciler.render(mountedScene: self)
    reconciler.reconcile(
      self,
      with: element,
      getElementType: { $0.type },
      updateChild: {
        $0.environmentValues = environmentValues
        switch element {
        case let .scene(scene):
          $0.scene = _AnyScene(scene)
        case let .view(view):
          $0.view = AnyView(view)
        }
      },
      mountChild: { $0.makeMountedElement(parentTarget, environmentValues, self) }
    )
  }
}

extension _AnyScene.BodyResult {
  var type: Any.Type {
    switch self {
    case let .scene(scene):
      return scene.type
    case let .view(view):
      return view.type
    }
  }

  func makeMountedElement<R: Renderer>(
    _ parentTarget: R.TargetType,
    _ environmentValues: EnvironmentValues,
    _ parent: MountedElement<R>?
  ) -> MountedElement<R> {
    switch self {
    case let .scene(scene):
      return scene.makeMountedScene(parentTarget, environmentValues, parent)
    case let .view(view):
      return view.makeMountedView(parentTarget, environmentValues, parent)
    }
  }
}

extension _AnyScene {
  func makeMountedScene<R: Renderer>(
    _ parentTarget: R.TargetType,
    _ environmentValues: EnvironmentValues,
    _ parent: MountedElement<R>?
  ) -> MountedScene<R> {
    var title: String?
    if let titledSelf = scene as? TitledScene,
       let text = titledSelf.title
    {
      title = _TextProxy(text).rawText
    }
    let children: [MountedElement<R>]
    if let deferredScene = scene as? SceneDeferredToRenderer {
      children = [
        deferredScene.deferredBody.makeMountedView(parentTarget, environmentValues, parent),
      ]
    } else if let groupScene = scene as? GroupScene {
      children = groupScene.children.map {
        $0.makeMountedScene(parentTarget, environmentValues, parent)
      }
    } else {
      children = []
    }
    return .init(self, title, children, parentTarget, environmentValues, parent)
  }
}
