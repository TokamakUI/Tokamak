// Copyright 2020 Tokamak contributors
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

import Runtime

final class MountedScene<R: Renderer>: MountedCompositeElement<R> {
  let title: String?

  init(
    _ scene: _AnyScene,
    _ title: String?,
    _ children: [MountedElement<R>],
    _ parentTarget: R.TargetType,
    _ environmentValues: EnvironmentValues
  ) {
    self.title = title
    super.init(scene, parentTarget, environmentValues)
    mountedChildren = children
  }

  override func mount(with reconciler: StackReconciler<R>) {
    let childBody = reconciler.render(mountedScene: self)

    let child: MountedElement<R> = childBody.makeMountedElement(parentTarget, environmentValues)
    mountedChildren = [child]
    child.mount(with: reconciler)
    #if DEBUG
    reconciler.debugTree[ObjectIdentifier(child)] = child.debugNode(parent: self)
    #endif
  }

  override func unmount(with reconciler: StackReconciler<R>) {
    mountedChildren.forEach {
      $0.unmount(with: reconciler)
      #if DEBUG
      reconciler.debugTree[ObjectIdentifier($0)] = nil
      #endif
    }
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
      mountChild: { $0.makeMountedElement(parentTarget, environmentValues) }
    )
  }

  override func debugNode(parent: MountedElement<R>? = nil) -> ViewTree<R>.Node {
    // swiftlint:disable:next force_try
    let info = try! typeInfo(of: scene.type)
    return .init(
      type: scene.type,
      isPrimitive: scene.bodyType is Never.Type,
      isHost: false,
      dynamicProperties: info.properties.filter { $0.type is DynamicProperty.Type }
        .map(\.name),
      object: self,
      parent: parent
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
    _ environmentValues: EnvironmentValues
  ) -> MountedElement<R> {
    switch self {
    case let .scene(scene):
      return scene.makeMountedScene(parentTarget, environmentValues)
    case let .view(view):
      return view.makeMountedView(parentTarget, environmentValues)
    }
  }
}

extension _AnyScene {
  func makeMountedScene<R: Renderer>(
    _ parentTarget: R.TargetType,
    _ environmentValues: EnvironmentValues
  ) -> MountedScene<R> {
    var title: String?
    if let titledSelf = scene as? TitledScene,
      let text = titledSelf.title
    {
      title = _TextProxy(text).rawText
    }
    let children: [MountedElement<R>]
    if let deferredScene = scene as? SceneDeferredToRenderer {
      children = [deferredScene.deferredBody.makeMountedView(parentTarget, environmentValues)]
    } else if let groupScene = scene as? GroupScene {
      children = groupScene.children.map { $0.makeMountedScene(parentTarget, environmentValues) }
    } else {
      children = []
    }
    return .init(self, title, children, parentTarget, environmentValues)
  }
}
