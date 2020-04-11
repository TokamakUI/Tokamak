//
//  Created by Max Desiatov on 03/12/2018.
//

/* A representation of a `View`, which has a `body` of type `Never`, stored in the tree of mounted
 views by `StackReconciler`.
 */
public final class MountedHostView<R: Renderer>: MountedView<R> {
  private var mountedChildren = [MountedView<R>]()

  /** Target of a closest ancestor host view. As a parent of this view
   might not be a host view, but a composite view, we need to pass
   around the target of a host view to its closests descendant host
   views. Thus, a parent target is not always the same as a target of
   a parent view. */
  private let parentTarget: R.TargetType

  /// Target of this host view supplied by a renderer after mounting has completed.
  private var target: R.TargetType?

  init(_ view: AnyView,
       _ parentTarget: R.TargetType) {
    self.parentTarget = parentTarget

    super.init(view)
  }

  override func mount(with reconciler: StackReconciler<R>) {
    guard
      let target = reconciler.renderer?.mountTarget(to: parentTarget,
                                                    with: self)
    else { return }

    self.target = target

    reconciler.renderer?.update(target: target, with: self)

    guard !view.children.isEmpty else { return }

    mountedChildren = view.children.map { $0.makeMountedView(target) }
    mountedChildren.forEach { $0.mount(with: reconciler) }
  }

  override func unmount(with reconciler: StackReconciler<R>) {
    guard let target = target else { return }

    reconciler.renderer?.unmount(
      target: target,
      from: parentTarget,
      with: self
    ) {
      self.mountedChildren.forEach { $0.unmount(with: reconciler) }
    }
  }

  override func update(with reconciler: StackReconciler<R>) {
    guard let target = target else { return }

    target.view = view
    reconciler.renderer?.update(target: target,
                                with: self)

    var childrenViews = view.children

    switch (mountedChildren.isEmpty, childrenViews.isEmpty) {
    // if existing children present and new children array is empty
    // then unmount all existing children
    case (false, true):
      mountedChildren.forEach { $0.unmount(with: reconciler) }
      mountedChildren = []

    // if no existing children then mount all new children
    case (true, false):
      mountedChildren = childrenViews.map { $0.makeMountedView(target) }
      mountedChildren.forEach { $0.mount(with: reconciler) }

    // if both arrays have items then reconcile by types and keys
    case (false, false):
      var newChildren = [MountedView<R>]()

      // iterate through every `mountedChildren` element and compare with
      // a corresponding `childrenViews` element, remount if type differs, otherwise
      // run simple update
      while let child = mountedChildren.first, let firstChild = childrenViews.first {
        let newChild: MountedView<R>
        if firstChild.typeConstructorName == mountedChildren[0].view.typeConstructorName {
          child.view = firstChild
          child.update(with: reconciler)
          newChild = child
        } else {
          child.unmount(with: reconciler)
          newChild = firstChild.makeMountedView(target)
          newChild.mount(with: reconciler)
        }
        newChildren.append(newChild)
        mountedChildren.removeFirst()
        childrenViews.removeFirst()
      }

      // more mounted views left than views were to be rendered:
      // unmount remaining `mountedChildren`
      if !mountedChildren.isEmpty {
        for child in mountedChildren {
          child.unmount(with: reconciler)
        }
      } else {
        // more views left than children were mounted,
        // mount remaining views
        for firstChild in childrenViews {
          let newChild: MountedView<R> =
            firstChild.makeMountedView(target)
          newChild.mount(with: reconciler)
          newChildren.append(newChild)
        }
      }

      mountedChildren = newChildren

    // both arrays are empty, nothing to reconcile
    case (true, true):
      ()
    }
  }
}
