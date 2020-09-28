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
//
//  Created by Max Desiatov on 21/12/2018.
//

#if os(WASI)
import JavaScriptKit
#else
import Dispatch
#endif
import TokamakCore

public func testScheduler(closure: @escaping () -> ()) {
  #if os(WASI)
  let fn = JSClosure { _ in
    closure()
    return .undefined
  }
  _ = JSObject.global.setTimeout!(fn, 0)
  #else
  DispatchQueue.main.async(execute: closure)
  #endif
}

public final class TestRenderer: Renderer {
  public private(set) var reconciler: StackReconciler<TestRenderer>?

  public var rootTarget: TestView {
    reconciler!.rootTarget
  }

  public init<V: View>(_ view: V) {
    reconciler = StackReconciler(
      view: view,
      target: TestView(EmptyView()),
      environment: .init(),
      renderer: self,
      scheduler: testScheduler
    )
  }

  public func mountTarget(
    to parent: TestView,
    with mountedHost: TestRenderer.MountedHost
  ) -> TestView? {
    let result = TestView(mountedHost.view)
    parent.add(subview: result)

    return result
  }

  public func update(
    target: TestView,
    with mountedHost: TestRenderer.MountedHost
  ) {}

  public func unmount(
    target: TestView,
    from parent: TestView,
    with mountedHost: TestRenderer.MountedHost,
    completion: () -> ()
  ) {
    target.removeFromSuperview()
  }
}
