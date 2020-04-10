//
//  UIKitRenderer.swift
//  Tokamak
//
//  Created by Max Desiatov on 07/10/2018.
//

/** Renderer protocol that renderers for all platforms must implement.
 It's up to a specific renderer to provide an initializer with an arbitrary
 signature that works well for that platform. Methods required by this
 protocol are used by a reconciler (`StackReconciler` instance) to notify
 the renderer about updates in the component tree.
 */
public protocol Renderer: AnyObject {
  typealias Mounted = MountedComponent<Self>
  typealias MountedHost = MountedHostComponent<Self>

  /** Component nodes are rendered to platform-specific targets with a renderer.
   Usually a target is a simple view (`UIView` and `NSView` for `UIKit`
   and `AppKit` respectively), but can also include other helper types like
   layout constraints (e.g. `NSLayoutConstraint`). A renderer would most
   probably create its own type hierarchy to be able to reason about
   all possible target types available on a specific platform.
   */
  associatedtype TargetType: Target

  /// Reconciler instance used by this renderer.
  var reconciler: StackReconciler<Self>? { get }

  /** Function called by a reconciler when a new target instance should be
   created and added to the parent (either as a subview or some other way, e.g.
   installed if it's a layout constraint).
   - parameter parent: Parent target that will own a newly created target
   instance.
   - parameter component: Type of the host component that renders to the
   newly created target.
   - returns: The newly created target.
   */
  func mountTarget(
    to parent: TargetType,
    with component: MountedHost
  ) -> TargetType?

  /** Function called by a reconciler when an existing target instance should be
   updated.
   - parameter target: Existing target instance to be updated.
   - parameter component: Type of the host component that renders to the
   updated target.
   */
  func update(
    target: TargetType,
    with component: MountedHost
  )

  /** Function called by a reconciler when an existing target instance should be
   unmounted: removed from the parent and most likely destroyed.
   - parameter target: Existing target instance to be unmounted.
   - parameter parent: Parent of target to direct interaction with parent.
   - parameter component: Type of the host component that renders to the
   updated target.
   */
  func unmount(
    target: TargetType,
    from parent: TargetType,
    with component: MountedHost,
    completion: @escaping () -> ()
  )
}

extension Renderer {
  public func mount(with node: AnyView, to parent: TargetType) -> Mounted {
    let result: Mounted = node.makeMountedComponent(parent)
    if let reconciler = reconciler {
      result.mount(with: reconciler)
    }
    return result
  }

  public func update(component: Mounted, with node: AnyView) {
    component.node = node
    if let reconciler = reconciler {
      component.update(with: reconciler)
    }
  }

  public func unmount(component: Mounted) {
    if let reconciler = reconciler {
      component.unmount(with: reconciler)
    }
  }
}
