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

import TokamakCore

extension PlainListStyle: ListStyleDeferredToRenderer {
  public func sectionHeader<Header>(_ header: Header) -> AnyView where Header: View {
    AnyView(
      header
        .padding(.vertical, 5)
        .background(Color(0xDDDDDD))
    )
  }

  public func sectionFooter<Footer>(_ footer: Footer) -> AnyView where Footer: View {
    AnyView(VStack {
      Divider()
      _ListRow.listRow(footer, self, isLast: true)
    })
  }
}

extension GroupedListStyle: ListStyleDeferredToRenderer {
  public func listBody<ListBody>(_ content: ListBody) -> AnyView where ListBody: View {
    AnyView(
      content
        .padding(.top, 20)
        .background(Color(0xEEEEEE))
    )
  }

  public func sectionHeader<Header>(_ header: Header) -> AnyView where Header: View {
    AnyView(
      header
        .font(.caption)
        .padding(.leading, 20)
    )
  }

  public func sectionBody<SectionBody>(_ section: SectionBody) -> AnyView where SectionBody: View {
    AnyView(
      section
        .background(Color.white)
        .padding(.top)
    )
  }

  public func sectionFooter<Footer>(_ footer: Footer) -> AnyView where Footer: View {
    AnyView(
      footer
        .font(.caption)
        .padding(.leading, 20)
    )
  }
}

extension InsetGroupedListStyle: ListStyleDeferredToRenderer {
  public func listBody<ListBody>(_ content: ListBody) -> AnyView where ListBody: View {
    AnyView(
      content
        .padding(.top, 20)
        .background(Color(0xEEEEEE))
    )
  }

  public func listRow<Row>(_ row: Row) -> AnyView where Row: View {
    AnyView(
      row
        .padding([.leading, .trailing, .top, .bottom])
    )
  }

  public func sectionHeader<Header>(_ header: Header) -> AnyView where Header: View {
    AnyView(
      header
        .font(.caption)
        .padding(.leading, 20)
    )
  }

  public func sectionBody<SectionBody>(_ section: SectionBody) -> AnyView where SectionBody: View {
    AnyView(
      section
        .background(Color.white)
        .cornerRadius(10)
        .padding(.all)
    )
  }

  public func sectionFooter<Footer>(_ footer: Footer) -> AnyView where Footer: View {
    AnyView(
      footer
        .font(.caption)
        .padding(.leading, 20)
    )
  }
}

extension SidebarListStyle: ListStyleDeferredToRenderer {
  public func listBody<ListBody>(_ content: ListBody) -> AnyView where ListBody: View {
    AnyView(
      content
        .padding(.all)
        .padding(.leading, 20)
        .background(Color(0xF2F2F7))
    )
  }
}
