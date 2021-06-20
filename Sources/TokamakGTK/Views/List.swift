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

import CGTK
import TokamakCore

extension List: GTKPrimitive {
  @ViewBuilder
  func iterateAsRow(_ content: [AnyView]) -> some View {
    ForEach(Array(content.enumerated()), id: \.offset) { _, row in
      if let parentView = mapAnyView(row, transform: { (view: ParentView) in view }) {
        AnyView(iterateAsRow(parentView.children))
      } else {
        WidgetView(build: { _ in
          gtk_list_box_row_new()
        }) {
          row
        }
      }
    }
  }

  @_spi(TokamakCore)
  public var renderedBody: AnyView {
    let proxy = _ListProxy(self)
    return AnyView(ScrollView {
      WidgetView(build: { _ in
        gtk_list_box_new()
      }) {
        if let content = proxy.content as? ParentView {
          iterateAsRow(content.children)
        } else {
          WidgetView(build: { _ in
            gtk_list_box_row_new()
          }) {
            proxy.content
          }
        }
      }
    }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity))
  }
}

extension PlainListStyle: ListStyleDeferredToRenderer {
  public func sectionHeader<Header>(_ header: Header) -> AnyView where Header: View {
    AnyView(
      header
        .font(.system(size: 17, weight: .medium))
        .padding(.vertical, 4)
        .padding(.leading)
        .background(Color.listSectionHeader)
        .frame(minWidth: 0, maxWidth: .infinity)
    )
  }

  public func sectionFooter<Footer>(_ footer: Footer) -> AnyView where Footer: View {
    AnyView(
      VStack(alignment: .leading) {
        Divider()
        _ListRow.listRow(footer, self, isLast: true)
      }
      .padding(.leading)
      .frame(minWidth: 0, maxWidth: .infinity)
    )
  }

  public func sectionBody<SectionBody>(_ section: SectionBody) -> AnyView where SectionBody: View {
    // AnyView(section.padding(.leading).frame(minWidth: 0, maxWidth: .infinity))
    AnyView(section)
  }

  public func listRow<Row>(_ row: Row) -> AnyView where Row: View {
    // AnyView(row.padding(.vertical))
    AnyView(
      WidgetView(build: { _ in
        gtk_list_box_row_new()
      }) {
        row
      }
    )
  }

  public func listBody<ListBody>(_ content: ListBody) -> AnyView where ListBody: View {
    AnyView(
      WidgetView(build: { _ in
        gtk_list_box_new()
      }) {
        content
      }
    )
  }
}
