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
  ) -> AnyNode {
    return View.node(
      .init(style: Style(backgroundColor: .white)),
      Button.node(.init(
        handlers: [.touchUpInside: props.handler],
        style: Style(frame: Rectangle(.zero, Size(width: 200, height: 200)))
      ), "Close Modal")
    )
  }
}

struct StackModal: LeafComponent {
  struct Props: Equatable {
    let isPresented: Bool
    let onClose: Handler<()>
  }

  static func render(props: Props) -> AnyNode {
    return props.isPresented ?
      ModalPresenter.node(
        StackPresenter<NavRouter>.node(
          .init(
            initial: Null(),
            routerProps: .init(handler: props.onClose)
          )
        )
      ) : Null.node()
  }
}

struct Counter: LeafComponent {
  struct Props: Equatable {
    let frame: Rectangle
    let initial: Int
  }

  static func render(props: Props) -> AnyNode {
    let count = hooks.state(props.initial)
    let sliding = hooks.state(0.5 as Float)
    let isModalPresented = hooks.state(false)

    let children = [Button.node(.init(handlers: [.touchUpInside: Handler {
      isModalPresented.set(true)
    }]), "Present Modal")] + (count.value < 15 ? [
      Button.node(.init(
        handlers: [.touchUpInside: Handler { count.set { $0 + 1 } }]
      ), "Increment"),

      Label.node(.init(alignment: .center), "\(count.value)"),

      Slider.node(.init(
        value: sliding.value,
        valueHandler: Handler(sliding.set)
      )),

      Label.node(.init(alignment: .center), "\(sliding.value)"),

      StackModal.node(.init(isPresented: isModalPresented.value,
                            onClose: Handler { isModalPresented.set(false) }))
    ] : [])

    return StackView.node(.init(axis: .vertical,
                                distribution: .fillEqually,
                                frame: props.frame),
                          children)
  }
}

struct App: LeafComponent {
  typealias Props = Rectangle

  static func render(props: Rectangle) -> AnyNode {
    return Counter.node(.init(frame: props, initial: 5))
  }
}
