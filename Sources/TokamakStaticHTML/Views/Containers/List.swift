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

@_spi(TokamakCore) import TokamakCore

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
    AnyView(section.padding(.leading).frame(minWidth: 0, maxWidth: .infinity))
  }

  public func listRow<Row>(_ row: Row) -> AnyView where Row: View {
    AnyView(row.padding(.vertical))
  }
}

extension InsetListStyle: ListStyleDeferredToRenderer {
  public func sectionHeader<Header>(_ header: Header) -> AnyView where Header: View {
    AnyView(
      header
        .font(.system(size: 17, weight: .medium))
        .padding(.vertical, 4)
        .padding(.leading, 24)
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
      .padding(.leading, 24)
      .frame(minWidth: 0, maxWidth: .infinity)
    )
  }

  public func sectionBody<SectionBody>(_ section: SectionBody) -> AnyView where SectionBody: View {
    AnyView(
      section
        .padding(.leading, 24)
        .frame(minWidth: 0, maxWidth: .infinity)
    )
  }

  public func listRow<Row>(_ row: Row) -> AnyView where Row: View {
    AnyView(row.padding(.vertical))
  }
}

extension GroupedListStyle: ListStyleDeferredToRenderer {
  public func listBody<ListBody>(_ content: ListBody) -> AnyView where ListBody: View {
    AnyView(
      content
        .background(Color.groupedListBackground)
    )
  }

  public func sectionHeader<Header>(_ header: Header) -> AnyView where Header: View {
    AnyView(
      header
        .font(.caption)
        .padding([.top, .leading])
        .frame(minWidth: 0, maxWidth: .infinity)
    )
  }

  public func sectionBody<SectionBody>(_ section: SectionBody) -> AnyView where SectionBody: View {
    AnyView(
      section
        .padding(.leading)
        .background(Color.listGroupBackground)
        .padding(.top)
        .frame(minWidth: 0, maxWidth: .infinity)
    )
  }

  public func sectionFooter<Footer>(_ footer: Footer) -> AnyView where Footer: View {
    AnyView(
      footer
        .font(.caption)
        .padding([.top, .leading])
    )
  }

  public func listRow<Row>(_ row: Row) -> AnyView where Row: View {
    AnyView(row.padding(.vertical))
  }
}

extension InsetGroupedListStyle: ListStyleDeferredToRenderer {
  public func listBody<ListBody>(_ content: ListBody) -> AnyView where ListBody: View {
    AnyView(content.background(Color.groupedListBackground))
  }

  public func sectionHeader<Header>(_ header: Header) -> AnyView where Header: View {
    AnyView(
      header
        .font(.caption)
        .padding([.top, .leading])
        .padding(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
    )
  }

  public func sectionBody<SectionBody>(_ section: SectionBody) -> AnyView where SectionBody: View {
    AnyView(
      section
        .padding(.leading)
        .background(Color.listGroupBackground)
        .cornerRadius(10)
        .padding([.horizontal, .top])
        .frame(maxWidth: .infinity, alignment: .leading)
    )
  }

  public func sectionFooter<Footer>(_ footer: Footer) -> AnyView where Footer: View {
    AnyView(
      footer
        .font(.caption)
        .padding([.top, .leading])
        .padding(.leading)
    )
  }

  public func listRow<Row>(_ row: Row) -> AnyView where Row: View {
    AnyView(row.padding(.vertical))
  }
}

// TODO: Make sections collapsible (see Section.swift for more impl. details)
extension SidebarListStyle: ListStyleDeferredToRenderer {
  public func sectionHeader<Header>(_ header: Header) -> AnyView where Header: View {
    AnyView(
      header
        .font(.system(size: 11, weight: .medium))
        .foregroundColor(Color._withScheme {
          switch $0 {
          case .light: return Color(.sRGB, white: 0, opacity: 0.4)
          case .dark: return Color(.sRGB, white: 1, opacity: 0.4)
          }
        })
        .padding(.vertical, 2)
        .padding(.leading, 4)
    )
  }

  public func listRow<Row>(_ row: Row) -> AnyView where Row: View {
    AnyView(row.frame(maxWidth: .infinity, alignment: .leading))
  }

  public func listBody<ListBody>(_ content: ListBody) -> AnyView where ListBody: View {
    AnyView(
      content
        ._navigationLinkStyle(_SidebarNavigationLinkStyle())
        .padding([.horizontal, .top], 6)
        .background(Color.sidebarBackground)
    )
  }
}

public struct _SidebarNavigationLinkStyle: _NavigationLinkStyle {
  @ViewBuilder
  public func makeBody(configuration: _NavigationLinkStyleConfiguration) -> some View {
    if configuration.isSelected {
      configuration
        .padding(6)
        .font(.footnote)
        .background(Color._withScheme {
          switch $0 {
          case .light: return Color(.sRGB, white: 0, opacity: 0.1)
          case .dark: return Color(.sRGB, white: 1, opacity: 0.1)
          }
        })
        .cornerRadius(5)
    } else {
      configuration
        .padding(6)
        .foregroundColor(.primary)
        .font(.footnote)
    }
  }
}
