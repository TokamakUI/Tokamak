//
//  StackReconciler.swift
//  Gluon
//
//  Created by Max Desiatov on 28/11/2018.
//

import Dispatch

// TODO: this won't work in multi-threaded scenarios
private var _hooks = Hooks()

extension CompositeComponent {
  public static var hooks: Hooks {
    return _hooks
  }
}

final class StackReconciler {
  private var queuedState = [(MountedCompositeComponent, Int, Any)]()

  private let rootComponent: MountedComponent
  private let rootTarget: Any
  private weak var renderer: Renderer!

  init(node: Node, target: Any, renderer: Renderer) {
    self.renderer = renderer
    rootTarget = target

    switch node.type {
    case let .base(type):
      let target = renderer.mountTarget(to: rootTarget,
                                        with: type,
                                        props: node.props,
                                        children: node.children)

      rootComponent = MountedBaseComponent(node, type, target)
    case let .composite(type):
      let component = MountedCompositeComponent(node, type)

      rootComponent = component

      let renderedNode = render(component: component)
      reconcile(component: component, with: renderedNode)

    }
  }

  func queue(state: Any, for node: MountedCompositeComponent, id: Int) {
    let scheduleReconcile = queuedState.isEmpty

    queuedState.append((node, id, state))

    guard scheduleReconcile else { return }

    DispatchQueue.main.async {
      self.updateStateAndReconcile()
    }
  }

  private func render(component: MountedCompositeComponent) -> Node {
    _hooks.currentReconciler = self
    _hooks.currentComponent = component

    let result = component.type.render(props: component.props,
                                       children: component.children)

    _hooks.currentComponent = nil
    _hooks.currentReconciler = nil

    return result
  }

  private func updateStateAndReconcile() {
    for (component, id, state) in queuedState {
      component.state[id] = state

      reconcile(component: component, with: render(component: component))
    }
  }

  private func reconcile(component: MountedCompositeComponent,
                         with node: Node) {
    let parentTarget = rootTarget

    for child in component.mountedChildren {
      switch (child, node.type) {
      case let (nil, .base(type)):
        ()
      case let (child, .composite(nodeType))
      as (MountedCompositeComponent, ComponentType):
        guard child.type == nodeType &&
          child.props == node.props &&
          child.children == node.children else {
          // FIXME: continue?
          return
        }
      default:
        assertionFailure("unhandled case to reconcile")
      }
    }

    if component.mountedChildren.isEmpty {
      switch node.type {
      case let .base(type):
        let target = renderer.mountTarget(to: parentTarget,
                                          with: type,
                                          props: node.props,
                                          children: node.children)
        component.mountedChildren.append(MountedBaseComponent(node, type, target))
      case let .composite(type):
        ()
      }
    }
  }
}
