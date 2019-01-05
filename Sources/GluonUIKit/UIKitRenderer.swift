//
//  UIKitRenderer.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 02/12/2018.
//

import Gluon
import UIKit

// FIXME: working around "Couldn't lookup symbols: protocol witness table"
// compiler bug
let _ModalPresenterWitnessTableHack: UIHostComponent.Type = ModalPresenter.self
let _StackPresenterWitnessTableHack: UIHostComponent.Type =
  StackPresenter<TestRouter>.self

struct TestRouter: StackRouter {
  typealias Props = Null
  typealias Route = Null

  static func route(props: Null,
                    route: Null,
                    push: (TestRouter.Route) -> (),
                    pop: () -> ()) -> AnyNode {
    return Label.node(.init(), "blah")
  }
}

public protocol UITarget {
  var viewController: UIViewController { get }
}

public class UIKitRenderer: Renderer {
  private var reconciler: StackReconciler<UIKitRenderer>?
  private let rootViewController: UIViewController

  public init(node: AnyNode, rootViewController: UIViewController) {
    self.rootViewController = rootViewController
    reconciler = StackReconciler(
      node: node,
      target: ViewBox(rootViewController.view, rootViewController),
      renderer: self
    )
  }

  private func typeAssertionFailure(for type: AnyHostComponent.Type) {
    assertionFailure("""
      component type \(type) not supported by UIKitRenderer
    """)
  }

  public func mountTarget(to parent: UITarget,
                          parentNode: AnyNode?,
                          with component: AnyHostComponent.Type,
                          props: AnyEquatable,
                          children: AnyEquatable) -> UITarget? {
    guard let rendererComponent = component as? UIHostComponent.Type else {
      print(component)
      typeAssertionFailure(for: component)
      return nil
    }

    return rendererComponent.mountTarget(to: parent,
                                         parentNode: parentNode,
                                         props: props,
                                         children: children)
  }

  public func update(target: UITarget,
                     with component: AnyHostComponent.Type,
                     props: AnyEquatable,
                     children: AnyEquatable) {
    guard let rendererComponent = component as? UIHostComponent.Type else {
      typeAssertionFailure(for: component)
      return
    }

    rendererComponent.update(target: target,
                             props: props,
                             children: children)
  }

  public func unmount(target: UITarget,
                      with component: AnyHostComponent.Type) {
    guard let rendererComponent = component as? UIHostComponent.Type else {
      typeAssertionFailure(for: component)
      return
    }

    rendererComponent.unmount(target: target)
  }
}
