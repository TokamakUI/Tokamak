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

public protocol ListStyle {
  var hasDividers: Bool { get }
}

/// A protocol implemented on the renderer to create platform-specific list styles.
public protocol ListStyleDeferredToRenderer {
  func listBody<ListBody>(_ content: ListBody) -> AnyView where ListBody: View
  func listRow<Row>(_ row: Row) -> AnyView where Row: View
  func sectionHeader<Header>(_ header: Header) -> AnyView where Header: View
  func sectionBody<SectionBody>(_ section: SectionBody) -> AnyView where SectionBody: View
  func sectionFooter<Footer>(_ footer: Footer) -> AnyView where Footer: View
}

public extension ListStyleDeferredToRenderer {
  func listBody<ListBody>(_ content: ListBody) -> AnyView where ListBody: View {
    AnyView(content)
  }

  func listRow<Row>(_ row: Row) -> AnyView where Row: View {
    AnyView(row.padding([.trailing, .top, .bottom]))
  }

  func sectionHeader<Header>(_ header: Header) -> AnyView where Header: View {
    AnyView(header)
  }

  func sectionBody<SectionBody>(_ section: SectionBody) -> AnyView where SectionBody: View {
    AnyView(section)
  }

  func sectionFooter<Footer>(_ footer: Footer) -> AnyView where Footer: View {
    AnyView(footer)
  }
}

public typealias DefaultListStyle = PlainListStyle

public struct PlainListStyle: ListStyle {
  public var hasDividers = true
  public init() {}
}

public struct GroupedListStyle: ListStyle {
  public var hasDividers = true
  public init() {}
}

public struct InsetListStyle: ListStyle {
  public var hasDividers = true
  public init() {}
}

public struct InsetGroupedListStyle: ListStyle {
  public var hasDividers = true
  public init() {}
}

public struct SidebarListStyle: ListStyle {
  public var hasDividers = false
  public init() {}
}

enum ListStyleKey: EnvironmentKey {
  static let defaultValue: ListStyle = DefaultListStyle()
}

extension EnvironmentValues {
  var listStyle: ListStyle {
    get {
      self[ListStyleKey.self]
    }
    set {
      self[ListStyleKey.self] = newValue
    }
  }
}

public extension View {
  func listStyle<S>(_ style: S) -> some View where S: ListStyle {
    environment(\.listStyle, style)
  }
}
