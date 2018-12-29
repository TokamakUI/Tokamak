//
//  StackReconciler.swift
//  Gluon
//
//  Created by Max Desiatov on 28/11/2018.
//

import Dispatch

public final class StackReconciler<R: Renderer> {
  private var queuedState = [(CompositeComponentWrapper<R>, String, Any)]()

  public let rootTarget: R.Target
  private let rootComponent: ComponentWrapper<R>
  private(set) weak var renderer: R?

  public init(node: Node, target: R.Target, renderer: R) {
    self.renderer = renderer
    rootTarget = target

    rootComponent = node.makeComponentWrapper(target)

    rootComponent.mount(with: self)
  }

  func queue(state: Any,
             for component: CompositeComponentWrapper<R>,
             id: String) {
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
