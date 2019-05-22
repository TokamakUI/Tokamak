import Tokamak

struct HookedLeafComponent: LeafComponent {
  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let hookMadeWithLove = hooks.state("")
    // do not use hooks it loop
    for item in items {
      let hookedItemState = hooks.state("")
    }
  }
}
