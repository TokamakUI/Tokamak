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
    func createHookedItem() {
      let hookedFunctionState = hooks.state("")
    }
  }
}

// don't use Hooks in extesion on non first level
extension Hooks {
  var blah: State<Int> {
    if true {
      return state(0)
    } else {
      return state(42)
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
    func createHookedItem() {
      let hookedFunctionState = hooks.state("")
    }
  }
}

// good extension among broken
extension Hooks {
  var theAnswerToLifeTheUniverseAndEverything: State<Int> {
    return state(42)
  }
}

// don't use state in conditions
extension Hooks {
  func test(_ condition: Bool) -> State<Int> {
    if condition {
      return state(0)
    } else {
      return state(42)
    }
  }
}

struct ConditionHookedLeafComponent: LeafComponent {
  static func render(props: Props, hooks: Hooks) {
    if props.condition {
      return hooks.blah
    } else {
      return hooks.blah
    }
  }
}

extension Hooks {
  var whatDoesTheDogSay: State<String> {
    return state("Woof-Woof")
  }

  func sayHiTo(name: String) -> String {
    return "Hi \(name)!"
  }
}
