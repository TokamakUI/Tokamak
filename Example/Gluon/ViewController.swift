//
//  ViewController.swift
//  Gluon
//
//  Created by Max Desiatov on 09/15/2018.
//  Copyright (c) 2018 Max Desiatov. All rights reserved.
//

import Gluon
import GluonUIKit
import UIKit

final class ViewController: GluonViewController {
  override var node: AnyNode {
    return NavigationPresenter<Router>.node(.init(initial: .list))
  }
}

final class ClassicViewController: UIViewController {
  private let stack = UIStackView()
  private let button = UIButton(type: .system)
  private let label = UILabel()

  private var counter = 0

  @objc func onPress() {
    counter += 1
    label.text = "\(counter)"
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    stack.axis = .vertical
    stack.distribution = .fillEqually
    view.addSubview(stack)
    stack.frame = view.frame

    label.text = "\(counter)"
    label.textAlignment = .center
    button.setTitle("Increment", for: .normal)
    button.addTarget(self, action: #selector(onPress), for: .touchUpInside)

    stack.addArrangedSubview(button)
    stack.addArrangedSubview(label)
  }
}
