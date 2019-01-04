//
//  GluonApp.swift
//  Gluon_Example
//
//  Created by Max Desiatov on 31/12/2018.
//  Copyright © 2018 Max Desiatov. All rights reserved.
//

import Gluon

struct NavRouter: StackRouter {
  typealias Route = Null

  struct Props: Equatable {
    let handler: Handler<()>
  }

  static func route(
    props: Props,
    route: Null,
    push: (Null) -> (),
    pop: () -> ()
  ) -> Node {
    return View.node(
      .init(style: Style(backgroundColor: .white)),
      Button.node(.init(
        handlers: [.touchUpInside: props.handler],
        style: Style(frame: Rectangle(.zero, Size(width: 200, height: 200)))
      ), "Close Modal")
    )
  }
}

struct Counter: LeafComponent {
  struct Props: Equatable {
    let frame: Rectangle
    let initial: Int
  }

  static func render(props: Props) -> Node {
    let (count, setCount) = hooks.state(props.initial)
    let (sliding, setSliding) = hooks.state(0.5 as Float)
    let (isModalPresented, setIsModalPresented) = hooks.state(false)

    let children = [Button.node(.init(handlers: [.touchUpInside: Handler {
      setIsModalPresented(true)
    }]), "Present Modal")] + (count < 15 ? [
      Button.node(.init(
        handlers: [.touchUpInside: Handler { setCount(count + 1) }]
      ), "Increment"),

      Label.node(.init(alignment: .center), "\(count)"),

      Slider.node(.init(
        value: sliding,
        valueHandler: Handler { setSliding($0) }
      )),

      Label.node(.init(alignment: .center), "\(sliding)"),
    ] : []) + (isModalPresented ? [
      ModalPresenter.node(
        StackPresenter<NavRouter>.node(
          .init(
            initial: Null(),
            routerProps: .init(handler: Handler { setIsModalPresented(false) })
          )
        )
      )
    ] : [])

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
