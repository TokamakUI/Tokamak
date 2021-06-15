// Copyright 2018-2021 Tokamak contributors
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
//  Created by Max Desiatov on 06/06/2021.
//

public extension List {
  // - MARK: Collection initializers
  init<Data, RowContent>(
    _ data: Data,
    selection: Binding<Set<SelectionValue>>?,
    @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
  )
    where Content == ForEach<Data, Data.Element.ID, HStack<RowContent>>,
    Data: RandomAccessCollection, RowContent: View,
    Data.Element: Identifiable
  {
    self.init(selection: selection) { ForEach(data) { row in HStack { rowContent(row) } } }
  }

  init<Data, ID, RowContent>(
    _ data: Data,
    id: KeyPath<Data.Element, ID>,
    selection: Binding<Set<SelectionValue>>?,
    @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
  )
    where Content == ForEach<Data, ID, HStack<RowContent>>,
    Data: RandomAccessCollection,
    ID: Hashable, RowContent: View
  {
    self.init(selection: selection) { ForEach(data, id: id) { row in HStack { rowContent(row) } } }
  }

  init<Data, ID, RowContent>(
    _ data: Data,
    id: KeyPath<Data.Element, ID>,
    selection: Binding<SelectionValue?>?,
    @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
  )
    where Content == ForEach<Data, ID, HStack<RowContent>>,
    Data: RandomAccessCollection, ID: Hashable, RowContent: View
  {
    self.init(selection: selection) {
      ForEach(data, id: id) { row in
        HStack { rowContent(row) }
      }
    }
  }

  init<Data, RowContent>(
    _ data: Data,
    selection: Binding<SelectionValue?>?,
    @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
  )
    where Content == ForEach<Data, Data.Element.ID, HStack<RowContent>>,
    Data: RandomAccessCollection, RowContent: View, Data.Element: Identifiable
  {
    self.init(selection: selection) {
      ForEach(data) { row in
        HStack {
          rowContent(row)
        }
      }
    }
  }

  // - MARK: Range initializers
  init<RowContent>(
    _ data: Range<Int>,
    selection: Binding<Set<SelectionValue>>?,
    @ViewBuilder rowContent: @escaping (Int) -> RowContent
  )
    where Content == ForEach<Range<Int>, Int, HStack<RowContent>>, RowContent: View
  {
    self.init(selection: selection) {
      ForEach(data) { row in
        HStack { rowContent(row) }
      }
    }
  }

  init<RowContent>(
    _ data: Range<Int>,
    selection: Binding<SelectionValue?>?,
    @ViewBuilder rowContent: @escaping (Int) -> RowContent
  )
    where Content == ForEach<Range<Int>, Int, HStack<RowContent>>, RowContent: View
  {
    self.init(selection: selection) {
      ForEach(data) { row in
        HStack { rowContent(row) }
      }
    }
  }

  // - MARK: OutlineGroup initializers

  init<Data, RowContent>(
    _ data: Data,
    children: KeyPath<Data.Element, Data?>,
    selection: Binding<Set<SelectionValue>>?,
    @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
  )
    where Content == OutlineGroup<
      Data,
      Data.Element.ID,
      HStack<RowContent>,
      HStack<RowContent>,
      DisclosureGroup<HStack<RowContent>, OutlineSubgroupChildren>
    >, Data: RandomAccessCollection, RowContent: View, Data.Element: Identifiable
  {
    self.init(selection: selection) {
      OutlineGroup(data, children: children) { row in
        HStack { rowContent(row) }
      }
    }
  }

  init<Data, ID, RowContent>(
    _ data: Data,
    id: KeyPath<Data.Element, ID>,
    children: KeyPath<Data.Element, Data?>,
    selection: Binding<Set<SelectionValue>>?,
    @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
  )
    where Content == OutlineGroup<
      Data,
      ID,
      HStack<RowContent>,
      HStack<RowContent>,
      DisclosureGroup<HStack<RowContent>, OutlineSubgroupChildren>
    >, Data: RandomAccessCollection, ID: Hashable, RowContent: View
  {
    self.init(selection: selection) {
      OutlineGroup(data, id: id, children: children) { row in
        HStack { rowContent(row) }
      }
    }
  }

  init<Data, RowContent>(
    _ data: Data,
    children: KeyPath<Data.Element, Data?>,
    selection: Binding<SelectionValue?>?,
    @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
  )
    where Content == OutlineGroup<
      Data,
      Data.Element.ID,
      HStack<RowContent>,
      HStack<RowContent>,
      DisclosureGroup<HStack<RowContent>, OutlineSubgroupChildren>
    >, Data: RandomAccessCollection, RowContent: View, Data.Element: Identifiable
  {
    self.init(selection: selection) {
      OutlineGroup(data, children: children) { row in
        HStack { rowContent(row) }
      }
    }
  }

  init<Data, ID, RowContent>(
    _ data: Data,
    id: KeyPath<Data.Element, ID>,
    children: KeyPath<Data.Element, Data?>,
    selection: Binding<SelectionValue?>?,
    @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
  )
    where Content == OutlineGroup<
      Data,
      ID,
      HStack<RowContent>,
      HStack<RowContent>,
      DisclosureGroup<HStack<RowContent>, OutlineSubgroupChildren>
    >, Data: RandomAccessCollection, ID: Hashable, RowContent: View
  {
    self.init(selection: selection) {
      OutlineGroup(data, id: id, children: children) { row in
        HStack { rowContent(row) }
      }
    }
  }
}
