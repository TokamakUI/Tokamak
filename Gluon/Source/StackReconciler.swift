//
//  StackReconciler.swift
//  Gluon
//
//  Created by Max Desiatov on 28/11/2018.
//

import Dispatch

protocol Reconciler: class {
  var renderer: Renderer? { get }

  func queue(state: Any, for component: CompositeComponentWrapper, id: String)
}

final class StackReconciler: Reconciler {
  private var queuedState = [(CompositeComponentWrapper, String, Any)]()

  private let rootComponent: ComponentWrapper
  private let rootTarget: Any
  private(set) weak var renderer: Renderer?

  init(node: Node, target: Any, renderer: Renderer) {
    self.renderer = renderer
    rootTarget = target

    rootComponent = node.makeComponentWrapper(target)

    rootComponent.mount(with: self)
  }

  func queue(state: Any, for component: CompositeComponentWrapper, id: String) {
    let scheduleReconcile = queuedState.isEmpty

    queuedState.append((component, id, state))

    guard scheduleReconcile else { return }

    DispatchQueue.main.async {
      self.updateStateAndReconcile()
    }
  }

  private func updateStateAndReconcile() {
    for (component, id, state) in queuedState {
      component.state[id] = state

      component.update(with: self)
    }
  }
}
