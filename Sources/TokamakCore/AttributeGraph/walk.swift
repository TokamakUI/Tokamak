//
//  File.swift
//
//
//  Created by Carson Katri on 2/11/22.
//

enum WalkWorkResult<Success> {
  case `continue`
  case `break`(with: Success)
  case pause
}

enum WalkResult<Renderer: GraphRenderer, Success> {
  case success(Success)
  case finished
  case paused(at: Reconciler<Renderer>.ViewNode)
}

@discardableResult
func walk<Renderer: GraphRenderer>(
  _ root: Reconciler<Renderer>.ViewNode,
  _ work: @escaping (Reconciler<Renderer>.ViewNode) throws -> Bool
) rethrows -> WalkResult<Renderer, ()> {
  try walk(root) {
    try work($0) ? .continue : .pause
  }
}

/// Parent-first depth-first traversal of a `ViewNode` tree.
func walk<Renderer: GraphRenderer, Success>(
  _ root: Reconciler<Renderer>.ViewNode,
  _ work: @escaping (Reconciler<Renderer>.ViewNode) throws -> WalkWorkResult<Success>
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
    // swiftlint:disable:next force_unwrap
    current = current.sibling!
  }
}
