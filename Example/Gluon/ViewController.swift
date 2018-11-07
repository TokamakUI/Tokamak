//
//  ViewController.swift
//  Gluon
//
//  Created by Max Desiatov on 09/15/2018.
//  Copyright (c) 2018 Max Desiatov. All rights reserved.
//

import UIKit
import Gluon

//struct TodoList: Store {
//  enum Action {
//    case add(String, Int)
//    case remove(Int)
//    case update(String, Int)
//  }
//
//  var state = [String]()
//
//  mutating func apply(action: Action) {
//    switch action {
//    case let .add(item, index):
//      state.insert(item, at: index)
//    case let .update(item, index):
//      state[index] = item
//    case let .remove(index):
//      state.remove(at: index)
//    }
//  }
//}
//
//final class Counter: Component<NoProps, Counter.State> {
//  struct State: StateType {
//    var counter = 0
//  }
//
//  lazy var onPress = { Closure {
//    self.setState { $0.counter += 1 }
//  }}()
//
//  func render() -> Node {
//    return StackView.node {
//      [Button.node(.init(onPress: onPress)) { "Increment" },
//       Label.node { Node("\(state.counter)") }]
//    }
//  }
//}

final class ViewController: UIViewController {
  override func viewDidLoad() {
      super.viewDidLoad()
  }

  @IBAction func onTap(_ sender: Any) {
//    let counters = (0..<1_000_000).map { _ in Counter(props: NoProps(), children: []) }
    print(#file)
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

