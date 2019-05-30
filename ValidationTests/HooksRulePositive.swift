import Tokamak

struct HookedLeafComponent: LeafComponent {
  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let hookMadeWithLove = hooks.state("")
  }
}

extension Hooks {
  var theAnswerToLifeTheUniverseAndEverything: State<Int> {
    return state(42)
  }
}

struct AnotherHookedLeafComponent: LeafComponent {
  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let hookMadeWithLove = hooks.state("")
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

struct OneMoreHookedLeafComponent: LeafComponent {
  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let hookMadeWithLove = hooks.state("")
  }
}

extension String {
  let str = "number"
}
