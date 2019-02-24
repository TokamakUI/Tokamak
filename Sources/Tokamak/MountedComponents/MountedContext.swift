//
//  MountedContext.swift
//  Tokamak
//
//  Created by Max Desiatov on 22/02/2019.
//

final class MountedContext<R: Renderer>: MountedComponent<R> {
  private let parentTarget: R.TargetType
  let type: AnyContext.Type

  init(_ node: AnyNode, _ type: AnyContext.Type, _ parentTarget: R.TargetType) {
    self.type = type
    self.parentTarget = parentTarget
    super.init(node)
  }
}
