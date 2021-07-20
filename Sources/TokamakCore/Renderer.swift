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
//  Created by Max Desiatov on 07/10/2018.
//

/** Renderer protocol that renderers for all platforms must implement.
 It's up to a specific renderer to provide an initializer with an arbitrary
 signature that works well for that platform. Methods required by this
 protocol are used by a reconciler (`StackReconciler` instance) to notify
 the renderer about updates in the view tree.
 */
public protocol Renderer: AnyObject {
  typealias Mounted = MountedElement<Self>
  typealias MountedHost = MountedHostView<Self>

  /** Views are rendered to platform-specific targets with a renderer.
   Usually a target is a simple view (`UIView` and `NSView` for `UIKit`
   and `AppKit` respectively).
   */
  associatedtype TargetType: Target

  /** Function called by a reconciler when a new target instance should be
   created and added to the parent (either as a subview or some other way, e.g.
   installed if it's a layout constraint).
   - parameter parent: Parent target that will own a newly created target instance.
   - parameter view: The host view that renders to the newly created target.
   - returns: The newly created target.
   */
  func mountTarget(
    before sibling: TargetType?,
    to parent: TargetType,
    with host: MountedHost
  ) -> TargetType?

  /** Function called by a reconciler when an existing target instance should be
   updated.
   - parameter target: Existing target instance to be updated.
   - parameter view: The host view that renders to the updated target.
   */
  func update(
    target: TargetType,
    with host: MountedHost
  )

  /** Function called by a reconciler when an existing target instance should be
   unmounted: removed from the parent and most likely destroyed.
   - parameter target: Existing target instance to be unmounted.
   - parameter parent: Parent of target to direct interaction with parent.
   - parameter task: The state associated with the unmount.
   */
  func unmount(
    target: TargetType,
    from parent: TargetType,
    with task: UnmountHostTask<Self>
  )

  /** Returns a body of a given pritimive view, or `nil` if `view` is not a primitive view for
   this renderer.
   */
  func primitiveBody(for view: Any) -> AnyView?

  /** Returns `true` if a given view type is a primitive view that should be deferred to this
   renderer.
   */
  func isPrimitiveView(_ type: Any.Type) -> Bool
}
