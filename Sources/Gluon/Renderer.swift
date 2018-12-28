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

 A `Renderer` operates on targets of type `Any` due to lack of generalized
 existentials in Swift. If a target type was an associated type of this
 protocol, a `StackReconciler` instance wouldn't have a concrete renderer type
 to delegate rendering to.

 Despite that fact, a valid bug-free and consistent renderer shouldn't
 have problems with targets cast to a wrong type. It's an invalid behaviour for
 a user to create children nodes of a wrong type and renderer code is supposed
 to trigger an assertion failure in this case to avoid wrong type casts later.
 */
public protocol Renderer: class {
  /** Function called by a reconciler when a new target instance should be
   created.
   - parameter parent: Parent target that will own a newly created target
   instance.
   - parameter component: Type of the base component that renders to the
   newly created target.
   - parameter props: Props used to configure the new target.
   - parameter children: Children of the rendered base component for the new
   target.
   - returns: The newly created target.
   */
  func mountTarget(to parent: Any,
                   with component: AnyHostComponent.Type,
                   props: AnyEquatable,
                   children: AnyEquatable) -> Any?

  /** Function called by a reconciler when an existing target instance should be
   updated.
   - parameter target: Existing target instance to be updated.
   - parameter component: Type of the base component that renders to the
   updated target.
   - parameter props: Props used to configure the existing target. This props
   value can be different from props passed on previous
   updates or on target creation. The props value is wrapped
   with `AnyEquatable` for type-erasure purposes.
   - parameter children: Children used to configure the existing target. These
   children can be different from children passed on
   previous updates or on target creation.
   */
  func update(target: Any,
              with component: AnyHostComponent.Type,
              props: AnyEquatable,
              children: AnyEquatable)

  /** Function called by a reconciler when an existing target instance should be
   unmounted: removed the parent and most likely destroyed.
   - parameter target: Existing target instance to be unmounted.
   - parameter component: Type of the base component that renders to the
   updated target.
   */
  func unmount(target: Any,
               with component: AnyHostComponent.Type)
}
