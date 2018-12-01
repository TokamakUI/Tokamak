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
      reconcile(component: component, with: node)
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
                         with renderedNode: Node) {
    let parentTarget = rootTarget

    var stack = [(component, 0)]

    while !stack.isEmpty {
      let (component, childIndex) = stack.removeLast()

      for child in component.mountedChildren {
        switch (child, renderedNode.type) {
        case let (child, .composite(nodeType))
        as (MountedCompositeComponent, ComponentType):
          guard child.type == nodeType &&
            child.props == renderedNode.props &&
            child.children == renderedNode.children else {
            // FIXME: continue?
            return
          }
        default:
          assertionFailure("unhandled case to reconcile")
        }
      }

      if component.mountedChildren.isEmpty {
        // FIXME: handle fragment nodes here when those are introduced
        let mountedChild: MountedComponent

        switch renderedNode.type {
        case let .base(type):
          let target = renderer.mountTarget(to: parentTarget,
                                            with: type,
                                            props: renderedNode.props,
                                            children: renderedNode.children)

          mountedChild = MountedBaseComponent(renderedNode, type, target)
        case let .composite(type):
          mountedChild = MountedCompositeComponent(renderedNode, type)
        }
        component.mountedChildren.append(mountedChild)
      }
    }
  }
}
