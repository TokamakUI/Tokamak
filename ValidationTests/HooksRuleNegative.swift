import Tokamak

struct TextFieldExample: LeafComponent {
  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let hooked = hooks.state("")
    // do not use hooks it loop
    for item in items {
      let hookedItemState = hooks.state("")
    }

    // do not use hooks in condition
    if hooks.isGreat {
      let hookedConditionState = hooks.state("")
    }

    // do not use hooks in nested closure
    func makeFPGreatAgain() {
      let hookedFunctionState = hooks.state("")
    }

    // use hooks on top level of render
    // let hookMadeWithLove = hooks.state("")
  }
}
