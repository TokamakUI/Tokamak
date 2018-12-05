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

struct Counter: LeafComponent {
  struct Props: Equatable {
    let frame: CGRect
    let initial: Int
  }

  static func render(props: Props) -> Node {
    let (count, setCount) = hooks.state(props.initial)

    let handler = Handler {
      setCount(count + 1)
    }

    return StackView.node(.init(axis: .vertical,
                                distribution: .fillEqually,
                                frame: props.frame), [
      Button.node(.init(handlers: [.touchUpInside: handler]), "Increment"),
      Label.node(Null(), "\(count)")
    ])
  }
}

struct App: LeafComponent {
  typealias Props = StackViewProps

  static func render(props: StackViewProps) -> Node {
    return Counter.node(.init(frame: props.frame, initial: 5))
  }
}

final class GluonViewController: UIViewController {
  private var renderer: UIKitRenderer?

  override func viewDidLoad() {
    super.viewDidLoad()

    renderer = UIKitRenderer(node: App.node(.init(frame: view.frame)),
                             target: view)
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

