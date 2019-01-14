//
//  GluonApp.swift
//  Gluon_Example
//
//  Created by Max Desiatov on 31/12/2018.
//  Copyright © 2018 Max Desiatov. All rights reserved.
//

import Gluon

struct NavRouter: StackRouter {
  enum Route {
    case first
    case second
  }

  struct Props: Equatable {
    let handler: Handler<()>
  }

  static func route(
    props: Props,
    route: Route,
    push: @escaping (Route) -> (),
    pop: @escaping () -> (),
    hooks _: Hooks
  ) -> AnyNode {
    let close =
      Button.node(.init(
        handlers: [.touchUpInside: props.handler],
        Style(frame: Rectangle(.zero, Size(width: 200, height: 200)))
      ), "Close Modal")
    switch route {
    case .first:
      return View.node(
        .init(Style(backgroundColor: .white)), [
          close,
          Label.node(.init(
            alignment: .center,
            Style(frame: Rectangle(Point(x: 0, y: 200),
                                   Size(width: 200, height: 200)))
          ), "first"),
          Button.node(.init(
            handlers: [.touchUpInside: Handler { push(.second) }],
            Style(frame: Rectangle(Point(x: 0, y: 400),
                                   Size(width: 200, height: 200)))
          ), "second"),
        ]
      )
    case .second:
      return View.node(
        .init(Style(backgroundColor: .white)), [
          close,
          Label.node(.init(
            alignment: .center,
            Style(frame: Rectangle(Point(x: 0, y: 200),
                                   Size(width: 200, height: 200)))
          ), "second"),
        ]
      )
    }
  }
}

struct StackModal: PureLeafComponent {
  struct Props: Equatable {
    let isPresented: State<Bool>
  }

  static func render(props: Props) -> AnyNode {
    return props.isPresented.value ?
      ModalPresenter.node(
        StackPresenter<NavRouter>.node(
          .init(
            initial: .first,
            routerProps: .init(
              handler: Handler {
                props.isPresented.set(false)
              }
            )
          )
        )
      ) : Null.node()
  }
}

struct SimpleModal: LeafComponent {
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

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let backgroundColor = hooks.state(0)

    return props.isPresented.value ?
      ModalPresenter.node(
        View.node(
          .init(Style(backgroundColor: colors[backgroundColor.value].0)),
          StackView.node(
            .init(
              axis: .vertical,
              distribution: .fillEqually,
              Style(frame: props.frame)
            ), [
              Button.node(.init(
                handlers: [
                  .touchUpInside: Handler {
                    props.isPresented.set(false)
                  },
                ],
                Style(
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

  static func render(props: Props, hooks: Hooks) -> AnyNode {
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
      }]), "Present Simple Modal"),

      StackModal.node(.init(
        isPresented: isStackModalPresented
      )),

      SimpleModal.node(.init(
        frame: props.frame,
        isPresented: isAnimationModalPresented
      )),
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
    ] : [])

    return StackView.node(.init(axis: .vertical,
                                distribution: .fillEqually,
                                Style(frame: props.frame)),
                          children)
  }
}

struct App: PureLeafComponent {
  typealias Props = Rectangle

  static func render(props: Rectangle) -> AnyNode {
    return Counter.node(.init(frame: props, initial: 5))
  }
}
