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
//  Created by Carson Katri on 7/5/20.
//

protocol SectionView {
  func listRow(_ style: ListStyle) -> AnyView
}

public struct Section<Parent, Content, Footer> {
  let header: Parent
  let footer: Footer
  let content: Content
}

extension Section: View, SectionView where Parent: View, Content: View, Footer: View {
  public init(header: Parent, footer: Footer, @ViewBuilder content: () -> Content) {
    self.header = header
    self.footer = footer
    self.content = content()
  }

  @ViewBuilder
  public var body: TupleView<(Parent, Content, Footer)> {
    header
    content
    footer
  }

  func sectionContent(_ style: ListStyle) -> AnyView {
    if let contentContainer = content as? ParentView {
      return AnyView(_ListRow.buildItems(contentContainer.children) { view, isLast in
        _ListRow.listRow(view, style, isLast: isLast)
      })
    } else {
      return AnyView(content)
    }
  }

  func plainFooterView(_ style: ListStyle) -> AnyView {
    if footer is EmptyView {
      return AnyView(EmptyView())
    } else {
      return AnyView(_ListRow.listRow(footer, style, isLast: true))
    }
  }

  var plainHeaderView: AnyView {
    if header is EmptyView {
      return AnyView(EmptyView())
    } else {
      return AnyView(header
        .padding(.vertical, 5)
        .background(Color(0xBBBBBB)))
    }
  }

  func listRow(_ style: ListStyle) -> AnyView {
    if style is GroupedListStyle || style is InsetGroupedListStyle {
      return AnyView(VStack(alignment: .leading) {
        header
          .font(.caption)
          .padding(.leading, 20)
        sectionContent(style)
          .background(Color.white)
          .cornerRadius(style is InsetGroupedListStyle ? 10 : 0)
          .padding(style is InsetGroupedListStyle ? .all : .top)
        footer
          .font(.caption)
          .padding(.leading, 20)
      })
    } else {
      return AnyView(VStack(alignment: .leading) {
        plainHeaderView
        sectionContent(style)
        plainFooterView(style)
      })
    }
  }
}

extension Section where Parent == EmptyView, Content: View, Footer: View {
  public init(footer: Footer, @ViewBuilder content: () -> Content) {
    self.init(header: EmptyView(), footer: footer, content: content)
  }
}

extension Section where Parent: View, Content: View, Footer == EmptyView {
  public init(header: Parent, @ViewBuilder content: () -> Content) {
    self.init(header: header, footer: EmptyView(), content: content)
  }
}

extension Section where Parent == EmptyView, Content: View, Footer == EmptyView {
  public init(@ViewBuilder content: () -> Content) {
    self.init(header: EmptyView(), footer: EmptyView(), content: content)
  }
}

// FIXME: Implement IsCollapsibleTraitKey (and TraitKeys)
// extension Section where Parent : View, Content : View, Footer : View {
//  public func collapsible(_ collapsible: Bool) -> some View
// }
