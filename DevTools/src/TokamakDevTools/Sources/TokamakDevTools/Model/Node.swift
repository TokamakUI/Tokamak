import JavaScriptKit

final class Node: Identifiable, Hashable {
  let type: String
  let isHost: Bool
  let isPrimitive: Bool
  let dynamicProperties: [String]
  let target: String?
  let parent: Int?
  let id: Int

  var typeName: String {
    String(type.split(separator: "<").first!)
  }

  static func == (lhs: Node, rhs: Node) -> Bool {
    lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  var children: [Node]?
  var compositeChildren: [Node]? {
    if let children = children {
      return children.compactMap { node in
        if node.isHost || node.isPrimitive {
          return node.compositeChildren
        } else {
          return [node]
        }
      }.reduce([], +)
    } else {
      return nil
    }
  }

  init(object: JSObjectRef) {
    type = object.type.string!
    isHost = object.isHost.boolean!
    isPrimitive = object.isPrimitive.boolean!
    target = object.target.string
    dynamicProperties = object.dynamicProperties.array!.compactMap(\.string)
    if let parent = object.parent.number {
      self.parent = Int(parent)
    } else {
      parent = nil
    }
    id = Int(object.id.number!)
    children = nil
  }
}

extension Node {
  func firstChild(where predicate: (Node) -> Bool) -> Node? {
    children?.firstChild(where: predicate)
  }
}

extension Array where Element == Node {
  func firstChild(where predicate: (Element) -> Bool) -> Element? {
    first(where: predicate) ?? compactMap { $0.firstChild(where: predicate) }.first
  }
}
