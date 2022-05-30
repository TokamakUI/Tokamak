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
//  Created by Jed Fox on 06/30/2020.
//

public final class NavigationContext: ObservableObject {
  @Published
  var destination = NavigationLinkDestination(EmptyView())
}

public struct NavigationView<Content>: _PrimitiveView where Content: View {
  let content: Content

  @StateObject
  var context = NavigationContext()

  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }
}

private struct ToolbarReader<Content>: View where Content: View {
  let content: (_ title: AnyView?, _ toolbarContent: [AnyToolbarItem]?) -> Content

  var body: some View {
    ToolbarKey._delay {
      $0._force { bar in
        NavigationTitleKey._delay {
          $0
            ._force {
              content($0, bar.items.isEmpty && $0 == nil ? nil : bar.items)
            }
        }
      }
    }
  }
}

/// This is a helper type that works around absence of "package private" access control in Swift
public struct _NavigationViewProxy<Content: View> {
  public let subject: NavigationView<Content>

  public init(_ subject: NavigationView<Content>) { self.subject = subject }

  public var context: NavigationContext { subject.context }

  /// Builds the content of the `NavigationView` by passing in the title and toolbar if present.
  /// If `toolbarContent` is `nil`, you shouldn't render a toolbar.
  public func makeToolbar<DeferredBar>(
    @ViewBuilder _ content: @escaping (_ title: AnyView?, _ toolbarContent: [AnyToolbarItem]?)
      -> DeferredBar
  ) -> some View where DeferredBar: View {
    ToolbarReader(content: content)
  }

  public var content: some View {
    subject.content
      .environmentObject(context)
  }

  public var destination: some View {
    subject.context.destination.view
      .environmentObject(context)
  }
}

struct NavigationDestinationKey: EnvironmentKey {
  public static let defaultValue: Binding<AnyView>? = nil
}

extension EnvironmentValues {
  var navigationDestination: Binding<AnyView>? {
    get {
      self[NavigationDestinationKey.self]
    }
    set {
      self[NavigationDestinationKey.self] = newValue
    }
  }
}

struct NavigationTitleKey: PreferenceKey {
  typealias Value = AnyView?
  static func reduce(value: inout AnyView?, nextValue: () -> AnyView?) {
    value = nextValue()
  }
}

struct NavigationBarItemKey: PreferenceKey {
  static let defaultValue: NavigationBarItem = .init(displayMode: .automatic)
  static func reduce(value: inout NavigationBarItem, nextValue: () -> NavigationBarItem) {
    value = nextValue()
  }
}
