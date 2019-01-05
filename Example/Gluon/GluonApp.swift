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
    let isPresented: State<Bool>
  }

  static func render(props: Props) -> AnyNode {
    return props.isPresented.value ?
      ModalPresenter.node(
        StackPresenter<NavRouter>.node(
          .init(
            initial: Null(),
            routerProps: .init(
              handler: Handler { props.isPresented.set(false) }
            )
          )
        )
      ) : Null.node()
  }
}

struct AnimationModal: LeafComponent {
  struct Props: Equatable {
    let frame: Rectangle
    let isPresented: State<Bool>
  }

  private static let colors: [(Color, String)] = [
    (.white, "white"),
    (.red, "red"),
    (.green, "green"),
    (.blue, "blue"),
  ]

  static func render(props: Props) -> AnyNode {
    let backgroundColor = hooks.state(0)

    return props.isPresented.value ?
      ModalPresenter.node(
        View.node(
          .init(style: Style(backgroundColor: colors[backgroundColor.value].0)),
          StackView.node(
            .init(
              axis: .vertical,
              distribution: .fillEqually,
              style: Style(frame: props.frame)
            ), [
              Button.node(.init(
                handlers: [
                  .touchUpInside: Handler { props.isPresented.set(false) },
                ],
                style: Style(
                  frame: Rectangle(.zero, Size(width: 200, height: 200))
                )
              ), "Close Modal"),
              SegmentedControl.node(
                .init(
                  value: backgroundColor.value,
                  valueHandler: Handler(backgroundColor.set)
                ), colors.map { $0.1 }
              ),
            ]
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
    let isStackModalPresented = hooks.state(false)
    let isAnimationModalPresented = hooks.state(false)

    let children = [
      Button.node(.init(handlers: [.touchUpInside: Handler {
        isStackModalPresented.set(true)
      }]), "Present Stack Modal"),

      Button.node(.init(handlers: [.touchUpInside: Handler {
        isAnimationModalPresented.set(true)
      }]), "Present Animation Modal"),
    ] + (count.value < 15 ? [
      Button.node(.init(
        handlers: [.touchUpInside: Handler { count.set { $0 + 1 } }]
      ), "Increment"),

      Label.node(.init(alignment: .center), "\(count.value)"),

      Slider.node(.init(
        value: sliding.value,
        valueHandler: Handler(sliding.set)
      )),

      Label.node(.init(alignment: .center), "\(sliding.value)"),

      StackModal.node(.init(
        isPresented: isStackModalPresented
      )),

      AnimationModal.node(.init(
        frame: props.frame,
        isPresented: isAnimationModalPresented
      ))
    ] : [])

    return StackView.node(.init(axis: .vertical,
                                distribution: .fillEqually,
                                style: Style(frame: props.frame)),
                          children)
  }
}

struct App: LeafComponent {
  typealias Props = Rectangle

  static func render(props: Rectangle) -> AnyNode {
    return Counter.node(.init(frame: props, initial: 5))
  }
}
