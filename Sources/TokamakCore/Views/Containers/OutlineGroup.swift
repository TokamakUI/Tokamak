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
//  Created by Carson Katri on 7/3/20.
//

public struct OutlineGroup<Data, ID, Parent, Leaf, Subgroup>
  where Data: RandomAccessCollection, ID: Hashable
{
  enum Root {
    case collection(Data)
    case single(Data.Element)
  }

  let root: Root
  let children: KeyPath<Data.Element, Data?>
  let id: KeyPath<Data.Element, ID>
  let content: (Data.Element) -> Leaf
}

public extension OutlineGroup where ID == Data.Element.ID,
  Parent: View,
  Parent == Leaf,
  Subgroup == DisclosureGroup<Parent, OutlineSubgroupChildren>,
  Data.Element: Identifiable
{
  init<DataElement>(
    _ root: DataElement,
    children: KeyPath<DataElement, Data?>,
    @ViewBuilder content: @escaping (DataElement) -> Leaf
  ) where ID == DataElement.ID, DataElement: Identifiable, DataElement == Data.Element {
    self.init(root, id: \.id, children: children, content: content)
  }

  init<DataElement>(
    _ data: Data,
    children: KeyPath<DataElement, Data?>,
    @ViewBuilder content: @escaping (DataElement) -> Leaf
  ) where ID == DataElement.ID, DataElement: Identifiable, DataElement == Data.Element {
    self.init(data, id: \.id, children: children, content: content)
  }
}

public extension OutlineGroup where Parent: View,
  Parent == Leaf,
  Subgroup == DisclosureGroup<Parent, OutlineSubgroupChildren>
{
  init<DataElement>(
    _ root: DataElement,
    id: KeyPath<DataElement, ID>,
    children: KeyPath<DataElement, Data?>,
    @ViewBuilder content: @escaping (DataElement) -> Leaf
  )
    where DataElement == Data.Element
  {
    self.root = .single(root)
    self.children = children
    self.id = id
    self.content = content
  }

  init<DataElement>(
    _ data: Data,
    id: KeyPath<DataElement, ID>,
    children: KeyPath<DataElement, Data?>,
    @ViewBuilder content: @escaping (DataElement) -> Leaf
  )
    where DataElement == Data.Element
  {
    root = .collection(data)
    self.id = id
    self.children = children
    self.content = content
  }
}

extension OutlineGroup: View where Parent: View, Leaf: View, Subgroup: View {
  @_spi(TokamakCore)
  public var body: some View {
    switch root {
    case let .collection(data):
      return AnyView(ForEach(data, id: id) { elem in
        OutlineSubgroupChildren { () -> AnyView in
          if let subgroup = elem[keyPath: children] {
            return AnyView(DisclosureGroup(content: {
              OutlineGroup(
                root: .collection(subgroup),
                children: children,
                id: id,
                content: content
              )
            }) {
              content(elem)
            })
          } else {
            return AnyView(content(elem))
          }
        }
      })
    case let .single(root):
      return AnyView(DisclosureGroup(content: {
        if let subgroup = root[keyPath: children] {
          OutlineGroup(root: .collection(subgroup), children: children, id: id, content: content)
        } else {
          content(root)
        }
      }) {
        content(root)
      })
    }
  }
}

public struct OutlineSubgroupChildren: View {
  let children: () -> AnyView

  @_spi(TokamakCore)
  public var body: some View {
    children()
  }
}
