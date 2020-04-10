//
//  StackReconciler.swift
//  Tokamak
//
//  Created by Max Desiatov on 28/11/2018.
//

import Dispatch
import Runtime

public final class StackReconciler<R: Renderer> {
  private var queuedRerenders = Set<MountedCompositeComponent<R>>()

  public let rootTarget: R.TargetType
  private let rootComponent: MountedComponent<R>
  private(set) weak var renderer: R?

  public init<V: View>(node: V, target: R.TargetType, renderer: R) {
    self.renderer = renderer
    rootTarget = target

    rootComponent = node.makeMountedComponent(target)

    rootComponent.mount(with: self)
  }

  func queueUpdate(
    for component: MountedCompositeComponent<R>,
    id: Int,
    updater: (inout Any) -> ()
  ) {
    let scheduleReconcile = queuedRerenders.isEmpty

    updater(&component.state[id])
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

  func render(component: MountedCompositeComponent<R>) -> some View {
    // swiftlint:disable force_try
    let info = try! typeInfo(of: component.node.type)
    let stateProperties = info.properties.filter { $0.type is ValueStorage.Type }

    for (id, stateProperty) in stateProperties.enumerated() {
      // `ValueStorage` properties were already filtered out, so safe to assume the value's type
      // swiftlint:disable:next force_cast
      var state = try! stateProperty.get(from: component.node.view) as! ValueStorage

      if component.state.count == id {
        component.state.append(state.anyInitialValue)
      }

      state.getter = { component.state[id] }

      // Avoiding an indirect reference cycle here: this closure can be
      // owned by callbacks owned by node's target, which is strongly referenced
      // by the reconciler.
      state.setter = { [weak self, weak component] newValue in
        guard let component = component else { return }
        self?.queueUpdate(for: component, id: id) { $0 = newValue }
      }
      try! stateProperty.set(value: state, on: &component.node.view)
    }
    // swiftlint:enable force_try

    let result = component.node.bodyClosure(component.node.view)

    return result
  }
}
