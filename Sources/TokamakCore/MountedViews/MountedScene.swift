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

    let child: MountedElement<R> = childBody.makeMountedScene(parentTarget, environmentValues)
    mountedChildren = [child]
    child.mount(with: reconciler)
  }

  override func unmount(with reconciler: StackReconciler<R>) {
    mountedChildren.forEach { $0.unmount(with: reconciler) }
  }

  override func update(with reconciler: StackReconciler<R>) {
    let element = reconciler.render(mountedScene: self)
    reconciler.reconcile(
      self,
      with: element,
      getElementType: { ($0 as? _AnyScene)?.type ?? type(of: $0) },
      updateChild: { $0.scene = _AnyScene(element) },
      mountChild: { $0.makeMountedScene(parentTarget, environmentValues) }
    )
  }
}

extension Scene {
  func makeMountedScene<R: Renderer>(
    _ parentTarget: R.TargetType,
    _ environmentValues: EnvironmentValues
  ) -> MountedScene<R> {
    let anySelf = (self as? _AnyScene) ?? _AnyScene(self)
    var title: String?
    if let titledSelf = anySelf.scene as? TitledScene,
      let text = titledSelf.title {
      title = _TextProxy(text).rawText
    }
    let children: [MountedElement<R>]
    if let viewSelf = anySelf.scene as? ViewContainingScene {
      children = [viewSelf.anyContent.makeMountedView(parentTarget, environmentValues)]
    } else if let deferredSelf = anySelf.scene as? SceneDeferredToRenderer {
      children = [deferredSelf.deferredBody.makeMountedView(parentTarget, environmentValues)]
    } else if let groupSelf = anySelf.scene as? GroupScene {
      children = groupSelf.children.map { $0.makeMountedScene(parentTarget, environmentValues) }
    } else {
      fatalError("""
      Unsupported `Scene` type `\(anySelf.type)`. Please file a bug report at \
      https://github.com/swiftwasm/Tokamak/issues/new
      """)
    }

    return .init(anySelf, title, children, parentTarget, environmentValues)
  }
}
