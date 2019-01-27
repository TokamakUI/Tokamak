//
//  UIKitRenderer.swift
//  Gluon
//
//  Created by Max Desiatov on 07/10/2018.
//

/** Renderer protocol that renderers for all platforms must implement.
 It's up to a specific renderer to provide an initializer with an arbitrary
 signature that works well for that platform. Methods required by this
 protocol are used by a reconciler (`StackReconciler` instance) to notify
 the renderer about updates in the component tree.
 */
public protocol Renderer: class {
  /** Component nodes are rendered to platform-specific targets with a renderer.
   Usually a target is a simple view (`UIView` and `NSView` for `UIKit`
   and `AppKit` respectively), but can also include other helper types like
   layout constraints (e.g. `NSLayoutConstraint`). A renderer would most
   probably create its own type hierarchy to be able to reason about
   all possible target types available on a specific platform.
   */
  associatedtype Target: AnyObject

  /** Function called by a reconciler when a new target instance should be
   created and added to the parent (either as a subview or some other way, e.g.
   installed if it's a layout constraint).
   - parameter parent: Parent target that will own a newly created target
   instance.
   - parameter component: Type of the host component that renders to the
   newly created target.
   - parameter props: Props used to configure the new target.
   - parameter children: Children of the rendered host component for the new
   target.
   - returns: The newly created target.
   */
  func mountTarget(to parent: Target,
                   parentNode: AnyNode?,
                   with component: MountedHostComponent<Self>) -> Target?

  /** Function called by a reconciler when an existing target instance should be
   updated.
   - parameter target: Existing target instance to be updated.
   - parameter component: Type of the host component that renders to the
   updated target.
   - parameter props: Props used to configure the existing target. This props
   value can be different from props passed on previous
   updates or on target creation. The props value is wrapped
   with `AnyEquatable` for type-erasure purposes.
   - parameter children: Children used to configure the existing target. These
   children can be different from children passed on
   previous updates or on target creation.
   */
  func update(target: Target,
              with component: MountedHostComponent<Self>)

  /** Function called by a reconciler when an existing target instance should be
   unmounted: removed from the parent and most likely destroyed.
   - parameter target: Existing target instance to be unmounted.
   - parameter component: Type of the host component that renders to the
   updated target.
   */
  func unmount(target: Target,
               with component: MountedHostComponent<Self>)
}
