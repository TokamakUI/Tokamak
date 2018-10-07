//
//  Gluon.swift
//  Gluon_Example
//
//  Created by Max Desiatov on 15/09/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

final class Counter: Component<NoProps, Counter.State> {
  struct State: StateType {
    var counter = 0
  }

  func onPress() {
    setState { $0.counter += 1 }
  }

  lazy var onPressHandler = { Unique { self.onPress() } }()

  func render() -> Node {
    return View.node {
      [Button.node(.init(onPress: onPressHandler)) { "Press me" },
       Label.node { Node("\(state.counter)") }]
    }
  }
}

final class ViewController: UIViewController {
  private let button = UIButton()
  private let label = UILabel()

  private var counter = 0

  @objc func onPress() {
    counter += 1
    label.text = "\(counter)"
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    label.text = "\(counter)"

    button.addTarget(self, action: #selector(onPress), for: .touchUpInside)

    view.addSubview(button)
    view.addSubview(label)
  }
}

// render(node: Test.node(), container: UIView())
