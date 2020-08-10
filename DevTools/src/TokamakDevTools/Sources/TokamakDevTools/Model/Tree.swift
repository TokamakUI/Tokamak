import JavaScriptKit
import TokamakDOM

final class Tree: ObservableObject {
  @Published var nodes: Set<Node>
  @Published var root: Node!

  func traverse() {
    for node in nodes {
      node.children = nodes.filter { $0.parent == node.id }
      if node.children?.count == 0 {
        node.children = nil
      }
    }
    root = nodes.first { $0.parent == nil }!
  }

  init() {
    let data: JSValue = JSObjectRef.global.window.object!._tokamak_debug_tree
    nodes = Set(data.array!.map {
      Node(object: $0.object!)
    })
    traverse()
    let listener = JSObjectRef.global.window.object!.addEventListener!(
      "tree-update",
      JSClosure { e in
        let changes = Set(
          e[0].object!.detail.array!
            .map { Node(object: $0.object!) }
        )
        self.nodes = changes.union(self.nodes)
        self.traverse()
        return .undefined
      }
    )
  }
}
