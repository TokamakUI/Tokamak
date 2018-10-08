//
//  ViewController.swift
//  Gluon
//
//  Created by Max Desiatov on 09/15/2018.
//  Copyright (c) 2018 Max Desiatov. All rights reserved.
//

import UIKit
import Gluon

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


class ViewController: UIViewController {
  override func viewDidLoad() {
      super.viewDidLoad()

    render(node: Counter.node(), container: view)
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
}

final class ClassicViewController: UIViewController {
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

