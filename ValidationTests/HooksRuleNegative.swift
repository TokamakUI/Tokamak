import Tokamak

struct HookedLeafComponent: LeafComponent {
  static func render(props: Props, hooks: Hooks) -> AnyNode {
    // do not use hooks in the loop
    for item in items {
      let hookedItemState = hooks.state("")
    }

    // use hooks on top level of the render
    let hooked = hooks.state("")

    // do not use hooks in the condition
    if hooks.isGreat {
      let hookedConditionState = hooks.state("")
    }

    // do not use hooks in the nested closure
    func makeFPGreatAgain() {
      let hookedFunctionState = hooks.state("")
    }
  }
}

struct AnotherHookedLeafComponent: LeafComponent {
  static func render(props: Props, hooks: Hooks) -> AnyNode {
    // do not use hooks in the loop
    for item in items {
      let hookedItemState = hooks.state("")
    }

    // do not use hooks in the condition
    if hooks.isGreat {
      let hookedConditionState = hooks.state("")
    }

    // use hooks on top level of the render
    let hooked = hooks.state("")

    // do not use hooks in the nested closure
    func makeFPGreatAgain() {
      let hookedFunctionState = hooks.state("")
    }
  }
}
