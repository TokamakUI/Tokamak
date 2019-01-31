//
//  StackReconciler.swift
//  Gluon
//
//  Created by Max Desiatov on 28/11/2018.
//

import Dispatch

public final class StackReconciler<R: Renderer> {
  private var queuedRerenders = Set<MountedCompositeComponent<R>>()

  public let rootTarget: R.Target
  private let rootComponent: MountedComponent<R>
  private(set) weak var renderer: R?
  private var hooks = Hooks()

  public init(node: AnyNode, target: R.Target, renderer: R) {
    self.renderer = renderer
    rootTarget = target

    rootComponent = node.makeMountedComponent(target)

    rootComponent.mount(with: self)
  }

  func queue(state: Any,
             for component: MountedCompositeComponent<R>,
             id: Int) {
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

  func render(component: MountedCompositeComponent<R>) -> AnyNode {
    var stateIndex = 0
    hooks.currentState = { [weak component] in
      defer { stateIndex += 1 }

      guard let component = component else { return ($0, stateIndex) }

      if component.state.count > stateIndex {
        return (component.state[stateIndex], stateIndex)
      } else {
        component.state.append($0)
        return ($0, stateIndex)
      }
    }

    // Avoiding an indirect reference cycle here: this closure can be
    // owned by callbacks owned by node's target, which is strongly referenced
    // by the reconciler.
    hooks.queueState = { [weak self, weak component] in
      guard let component = component else { return }
      self?.queue(state: $0, for: component, id: $1)
    }

    let result = component.type.render(
      props: component.node.props,
      children: component.node.children,
      hooks: hooks
    )

    hooks.currentState = nil
    hooks.queueState = nil

    return result
  }
}
