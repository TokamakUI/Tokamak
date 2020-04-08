//
//  AppKitRenderer.swift
//  TokamakAppKit
//
//  Created by Max Desiatov on 02/12/2018.
//

import AppKit
import Tokamak

// FIXME: working around "Couldn't lookup symbols: protocol witness table"
// compiler bug
// let _modalPresenterWitnessTableHack: NSHostComponent.Type =
//   ModalPresenter.self
// let _stackControllerWitnessTableHack: NSHostComponent.Type =
//  NavigationController.self
// let _navigationItemWitnessTableHack: NSHostComponent.Type =
//  NavigationItem.self
// let _listViewWitnessTableHack: NSHostComponent.Type =
//  ListView<HackyProvider>.self
// let _collectionViewWitnessTableHack: NSHostComponent.Type =
//    CollectionView<HackyProvider>.self

struct HackyProvider: CellProvider {
  static func cell(
    props: Props, item: Int, path: CellPath
  ) -> AnyNode {
    Null.node()
  }

  typealias Props = Null
  typealias Model = Int
}

class NSTarget: Target {
  var viewController: NSViewController {
    fatalError("\(#function) should be overriden in NSTarget subclass")
  }

  var refTarget: Any {
    fatalError("\(#function) should be overriden in NSTarget subclass")
  }
}

/// UIKitRenderer is an implementation of `Renderer` with UIKit as a target.
final class AppKitRenderer: Renderer {
  private(set) var reconciler: StackReconciler<AppKitRenderer>?
  private weak var rootViewController: NSViewController!

  init(_ node: AnyView, rootViewController: NSViewController) {
    self.rootViewController = rootViewController
    reconciler = StackReconciler(
      node: node,
      target: ViewBox(rootViewController.view, rootViewController, node),
      renderer: self
    )
  }

  private func typeAssertionFailure(for type: Any.Type) {
    assertionFailure("""
      component type \(type) not supported by AppKitRenderer
    """)
  }

  func mountTarget(
    to parent: NSTarget,
    with component: AppKitRenderer.MountedHost
  ) -> NSTarget? {
    guard let rendererComponent = component.viewType as? NSHostComponent.Type else {
      typeAssertionFailure(for: component.viewType)
      return nil
    }

    return rendererComponent.mountTarget(to: parent,
                                         component: component,
                                         self)
  }

  func update(
    target: NSTarget,
    with component: AppKitRenderer.MountedHost
  ) {
    guard let rendererComponent = component.viewType as? NSHostComponent.Type else {
      typeAssertionFailure(for: component.viewType)
      return
    }

    rendererComponent.update(target: target,
                             node: component.node)
  }

  func unmount(
    target: NSTarget,
    from parent: NSTarget,
    with component: AppKitRenderer.MountedHost,
    completion: @escaping () -> ()
  ) {
    guard let rendererComponent = component.viewType as? NSHostComponent.Type else {
      typeAssertionFailure(for: component.viewType)
      return
    }

    rendererComponent.unmount(target: target, completion: completion)
  }
}
