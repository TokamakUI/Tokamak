//
//  UIKitRenderer.swift
//  TokamakUIKit
//
//  Created by Max Desiatov on 02/12/2018.
//

import Tokamak
import UIKit

// FIXME: working around "Couldn't lookup symbols: protocol witness table"
// compiler bug
let _modalPresenterWitnessTableHack: UIHostComponent.Type = ModalPresenter.self
let _stackControllerWitnessTableHack: UIHostComponent.Type =
  NavigationController.self
let _navigationItemWitnessTableHack: UIHostComponent.Type = NavigationItem.self
let _listViewWitnessTableHack: UIHostComponent.Type =
  ListView<HackyProvider>.self
let _collectionViewWitnessTableHack: UIHostComponent.Type =
  CollectionView<HackyProvider>.self

struct HackyProvider: CellProvider {
  static func cell(
    props: Props, item: Int, path: CellPath
  ) -> AnyNode {
    return Null.node()
  }

  typealias Props = Null
  typealias Model = Int
}

class UITarget: Target {
  var viewController: UIViewController {
    fatalError("\(#function) should be overriden in UITarget subclass")
  }

  var refTarget: Any {
    fatalError("\(#function) should be overriden in UITarget subclass")
  }
}

/// UIKitRenderer is an implementation of `Renderer` with UIKit as a target.
final class UIKitRenderer: Renderer {
  private(set) var reconciler: StackReconciler<UIKitRenderer>?
  private weak var rootViewController: UIViewController!

  init(_ node: AnyNode, rootViewController: UIViewController) {
    self.rootViewController = rootViewController
    reconciler = StackReconciler(
      node: node,
      target: ViewBox(rootViewController.view, rootViewController, node),
      renderer: self
    )
  }

  private func typeAssertionFailure(for type: AnyHostComponent.Type) {
    assertionFailure("""
      component type \(type) not supported by UIKitRenderer
    """)
  }

  func mountTarget(
    to parent: UITarget,
    with component: UIKitRenderer.MountedHost
  ) -> UITarget? {
    guard let rendererComponent = component.type as? UIHostComponent.Type else {
      typeAssertionFailure(for: component.type)
      return nil
    }

    return rendererComponent.mountTarget(to: parent,
                                         component: component,
                                         self)
  }

  func update(
    target: UITarget,
    with component: UIKitRenderer.MountedHost
  ) {
    guard let rendererComponent = component.type as? UIHostComponent.Type else {
      typeAssertionFailure(for: component.type)
      return
    }

    rendererComponent.update(target: target,
                             node: component.node)

    guard
      let componentType = component.type as? AnyRefComponent.Type,
      let anyRef = component.node.ref else { return }

    componentType.update(ref: anyRef, with: target.refTarget)
  }

  func unmount(
    target: UITarget,
    with component: UIKitRenderer.MountedHost,
    completion: @escaping () -> ()
  ) {
    guard let rendererComponent = component.type as? UIHostComponent.Type else {
      typeAssertionFailure(for: component.type)
      return
    }

    rendererComponent.unmount(target: target, completion: completion)
  }
}
