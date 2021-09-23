// Copyright 2020 Tokamak contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Created by Carson Katri on 9/20/21.
//

public enum _VariadicView {
  public typealias ViewRoot = _VariadicView_ViewRoot
  public typealias Children = _VariadicView_Children

  public struct Tree<Root, Content>: View, _VariadicView_AnyTree
    where Root: _VariadicView_ViewRoot, Content: View
  {
    public var root: Root
    public var content: Content

    public var children: Children?
    public var anyContent: AnyView { AnyView(content) }

    @inlinable
    public init(_ root: Root, @ViewBuilder content: () -> Content) {
      self.root = root
      self.content = content()
    }

    public var body: some View {
      if let children = children {
        root.body(children: children)
      }
    }
  }
}

public protocol _VariadicView_ViewRoot {
  associatedtype Body: View
  @ViewBuilder
  func body(children: _VariadicView.Children) -> Self.Body
}

public extension _VariadicView_ViewRoot where Self.Body == Never {
  func body(children: _VariadicView.Children) -> Never {
    fatalError()
  }
}

public struct _VariadicView_Children {
  private var elements: [Element]

  init(elements: [Element]) {
    self.elements = elements
  }
}

extension _VariadicView_Children: RandomAccessCollection {
  public struct Element: View, Identifiable {
    let view: AnyView
    public var id: AnyHashable
    let viewTraits: _ViewTraitStore
    let onTraitsUpdated: (_ViewTraitStore) -> ()

    public func id<ID>(as _: ID.Type = ID.self) -> ID? where ID: Hashable {
      id.base as? ID
    }

    public subscript<Trait>(key: Trait.Type) -> Trait.Value where Trait: _ViewTraitKey {
      get {
        viewTraits.value(forKey: key)
      }
      set {
        var updated = viewTraits
        updated.insert(newValue, forKey: key)
        onTraitsUpdated(updated)
      }
    }

    public var body: some View {
      view
    }
  }

  public var startIndex: Int { elements.startIndex }
  public var endIndex: Int { elements.endIndex }
  public subscript(index: Int) -> Element { elements[index] }

  public typealias Index = Int
  public typealias Indices = Range<Int>
  public typealias Iterator = IndexingIterator<_VariadicView_Children>
  public typealias SubSequence = Slice<_VariadicView_Children>
}

extension _VariadicView_Children: View {
  public var body: some View {
    ForEach(elements) { $0 }
  }
}

public protocol _VariadicView_AnyTree {
  var anyContent: AnyView { get }
  var children: _VariadicView.Children? { get set }
}
