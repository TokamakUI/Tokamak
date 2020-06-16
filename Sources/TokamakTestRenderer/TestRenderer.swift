//
//  Created by Max Desiatov on 21/12/2018.
//

import Dispatch
import Tokamak

public final class TestRenderer: Renderer {
  public private(set) var reconciler: StackReconciler<TestRenderer>?

  public var rootTarget: TestView {
    reconciler!.rootTarget
  }

  public init<V: View>(_ view: V) {
    // FIXME: the root target shouldn't be `EmptyView`, but something more sensible, maybe Group?
    reconciler = StackReconciler(view: view, target: TestView(EmptyView()), renderer: self) {
      DispatchQueue.main.async(execute: $0)
    }
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
