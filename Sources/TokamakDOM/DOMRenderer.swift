//
//  Created by Max Desiatov on 11/04/2020.
//

import Tokamak

public final class DOMNode: Target {}

public final class DOMRenderer: Renderer {
  public private(set) var reconciler: StackReconciler<DOMRenderer>?

  public func mountTarget(to parent: DOMNode, with view: MountedHost) -> DOMNode? {
    nil
  }

  public func update(target: DOMNode, with view: MountedHost) {}

  public func unmount(target: DOMNode, from parent: DOMNode, with view: MountedHost, completion: @escaping () -> ()) {}
}
