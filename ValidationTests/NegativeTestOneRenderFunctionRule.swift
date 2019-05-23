import Tokamak

struct TextFieldExample: LeafComponent {
  typealias Props = Null

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let hookInClosure = hooks.state("")

    return StackView.node(.init(
      alignment: .top,
      axis: .vertical
    ), [
    ])
  }
}
