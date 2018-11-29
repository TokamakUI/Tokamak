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
    if let component = rootComponent as? MountedBaseComponent,
    let type = component.type as? RendererBaseComponent.Type {
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

  private func render(composite type: AnyCompositeComponent.Type,
                      component: MountedCompositeComponent) -> Node? {
    _hooks.currentReconciler = self
    _hooks.currentComponent = component

    let result = type.render(props: component.props,
                             children: component.children)

    _hooks.currentComponent = nil
    _hooks.currentReconciler = nil

    return result
  }

  private func updateStateAndReconcile() {
    for (component, id, state) in queuedState {
      guard let renderedNode = render(composite: component.type,
                                      component: component) else {
        assertionFailure("""
          state update scheduled for a component that's not composite or
          has props and children types that don't match
        """)
        continue
      }
      component.state[id] = state
      reconcile(node: component, with: renderedNode)
    }
  }

  private func reconcile(node reference: MountedComponent, with node: Node) {
  }
}
