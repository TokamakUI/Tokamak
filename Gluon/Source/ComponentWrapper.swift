//
//  MountedComponent.swift
//  Gluon
//
//  Created by Max Desiatov on 28/11/2018.
//

protocol ComponentWrapper {
  func mount(with renderer: Renderer, to target: Any)

  func unmount(with renderer: Renderer)

  func update(with renderer: Renderer)
}

final class CompositeComponentWrapper: ComponentWrapper {
  private var node: Node
  private var mountedChildren = [ComponentWrapper]()
  private let type: AnyCompositeComponent.Type
  var state = [String: Any]()

  init(_ node: Node, _ type: AnyCompositeComponent.Type) {
    self.node = node
    self.type = type
  }

  func mount(with renderer: Renderer, to target: Any) {
    let renderedNode = type.render(props: node.props, children: node.children)

    let child = renderedNode.makeComponentWrapper()
    mountedChildren = [child]
    child.mount(with: renderer, to: target)
  }

  func unmount(with renderer: Renderer) {
    for child in mountedChildren {
      child.unmount(with: renderer)
    }
    // FIXME: this is probably not needed, right?
    mountedChildren = []
  }

  func update(with renderer: Renderer) {
    let newNode = render()

    if node.type == newNode.type {
      
    }
    
  }

  func render() -> Node {
    return type.render(props: node.props, children: node.children)
  }
}

final class HostComponentWrapper: ComponentWrapper {
  private let node: Node
  fileprivate var mountedChildren = [ComponentWrapper]()
  private let type: AnyHostComponent.Type
  private var target: Any?

  init(_ node: Node, _ type: AnyHostComponent.Type) {
    self.type = type
    self.node = node
  }

  func mount(with renderer: Renderer, to target: Any) {
    self.target = renderer.mountTarget(to: target,
                                       with: type,
                                       props: node.props,
                                       children: node.children)

    switch node.children.value {
    case let nodes as [Node]:
      mountedChildren = nodes.map { $0.makeComponentWrapper() }

      for child in mountedChildren {
        child.mount(with: renderer, to: target)
      }
    case let node as Node:
      let child = node.makeComponentWrapper()
      mountedChildren = [child]
      child.mount(with: renderer, to: target)
    default:
      // child type that can't be rendered, but still makes sense as a child
      // (e.g. `String`)
      ()
    }
  }

  func unmount(with renderer: Renderer) {
    guard let target = target else { return }

    renderer.unmount(target: target, with: type)
  }

  func update(with renderer: Renderer) {
  }
}
