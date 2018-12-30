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

// struct TodoList: Store {
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
// }

struct Counter: LeafComponent {
  struct Props: Equatable {
    let frame: Rectangle
    let initial: Int
  }

  static func render(props: Props) -> Node {
    let (count, setCount) = hooks.state(props.initial)
    let (sliding, setSliding) = hooks.state(0.5 as Float)

    let children = count < 15 ? [
      Button.node(.init(handlers: [
        .touchUpInside: Handler {
          setCount(count + 1)
        },
      ]), "Increment"),

      Label.node(.init(alignment: .center), "\(count)"),

      Slider.node(.init(
        value: sliding,
        valueHandler: Handler { setSliding($0) }
      )),

      Label.node(.init(alignment: .center), "\(sliding)"),
    ] : []

    return StackView.node(.init(axis: .vertical,
                                distribution: .fillEqually,
                                frame: props.frame),
                          children)
  }
}

struct App: LeafComponent {
  typealias Props = Rectangle

  static func render(props: Rectangle) -> Node {
    return Counter.node(.init(frame: props, initial: 5))
  }
}

final class GluonViewController: UIViewController {
  private var renderer: UIKitRenderer?

  override func viewDidLoad() {
    super.viewDidLoad()

    renderer = UIKitRenderer(node: App.node(Rectangle(view.frame)),
                             target: view)
  }

  @IBAction func onTap(_: Any) {
//    let counters = (0..<1_000_000).map { _ in
//        Counter(props: NoProps(), children: [])
//    }
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
