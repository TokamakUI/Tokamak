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

    rootComponent = MountedComponent.make(node)
    if let component = rootComponent as? MountedBaseComponent {
      guard let type = component.type as? RendererBaseComponent.Type else {
        assertionFailure("base component not supported by any renderer")
        return
      }
      component.target = renderer.mountTarget(to: target, with: type)
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

  private func render(component: MountedCompositeComponent) -> Node? {
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

      guard let node = render(component: component) else {
        assertionFailure("""
          state update scheduled for a component with props and children types
          that don't match
        """)
        continue
      }

      reconcile(component: component, with: node)
    }
  }

  private func reconcile(component: MountedCompositeComponent,
                         with node: Node) {
    let parentTarget = rootTarget

    switch (component.mountedChild, node.type) {
    case let (nil, .base(type)):
      guard let type = type as? RendererBaseComponent.Type else {
        assertionFailure("base component not supported by any renderer")
        return
      }
      let newChild = MountedBaseComponent(node, type)
      renderer.mountTarget(to: parentTarget, with: component)

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
}
