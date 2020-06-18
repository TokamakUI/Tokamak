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
//  Created by Max Desiatov on 28/11/2018.
//

public class MountedView<R: Renderer> {
  public internal(set) var view: AnyView

  init(_ view: AnyView) {
    self.view = view
  }

  func mount(with reconciler: StackReconciler<R>) {
    fatalError("implement \(#function) in subclass")
  }

  func unmount(with reconciler: StackReconciler<R>) {
    fatalError("implement \(#function) in subclass")
  }

  func update(with reconciler: StackReconciler<R>) {
    fatalError("implement \(#function) in subclass")
  }
}

extension View {
  func makeMountedView<R: Renderer>(_ parentTarget: R.TargetType)
    -> MountedView<R> {
    let anyView = self as? AnyView ?? AnyView(self)
    if anyView.type == EmptyView.self {
      return MountedNull(anyView)
    } else if anyView.bodyType == Never.self && !(anyView.type is ViewDeferredToRenderer.Type) {
      return MountedHostView(anyView, parentTarget)
    } else {
      return MountedCompositeView(anyView, parentTarget)
    }
  }
}
