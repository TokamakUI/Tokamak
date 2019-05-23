import Tokamak

struct HookedLeafComponent: LeafComponent {
  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let hookMadeWithLove = hooks.state("")
  }
}

struct AnotherHookedLeafComponent: LeafComponent {
  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let hookMadeWithLove = hooks.state("")
  }
}

struct OneMoreHookedLeafComponent: LeafComponent {
  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let hookMadeWithLove = hooks.state("")
  }
}
