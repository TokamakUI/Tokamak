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
//  Created by Carson Katri on 8/2/20.
//

public struct _NavigationLinkStyleConfiguration: View {
  public let body: AnyView
  public let isSelected: Bool
}

public protocol _NavigationLinkStyle {
  associatedtype Body: View
  typealias Configuration = _NavigationLinkStyleConfiguration
  func makeBody(configuration: Configuration) -> Self.Body
}

public struct _DefaultNavigationLinkStyle: _NavigationLinkStyle {
  public func makeBody(configuration: Configuration) -> some View {
    configuration.foregroundColor(.accentColor)
  }
}

public struct _AnyNavigationLinkStyle: _NavigationLinkStyle {
  public typealias Body = AnyView

  private let bodyClosure: (_NavigationLinkStyleConfiguration) -> AnyView
  public let type: Any.Type

  public init<S: _NavigationLinkStyle>(_ style: S) {
    type = S.self
    bodyClosure = { configuration in
      AnyView(style.makeBody(configuration: configuration))
    }
  }

  public func makeBody(configuration: Configuration) -> AnyView {
    bodyClosure(configuration)
  }
}

public enum _NavigationLinkStyleKey: EnvironmentKey {
  public static var defaultValue: _AnyNavigationLinkStyle {
    _AnyNavigationLinkStyle(_DefaultNavigationLinkStyle())
  }
}

extension EnvironmentValues {
  var _navigationLinkStyle: _AnyNavigationLinkStyle {
    get {
      self[_NavigationLinkStyleKey.self]
    }
    set {
      self[_NavigationLinkStyleKey.self] = newValue
    }
  }
}

public extension View {
  @_spi(TokamakCore)
  func _navigationLinkStyle<S: _NavigationLinkStyle>(_ style: S) -> some View {
    environment(\._navigationLinkStyle, _AnyNavigationLinkStyle(style))
  }
}
