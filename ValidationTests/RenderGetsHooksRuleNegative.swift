import Tokamak

struct HooksLessLeafComponent: LeafComponent {
  static func render(props: Props) -> AnyNode {
    let hooks = "Hooks"
    let hookMadeWithLove = hooks
  }
}

struct HookedLeafComponent: LeafComponent {
  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let whoPutHookedHere = hooks.state("not me")
  }
}

struct HooksLessLeafComponent: LeafComponent {
  static func render(props: Props) -> AnyNode {
    let hooks = "Hooks"
    let hookMadeWithLove = hooks
  }
}

struct HooksLessLeafComponent: LeafComponent {
  static func render(props: Props) -> AnyNode {
    let hooks = "Hooks"
    let hookMadeWithLove = hooks
  }
}
