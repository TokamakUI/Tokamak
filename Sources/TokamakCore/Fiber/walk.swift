// Copyright 2022 Tokamak contributors
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
//  Created by Carson Katri on 2/11/22.
//

@_spi(TokamakCore)
public enum WalkWorkResult<Success> {
  case `continue`
  case `break`(with: Success)
  case pause
}

@_spi(TokamakCore)
public enum WalkResult<Renderer: FiberRenderer, Success> {
  case success(Success)
  case finished
  case paused(at: FiberReconciler<Renderer>.Fiber)
}

/// Walk a fiber tree from `root` until the `work` predicate returns `false`.
@_spi(TokamakCore)
@discardableResult
public func walk<Renderer: FiberRenderer>(
  _ root: FiberReconciler<Renderer>.Fiber,
  _ work: @escaping (FiberReconciler<Renderer>.Fiber) throws -> Bool
) rethrows -> WalkResult<Renderer, ()> {
  try walk(root) {
    try work($0) ? .continue : .pause
  }
}

/// Parent-first depth-first traversal of a `Fiber` tree.
/// `work` is called with each `Fiber` in the tree as they are entered.
///
/// Traversal uses the following process:
/// 1. Perform work on the current `Fiber`.
/// 2. If the `Fiber` has a child, repeat from (1) with the child.
/// 3. If the `Fiber` does not have a sibling, walk up until we find a `Fiber` that does have one.
/// 4. Walk across to the sibling.
///
/// When the `root` is reached, the loop exits.
@_spi(TokamakCore)
public func walk<Renderer: FiberRenderer, Success>(
  _ root: FiberReconciler<Renderer>.Fiber,
  _ work: @escaping (FiberReconciler<Renderer>.Fiber) throws -> WalkWorkResult<Success>
) rethrows -> WalkResult<Renderer, Success> {
  var current = root
  while true {
    // Perform work on the node
    switch try work(current) {
    case .continue: break
    case let .break(success): return .success(success)
    case .pause: return .paused(at: current)
    }
    // Walk into the child
    if let child = current.child {
      current = child
      continue
    }
    // When we walk back to the root, exit
    if current === root {
      return .finished
    }
    // Walk back up until we find a sibling
    while current.sibling == nil {
      // When we walk back to the root, exit
      guard let parent = current.parent,
            parent !== root else { return .finished }
      current = parent
    }
    // Walk the sibling
    current = current.sibling!
  }
}
