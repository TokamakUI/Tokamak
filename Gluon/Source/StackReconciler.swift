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
  private var queuedState = [(CompositeComponentWrapper, String, Any)]()

  private let rootComponent: ComponentWrapper
  private let rootTarget: Any
  private weak var renderer: Renderer!

  init(node: Node, target: Any, renderer: Renderer) {
    self.renderer = renderer
    rootTarget = target

    rootComponent = node.makeComponentWrapper()

    rootComponent.mount(with: renderer)
  }

  func queue(state: Any, for component: CompositeComponentWrapper, id: String) {
    let scheduleReconcile = queuedState.isEmpty

    queuedState.append((component, id, state))

    guard scheduleReconcile else { return }

    DispatchQueue.main.async {
      self.updateStateAndReconcile()
    }
  }

  private func render(component: CompositeComponentWrapper) -> Node {
    _hooks.currentReconciler = self
    _hooks.currentComponent = component

    let result = component.render()

    _hooks.currentComponent = nil
    _hooks.currentReconciler = nil

    return result
  }

  private func updateStateAndReconcile() {
    for (component, id, state) in queuedState {
      component.state[id] = state

      component.mount(with: renderer)
    }
  }
}
