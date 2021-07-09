// Copyright 2020-2021 Tokamak contributors
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

import Foundation

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
  @_spi(TokamakCore)
  public var body: TupleView<(Parent, Content, Footer)> {
    header
    content
    footer
  }

  func sectionContent(_ style: ListStyle) -> AnyView {
    if let contentContainer = content as? ParentView {
      let rows = _ListRow.buildItems(contentContainer.children) { view, isLast in
        _ListRow.listRow(view, style, isLast: isLast)
      }
      if let style = style as? ListStyleDeferredToRenderer {
        return style.sectionBody(rows)
      } else {
        return AnyView(rows)
      }
    } else if let style = style as? ListStyleDeferredToRenderer {
      return style.sectionBody(content)
    } else {
      return AnyView(content)
    }
  }

  func footerView(_ style: ListStyle) -> AnyView {
    if footer is EmptyView {
      return AnyView(EmptyView())
    } else if let style = style as? ListStyleDeferredToRenderer {
      return style.sectionFooter(footer)
    } else {
      return AnyView(_ListRow.listRow(footer, style, isLast: true))
    }
  }

  func headerView(_ style: ListStyle) -> AnyView {
    if header is EmptyView {
      return AnyView(EmptyView())
    } else if let style = style as? ListStyleDeferredToRenderer {
      return style.sectionHeader(header)
    } else {
      return AnyView(header)
    }
  }

  func listRow(_ style: ListStyle) -> AnyView {
    AnyView(
      VStack(alignment: .leading, spacing: 0) {
        headerView(style)
        sectionContent(style)
        footerView(style)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    )
  }
}

public extension Section where Parent == EmptyView, Content: View, Footer: View {
  init(footer: Footer, @ViewBuilder content: () -> Content) {
    self.init(header: EmptyView(), footer: footer, content: content)
  }
}

public extension Section where Parent: View, Content: View, Footer == EmptyView {
  init(header: Parent, @ViewBuilder content: () -> Content) {
    self.init(header: header, footer: EmptyView(), content: content)
  }
}

public extension Section where Parent == EmptyView, Content: View, Footer == EmptyView {
  init(@ViewBuilder content: () -> Content) {
    self.init(header: EmptyView(), footer: EmptyView(), content: content)
  }
}

// FIXME: Implement IsCollapsibleTraitKey (and TraitKeys)
// extension Section where Parent : View, Content : View, Footer : View {
//  public func collapsible(_ collapsible: Bool) -> some View
// }
