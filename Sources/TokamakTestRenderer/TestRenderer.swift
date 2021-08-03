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

import TokamakCore

public func testScheduler(closure: @escaping () -> ()) {
  // immediate scheduler on all platforms for easier debugging and support on all platforms
  closure()
}

public final class TestRenderer: Renderer {
  public private(set) var reconciler: StackReconciler<TestRenderer>?

  public var rootTarget: TestView {
    reconciler!.rootTarget
  }

  public init<A: App>(_ app: A) {
    reconciler = StackReconciler(
      app: app,
      target: TestView(EmptyView()),
      environment: .init(),
      renderer: self,
      scheduler: testScheduler
    )
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
    before _: TestView?,
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
    with task: UnmountHostTask<TestRenderer>
  ) {
    target.removeFromSuperview()
    task.finish()
  }

  public func primitiveBody(for view: Any) -> AnyView? {
    nil
  }

  public func isPrimitiveView(_ type: Any.Type) -> Bool {
    false
  }
}
