//
//  MountedComponent.swift
//  Gluon
//
//  Created by Max Desiatov on 28/11/2018.
//

protocol ComponentWrapper {
  func mount(with renderer: Renderer)

  func unmount(with renderer: Renderer)

  func update(with renderer: Renderer)
}

final class CompositeComponentWrapper: ComponentWrapper {
  private let node: Node
  private var mountedChildren = [ComponentWrapper]()
  private let type: AnyCompositeComponent.Type
  var state = [String: Any]()

  init(_ node: Node, _ type: AnyCompositeComponent.Type) {
    self.node = node
    self.type = type
  }

  func mount(with: Renderer) {
    let renderedNode = type.render(props: node.props, children: node.children)

    mountedChildren = []
  }

  func unmount(with renderer: Renderer) {

  }

  func update(with renderer: Renderer) {

  }

  func render() -> Node {
    return type.render(props: node.props, children: node.children)

  }
}

final class HostComponentWrapper: ComponentWrapper {
  private let node: Node
  fileprivate var mountedChildren = [ComponentWrapper]()
  private let type: AnyHostComponent.Type
  var target: Any?

  init(_ node: Node, _ type: AnyHostComponent.Type) {
    self.type = type
    self.node = node
  }

  func mount(with renderer: Renderer) {
  }

  func unmount(with renderer: Renderer) {
  }

  func update(with renderer: Renderer) {
  }
}
