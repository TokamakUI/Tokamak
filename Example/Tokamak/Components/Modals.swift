//
//  Modals.swift
//  Tokamak_Example
//
//  Created by Max Desiatov on 14/02/2019.
//  Copyright © 2019 Max Desiatov. All rights reserved.
//

import Tokamak

struct NavigationModal: PureLeafComponent {
  struct Props: Equatable {
    let isPresented: State<Bool>
  }

  static func render(props: Props) -> AnyNode {
    return props.isPresented.value ?
      ModalPresenter.node(
        NavigationPresenter<ModalRouter>.node(
          .init(
            initial: .first,
            prefersLargeTitles: true,
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
      View.node(
        .init(Style(
          backgroundColor: colors[backgroundColor.value].0,
          Edges.equal(to: .parent)
        )),
        StackView.node(.init(
          axis: .vertical,
          distribution: .fillEqually,
          Edges.equal(to: .parent)
        ), [
          Button.node(.init(
            onPress: Handler { props.isPresented.set(false) }
          ), "Close Modal"),
          SegmentedControl.node(
            .init(value: backgroundColor.value,
                  valueHandler: Handler(backgroundColor.set)),
            colors.map { $0.1 }
          ),
        ])
      )
    ) : Null.node()
  }
}

struct Modals: LeafComponent {
  typealias Props = Null

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let isStackModalPresented = hooks.state(false)
    let isAnimationModalPresented = hooks.state(false)
    let isTableModalPresented = hooks.state(false)

    return StackView.node(
      .init(
        alignment: .center,
        axis: .vertical,
        distribution: .fillEqually,
        Edges.equal(to: .safeArea)
      ),
      [
        Button.node(
          .init(onPress: Handler { isAnimationModalPresented.set(true) }),
          "Present Simple Modal"
        ),

        Button.node(
          .init(onPress: Handler { isStackModalPresented.set(true) }),
          "Present Navigation Modal"
        ),

        Button.node(
          .init(onPress: Handler { isTableModalPresented.set(true) }),
          "Present Table Modal"
        ),

        NavigationModal.node(.init(isPresented: isStackModalPresented)),

        SimpleModal.node(.init(isPresented: isAnimationModalPresented)),

        TableModal.node(.init(isPresented: isTableModalPresented)),
      ]
    )
  }
}
