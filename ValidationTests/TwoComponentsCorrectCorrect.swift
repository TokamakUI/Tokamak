import Tokamak

struct FirstCorrectComponent: LeafComponent {
  typealias Props = Null

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let text = hooks.state("")
    let textFieldStyle = Style(
      [
        Height.equal(to: 44),
        Width.equal(to: .parent),
      ]
    )

    return StackView.node(.init(
      [
        Leading.equal(to: .safeArea),
        Trailing.equal(to: .safeArea),
        Top.equal(to: .safeArea),
      ],
      alignment: .top,
      axis: .vertical
    ), [
      TextField.node(.init(
        textFieldStyle,
        placeholder: "Default",
        value: text.value,
        valueHandler: Handler(text.set)
      )),
    ])
  }
}

struct SecondCorrectComponent: LeafComponent {
  typealias Props = Null

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let text = hooks.state("")
    let textFieldStyle = Style(
      [
        Height.equal(to: 44),
        Width.equal(to: .parent),
      ]
    )

    return StackView.node(.init(
      [
        Leading.equal(to: .safeArea),
        Trailing.equal(to: .safeArea),
        Top.equal(to: .safeArea),
      ],
      alignment: .top,
      axis: .vertical
    ), [
      TextField.node(.init(
        textFieldStyle,
        placeholder: "Default",
        value: text.value,
        valueHandler: Handler(text.set)
      )),
    ])
  }
}
