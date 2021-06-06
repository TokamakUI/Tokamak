// Copyright 2018-2020 Tokamak contributors
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
//  Created by Carson Katri on 7/2/20.
//

public struct List<SelectionValue, Content>: View
  where SelectionValue: Hashable, Content: View
{
  public enum _Selection {
    case one(Binding<SelectionValue?>?)
    case many(Binding<Set<SelectionValue>>?)
  }

  let selection: _Selection
  let content: Content

  @Environment(\.listStyle) var style

  public init(selection: Binding<Set<SelectionValue>>?, @ViewBuilder content: () -> Content) {
    self.selection = .many(selection)
    self.content = content()
  }

  public init(selection: Binding<SelectionValue?>?, @ViewBuilder content: () -> Content) {
    self.selection = .one(selection)
    self.content = content()
  }

  var listStack: some View {
    VStack(alignment: .leading) { () -> AnyView in
      if let contentContainer = content as? ParentView {
        var sections = [AnyView]()
        var currentSection = [AnyView]()
        for child in contentContainer.children {
          if child.view is SectionView {
            if currentSection.count > 0 {
              sections.append(AnyView(Section {
                ForEach(Array(currentSection.enumerated()), id: \.offset) { _, view in view }
              }))
              currentSection = []
            }
            sections.append(child)
          } else {
            if child.children.count > 0 {
              currentSection.append(contentsOf: child.children)
            } else {
              currentSection.append(child)
            }
          }
        }
        if currentSection.count > 0 {
          sections.append(AnyView(Section {
            ForEach(Array(currentSection.enumerated()), id: \.offset) { _, view in view }
          }))
        }
        return AnyView(_ListRow.buildItems(sections) { view, isLast in
          if let section = view.view as? SectionView {
            section.listRow(style)
          } else {
            _ListRow.listRow(view, style, isLast: isLast)
          }
        })
      } else {
        return AnyView(content)
      }
    }
  }

  @_spi(TokamakCore)
  public var body: some View {
    if let style = style as? ListStyleDeferredToRenderer {
      style.listBody(ScrollView {
        HStack { Spacer() }
        listStack
          .environment(\._outlineGroupStyle, _ListOutlineGroupStyle())
      })
        .frame(minHeight: 0, maxHeight: .infinity)
    } else {
      ScrollView {
        HStack { Spacer() }
        listStack
          .environment(\._outlineGroupStyle, _ListOutlineGroupStyle())
      }
    }
  }
}

public enum _ListRow {
  static func buildItems<RowView>(
    _ children: [AnyView],
    @ViewBuilder rowView: @escaping (AnyView, Bool) -> RowView
  ) -> some View where RowView: View {
    ForEach(Array(children.enumerated()), id: \.offset) { offset, view in
      VStack(alignment: .leading) {
        HStack { Spacer() }
        rowView(view, offset == children.count - 1)
      }
    }
  }

  @ViewBuilder
  public static func listRow<V: View>(_ view: V, _ style: ListStyle, isLast: Bool) -> some View {
    (style as? ListStyleDeferredToRenderer)?.listRow(view) ??
      AnyView(view.padding([.trailing, .top, .bottom]))
    if !isLast && style.hasDividers {
      Divider()
    }
  }
}

/// This is a helper type that works around absence of "package private" access control in Swift
public struct _ListProxy<SelectionValue, Content>
  where SelectionValue: Hashable, Content: View
{
  public let subject: List<SelectionValue, Content>

  public init(_ subject: List<SelectionValue, Content>) {
    self.subject = subject
  }

  public var content: Content { subject.content }
  public var selection: List<SelectionValue, Content>._Selection { subject.selection }
}

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

public extension List where SelectionValue == Never {
  init(@ViewBuilder content: () -> Content) {
    selection = .one(nil)
    self.content = content()
  }

  init<Data, RowContent>(
    _ data: Data,
    @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
  )
    where Content == ForEach<Data, Data.Element.ID, HStack<RowContent>>,
    Data: RandomAccessCollection, RowContent: View, Data.Element: Identifiable
  {
    selection = .one(nil)
    content = ForEach(data) { row in
      HStack { rowContent(row) }
    }
  }

  init<Data, RowContent>(
    _ data: Data,
    children: KeyPath<Data.Element, Data?>,
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
    self.init {
      OutlineGroup(data, children: children) { row in
        HStack { rowContent(row) }
      }
    }
  }

  init<Data, ID, RowContent>(
    _ data: Data,
    id: KeyPath<Data.Element, ID>,
    children: KeyPath<Data.Element, Data?>,
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
    self.init {
      OutlineGroup(data, id: id, children: children) { row in
        HStack { rowContent(row) }
      }
    }
  }

  init<Data, ID, RowContent>(
    _ data: Data,
    id: KeyPath<Data.Element, ID>,
    @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
  )
    where Content == ForEach<Data, ID, HStack<RowContent>>,
    Data: RandomAccessCollection, ID: Hashable, RowContent: View
  {
    selection = .one(nil)
    content = ForEach(data, id: id) { row in
      HStack { rowContent(row) }
    }
  }

  init<RowContent>(
    _ data: Range<Int>,
    @ViewBuilder rowContent: @escaping (Int) -> RowContent
  )
    where Content == ForEach<Range<Int>, Int, HStack<RowContent>>, RowContent: View
  {
    selection = .one(nil)
    content = ForEach(data) { row in
      HStack { rowContent(row) }
    }
  }
}
