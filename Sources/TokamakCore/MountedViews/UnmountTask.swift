// Copyright 2018-2021 Tokamak contributors
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
//  Created by Carson Katri on 7/19/21.
//

/// A tree of cancellable in-progress unmounts.
public class UnmountTask<R> where R: Renderer {
  public internal(set) var isCancelled = false
  var childTasks = [UnmountTask<R>]()
  private let callback: () -> ()

  init(_ callback: @escaping () -> () = {}) {
    self.callback = callback
  }

  func cancel() {
    forEach { $0.isCancelled = true }
  }

  /// Call after completely unmounting the `host`.
  public func finish() {
    callback()
  }

  /// Adds and returns a new child `UnmountTask`
  func appendChild() -> UnmountTask<R> {
    let child = UnmountTask()
    child.isCancelled = isCancelled
    childTasks.append(child)
    return child
  }

  /// Forces the element and all child tasks to unmount without transition.
  func completeImmediately() {
    forEach {
      guard $0 is UnmountHostTask<R> else { return }
      $0.completeImmediately()
    }
  }

  func forEach(_ f: (UnmountTask<R>) -> ()) {
    var stack = [self]
    while let last = stack.popLast() {
      f(last)
      stack.insert(contentsOf: last.childTasks, at: 0)
    }
  }
}

/// The state for the unmounting of a `MountedHostView` by a `Renderer`.
public final class UnmountHostTask<R>: UnmountTask<R> where R: Renderer {
  public private(set) weak var host: MountedHostView<R>!
  private unowned var reconciler: StackReconciler<R>

  init(
    _ host: MountedHostView<R>,
    in reconciler: StackReconciler<R>,
    callback: @escaping () -> ()
  ) {
    self.host = host
    self.reconciler = reconciler
    super.init(callback)
  }

  override func completeImmediately() {
    host.viewTraits.insert(false, forKey: CanTransitionTraitKey.self)
    host.unmount(in: reconciler, with: .init(animation: nil), parentTask: nil)
  }
}
