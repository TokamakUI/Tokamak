import Tokamak

struct HookedLeafComponent: LeafComponent {
  static func render(props: Props, hooks: Hooks) -> AnyNode {
    // do not use hooks it loop
    for item in items {
      let hookedItemState = hooks.state("")
    }

    // use hooks on top level of render
    let hooked = hooks.state("")

    // do not use hooks in condition
    if hooks.isGreat {
      let hookedConditionState = hooks.state("")
    }

    // do not use hooks in nested closure
    func makeFPGreatAgain() {
      let hookedFunctionState = hooks.state("")
    }
  }
}

struct AnotherHookedLeafComponent: LeafComponent {
  static func render(props: Props, hooks: Hooks) -> AnyNode {
    // do not use hooks it loop
    for item in items {
      let hookedItemState = hooks.state("")
    }

    // do not use hooks in condition
    if hooks.isGreat {
      let hookedConditionState = hooks.state("")
    }

    // use hooks on top level of render
    let hooked = hooks.state("")

    // do not use hooks in nested closure
    func makeFPGreatAgain() {
      let hookedFunctionState = hooks.state("")
    }
  }
}
