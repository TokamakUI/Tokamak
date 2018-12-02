//
//  MountedComponent.swift
//  Gluon
//
//  Created by Max Desiatov on 28/11/2018.
//

class MountedComponent {
  let key: String?
  let props: AnyEquatable
  let children: AnyEquatable
  var mountedChildren = [MountedComponent]()

  fileprivate init(key: String?, props: AnyEquatable, children: AnyEquatable) {
    self.key = key
    self.props = props
    self.children = children
  }
}

final class MountedCompositeComponent: MountedComponent {
  let type: AnyCompositeComponent.Type
  var state = [Int: Any]()

  init(_ node: Node, _ type: AnyCompositeComponent.Type) {
    self.type = type

    super.init(key: node.key, props: node.props, children: node.children)
  }
}

final class MountedHostComponent: MountedComponent {
  let type: AnyHostComponent.Type
  let target: Any

  init(_ node: Node, _ type: AnyHostComponent.Type, _ target: Any) {
    self.type = type
    self.target = target

    super.init(key: node.key, props: node.props, children: node.children)
  }
}
