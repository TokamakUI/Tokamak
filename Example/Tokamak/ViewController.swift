//
//  ViewController.swift
//  TokamakDemo
//
//  Created by Max Desiatov on 09/15/2018.
//  Copyright (c) 2018 Max Desiatov. Tokamak is available under the Apache 2.0
//  license. See the LICENSE file for more info.
//

import Tokamak
import TokamakDemo
import TokamakUIKit
import UIKit

final class ViewController: TokamakViewController {
  override var node: AnyNode {
    return Network.node()
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
