import Tokamak

struct TextFieldExample {
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
      alignment: .top,
      axis: .vertical
    ), [
    ])
  }

  static func render(props: Props, hooks: Hooks) {
    print("blah")
  }
}
