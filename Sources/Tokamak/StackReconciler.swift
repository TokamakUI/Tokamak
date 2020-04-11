//
//  StackReconciler.swift
//  Tokamak
//
//  Created by Max Desiatov on 28/11/2018.
//

import Dispatch
import Runtime

public final class StackReconciler<R: Renderer> {
  private var queuedRerenders = Set<MountedCompositeView<R>>()

  public let rootTarget: R.TargetType
  private let rootView: MountedView<R>
  private(set) weak var renderer: R?

  public init<V: View>(view: V, target: R.TargetType, renderer: R) {
    self.renderer = renderer
    rootTarget = target

    rootView = view.makeMountedView(target)

    rootView.mount(with: self)
  }

  func queueUpdate(
    for mountedView: MountedCompositeView<R>,
    id: Int,
    updater: (inout Any) -> ()
  ) {
    let scheduleReconcile = queuedRerenders.isEmpty

    updater(&mountedView.state[id])
    queuedRerenders.insert(mountedView)

    guard scheduleReconcile else { return }

    DispatchQueue.main.async {
      self.updateStateAndReconcile()
    }
  }

  private func updateStateAndReconcile() {
    for mountedView in queuedRerenders {
      mountedView.update(with: self)
    }

    queuedRerenders.removeAll()
  }

  func render(compositeView: MountedCompositeView<R>) -> some View {
    // swiftlint:disable force_try
    let info = try! typeInfo(of: compositeView.view.type)
    let stateProperties = info.properties.filter { $0.type is ValueStorage.Type }

    for (id, stateProperty) in stateProperties.enumerated() {
      // `ValueStorage` properties were already filtered out, so safe to assume the value's type
      // swiftlint:disable:next force_cast
      var state = try! stateProperty.get(from: compositeView.view.view) as! ValueStorage

      if compositeView.state.count == id {
        compositeView.state.append(state.anyInitialValue)
      }

      state.getter = { compositeView.state[id] }

      // Avoiding an indirect reference cycle here: this closure can be
      // owned by callbacks owned by view's target, which is strongly referenced
      // by the reconciler.
      state.setter = { [weak self, weak compositeView] newValue in
        guard let view = compositeView else { return }
        self?.queueUpdate(for: view, id: id) { $0 = newValue }
      }
      try! stateProperty.set(value: state, on: &compositeView.view.view)
    }
    // swiftlint:enable force_try

    let result = compositeView.view.bodyClosure(compositeView.view.view)

    return result
  }
}
