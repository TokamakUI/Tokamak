//
//  TextViewBox.swift
//  TokamakUIKit
//
//  Created by Matvii Hodovaniuk on 3/28/19.
//

import Tokamak
import UIKit

private final class Delegate<T: UITextView>:
  NSObject,
  UITextViewDelegate {
  private let valueHandler: Handler<String>?

  func textViewDidChange(_ textView: UITextView) {
    valueHandler?.value(textView.text)
  }

  init(_ props: TextView.Props) {
    valueHandler = props.valueHandler
  }
}

final class TextViewBox: ViewBox<TokamakTextView> {
  // this delegate stays as a constant and doesn't create a reference cycle
  // swiftlint:disable:next weak_delegate
  private let delegate: Delegate<UITextView>

  init(
    _ view: TokamakTextView,
    _ viewController: UIViewController,
    _ component: UIKitRenderer.MountedHost,
    _ props: TextView.Props,
    _ renderer: UIKitRenderer
  ) {
    delegate = Delegate(props)
    view.delegate = delegate
    super.init(view, viewController, component.node)
  }
}
