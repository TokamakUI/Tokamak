//
//  StackReconciler.swift
//  Gluon
//
//  Created by Max Desiatov on 28/11/2018.
//

import Dispatch

public final class StackReconciler<R: Renderer> {
  private var queuedRerenders = Set<CompositeComponentWrapper<R>>()

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
    let scheduleReconcile = queuedRerenders.isEmpty

    component.state[id] = state
    queuedRerenders.insert(component)

    guard scheduleReconcile else { return }

    DispatchQueue.main.async {
      self.updateStateAndReconcile()
    }
  }

  private func updateStateAndReconcile() {
    for component in queuedRerenders {
      component.update(with: self)
    }

    queuedRerenders.removeAll()
  }
}
