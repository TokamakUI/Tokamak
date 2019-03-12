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

struct SimpleModal: PureLeafComponent {
  struct Props: Equatable {
    let isPresented: State<Bool>
  }

  static func render(props: Props) -> AnyNode {
    return props.isPresented.value ? ModalPresenter.node(
      Animation.node(
        Null(),
        Button.node(.init(
          Style(Center.equal(to: .parent)),
          onPress: Handler { props.isPresented.set(false) },
          text: "Close Modal"
        ))
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
        Edges.equal(to: .safeArea),
        alignment: .center,
        axis: .vertical,
        distribution: .fillEqually
      ),
      [
        Button.node(.init(
          onPress: Handler { isAnimationModalPresented.set(true) },
          text: "Present Simple Modal"
        )),

        Button.node(.init(
          onPress: Handler { isStackModalPresented.set(true) },
          text: "Present Navigation Modal"
        )),

        Button.node(.init(
          onPress: Handler { isTableModalPresented.set(true) },
          text: "Present Table Modal"
        )),

        NavigationModal.node(.init(isPresented: isStackModalPresented)),

        SimpleModal.node(.init(isPresented: isAnimationModalPresented)),

        TableModal.node(.init(isPresented: isTableModalPresented)),
      ]
    )
  }
}
