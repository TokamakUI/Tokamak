//
//  Hooks.swift
//  Gluon
//
//  Created by Max Desiatov on 06/11/2018.
//

public struct Hooks {
  var currentReconciler: StackReconciler?
  var currentComponent: CompositeComponentWrapper?

  public func state<T>(_ initial: T,
                       id: String = "\(#file)\(#line)") -> (T, (T) -> ()) {
    guard let component = currentComponent,
      let reconciler = currentReconciler else {
      fatalError("""
        attempt to use `state` hook outside of a `render` function,
        or `render` is not called from a renderer
      """)
    }

    let current = currentComponent?.state[id] as? T ?? initial

    return (current, { [weak reconciler, weak component] new in
      // avoiding an indirect reference cycle here: this closure can be
      // owned by callbacks owned by node's target, which is strongly referenced
      // from node. Same with the reconciler.
      guard let component = component,
        let reconciler = reconciler else { return }

      reconciler.queue(state: new, for: component, id: id) })
  }
}
