//
//  GluonApp.swift
//  Gluon_Example
//
//  Created by Max Desiatov on 31/12/2018.
//  Copyright © 2018 Max Desiatov. All rights reserved.
//

import Gluon

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
              onPress: Handler { props.isPresented.set(false) }
            )
          )
        )
      ) : Null.node()
  }
}

struct SimpleModal: LeafComponent {
  struct Props: Equatable {
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

    return props.isPresented.value ? ModalPresenter.node(
      View.node(.init(Style(backgroundColor: colors[backgroundColor.value].0)),
                StackView.node(.init(
                  axis: .vertical,
                  distribution: .fillEqually,
                  Style(Edges.equal(to: .parent))
                ), [
                  Button.node(.init(
                    onPress: Handler { props.isPresented.set(false) }
                  ), "Close Modal"),
                  SegmentedControl.node(
                    .init(value: backgroundColor.value,
                          valueHandler: Handler(backgroundColor.set)),
                    colors.map { $0.1 }
                  ),
      ]))
    ) : Null.node()
  }
}

struct ListProvider: SimpleCellProvider {
  typealias Props = Null
  typealias Model = [[Int]]

  static func cell(props: Null, item: Int, path: CellPath) -> AnyNode {
    return Label.node("\(item)")
  }
}

struct TableModal: LeafComponent {
  struct Props: Equatable {
    let isPresented: State<Bool>
  }

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let list = ListView<ListProvider>.node(.init(singleSection: [1, 2, 3]))
    return props.isPresented.value ? ModalPresenter.node(list) : Null.node()
  }
}

struct Counter: LeafComponent {
  struct Props: Equatable {
    let initial: Int
  }

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let count = hooks.state(props.initial)
    let sliding = hooks.state(0.5 as Float)
    let isStackModalPresented = hooks.state(false)
    let isAnimationModalPresented = hooks.state(false)
    let isTableModalPresented = hooks.state(false)
    let switchState = hooks.state(true)
    let stepperState = hooks.state(0.0)
    let isEnabled = hooks.state(true)

    let children = [
      StackView.node(
        .init(
          alignment: .center,
          axis: .horizontal,
          spacing: 10.0
        ), [
          Switch.node(
            .init(
              value: isEnabled.value,
              valueHandler: Handler(isEnabled.set)
            )
          ),

          Label.node(
            .init(alignment: .center),
            "isEnabled \(isEnabled.value)"
          ),
        ]
      ),

      Button.node(
        .init(
          isEnabled: isEnabled.value,
          onPress: Handler { isStackModalPresented.set(true) }
        ),
        "Present Stack Modal"
      ),

      Button.node(
        .init(
          isEnabled: isEnabled.value,
          onPress: Handler { isAnimationModalPresented.set(true) }
        ),
        "Present Simple Modal"
      ),

      Button.node(
        .init(
          isEnabled: isEnabled.value,
          onPress: Handler { isTableModalPresented.set(true) }
        ),
        "Present Table Modal"
      ),

      StackModal.node(.init(isPresented: isStackModalPresented)),

      SimpleModal.node(.init(isPresented: isAnimationModalPresented)),

      TableModal.node(.init(isPresented: isTableModalPresented)),
    ] + (count.value < 15 ? [
      StackView.node(
        .init(
          alignment: .center,
          axis: .horizontal,
          spacing: 10.0
        ), [
          Button.node(
            .init(
              isEnabled: isEnabled.value,
              onPress: Handler { count.set { $0 + 1 } }
            ),
            "Increment"
          ),

          Label.node(.init(alignment: .center), "\(count.value)"),
        ]
      ),

      Slider.node(.init(
        isEnabled: isEnabled.value,
        value: sliding.value,
        valueHandler: Handler(sliding.set),
        Style(Width.equal(to: .parent))
      )),

      Label.node(.init(alignment: .center), "\(sliding.value)"),

      StackView.node(
        .init(
          alignment: .center,
          axis: .horizontal,
          spacing: 10.0
        ), [
          Switch.node(
            .init(
              isEnabled: isEnabled.value,
              value: switchState.value,
              valueHandler: Handler(switchState.set)
            )
          ),

          Label.node(.init(alignment: .center), "\(switchState.value)"),
        ]
      ),

      StackView.node(
        .init(
          alignment: .center,
          axis: .horizontal,
          spacing: 10.0
        ), [
          Stepper.node(
            .init(
              isEnabled: isEnabled.value,
              value: stepperState.value,
              valueHandler: Handler(stepperState.set)
            )
          ),

          Label.node(.init(alignment: .center), "\(stepperState.value)"),
        ]
      ),
    ] : [])

    return StackView.node(
      .init(
        alignment: .center,
        axis: .vertical,
        distribution: .fillEqually,
        Style(Edges.equal(to: .parent))
      ),
      children
    )
  }
}

struct App: PureLeafComponent {
  typealias Props = Null

  static func render(props _: Props) -> AnyNode {
    return Counter.node(.init(initial: 1))
  }
}
