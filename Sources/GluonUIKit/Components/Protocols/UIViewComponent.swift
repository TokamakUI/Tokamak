//
//  UIKitViewComponent.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 02/12/2018.
//

import Gluon
import UIKit

protocol UIViewComponent: UIHostComponent, HostComponent {
  associatedtype Target: UIView & Default

  static func update(view box: ViewBox<Target>,
                     _ props: Props,
                     _ children: Children)

  static func box(
    for view: Target,
    _ viewController: UIViewController,
    _ node: AnyNode
  ) -> ViewBox<Target>
}

private func applyStyle<T: UIView, P: StyleProps>(_ target: ViewBox<T>,
                                                  _ props: P) {
  guard let style = props.style else {
    return
  }

  let view = target.view

  style.alpha.flatMap { view.alpha = CGFloat($0) }
  style.backgroundColor.flatMap { view.backgroundColor = UIColor($0) }
  style.clipsToBounds.flatMap { view.clipsToBounds = $0 }

  switch style.layout {
  case let .frame(frame)?:
    view.frame = CGRect(frame)
  case let .constraints(constraints)?:
    view.removeConstraints(view.constraints)
    for c in constraints {
//      view.addConstraint(<#T##constraint: NSLayoutConstraint##NSLayoutConstraint#>)
    }
  case nil:
    ()
  }

  // center has to be updated after `frame`, otherwise `frame` overrides it
  style.center.flatMap { view.center = CGPoint($0) }
  style.isHidden.flatMap { view.isHidden = $0 }
}

extension UIViewComponent where Target == Target.DefaultValue,
  Props: StyleProps {
  static func box(
    for view: Target,
    _ viewController: UIViewController,
    _ node: AnyNode
  ) -> ViewBox<Target> {
    return ViewBox(view, viewController, node)
  }

  static func mountTarget(to parent: UITarget,
                          node: AnyNode) -> UITarget? {
    guard let children = node.children.value as? Children else {
      childrenAssertionFailure()
      return nil
    }

    guard let props = node.props.value as? Props else {
      propsAssertionFailure()
      return nil
    }

    let target = Target.defaultValue
    let result: ViewBox<Target>

    let parentRequiresViewController = parent.node?.isSubtypeOf(
      ModalPresenter.self, or: StackController.self, or: AnyTabPresenter.self
    ) ?? false

    // UIViewController parent target can't present a bare `ViewBox` target,
    // it needs to be wrapped with `ContainerViewController` first.
    if parentRequiresViewController {
      result = box(
        for: target,
        ContainerViewController(contained: target),
        node
      )
    } else {
      result = box(for: target, parent.viewController, node)
    }
    applyStyle(result, props)
    update(view: result, props, children)

    switch parent {
    case let box as ViewBox<GluonStackView>:
      box.view.addArrangedSubview(target)
    // no covariance/contravariance in Swift generics require next
    // two cases to be duplicated :(
    case let box as ViewBox<UIView>:
      box.view.addSubview(target)
    case let box as ViewBox<GluonView>:
      box.view.addSubview(target)
    case let box as ViewControllerBox<GluonNavigationController>
      where parent.node?.isSubtypeOf(StackController.self) ?? false:
      guard let props = parent.node?.props.value
        as? StackController.Props else {
        propsAssertionFailure()
        return nil
      }

      box.containerViewController.pushViewController(
        result.viewController,
        animated: props.pushAnimated
      )
    case let box as ViewControllerBox<UIViewController>
      where parent.node?.isSubtypeOf(ModalPresenter.self) ?? false:
      guard let props = parent.node?.props.value as? ModalPresenter.Props else {
        propsAssertionFailure()
        return nil
      }

      box.viewController.present(result.viewController,
                                 animated: props.presentAnimated,
                                 completion: nil)
    default:
      parentAssertionFailure()
    }

    return result
  }

  static func update(target: UITarget,
                     node: AnyNode) {
    guard let target = target as? ViewBox<Target> else {
      targetAssertionFailure()
      return
    }
    guard let children = node.children.value as? Children else {
      childrenAssertionFailure()
      return
    }
    guard let props = node.props.value as? Props else {
      propsAssertionFailure()
      return
    }

    applyStyle(target, props)

    update(view: target, props, children)
  }

  static func unmount(target: UITarget) {
    switch target {
    case let target as ViewBox<Target>:
      target.view.removeFromSuperview()
    default:
      targetAssertionFailure()
    }
  }
}
