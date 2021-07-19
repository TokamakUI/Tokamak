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
//  Created by Carson Katri on 7/12/21.
//

import Foundation

public protocol ControlGroupStyle {
  associatedtype Body: View
  @ViewBuilder
  func makeBody(configuration: Self.Configuration) -> Self.Body
  typealias Configuration = ControlGroupStyleConfiguration
}

public struct ControlGroupStyleConfiguration {
  public struct Content: View {
    public let body: AnyView
  }

  public let content: ControlGroupStyleConfiguration.Content
}

public struct AutomaticControlGroupStyle: ControlGroupStyle {
  public init() {}

  public func makeBody(configuration: Self.Configuration) -> some View {
    Picker(
      selection: .constant(AnyHashable?.none),
      label: EmptyView()
    ) {
      if let parentView = configuration.content.body.view as? ParentView {
        ForEach(Array(parentView.children.enumerated()), id: \.offset) {
          $0.element
        }
      } else {
        configuration.content
      }
    }
    .pickerStyle(SegmentedPickerStyle())
  }
}

public struct NavigationControlGroupStyle: ControlGroupStyle {
  public init() {}

  public func makeBody(configuration: Self.Configuration) -> some View {
    HStack {
      configuration.content
    }
  }
}

public struct _AnyControlGroupStyle: ControlGroupStyle {
  public typealias Body = AnyView

  private let bodyClosure: (ControlGroupStyleConfiguration) -> AnyView
  public let type: Any.Type

  public init<S: ControlGroupStyle>(_ style: S) {
    type = S.self
    bodyClosure = { configuration in
      AnyView(style.makeBody(configuration: configuration))
    }
  }

  public func makeBody(configuration: ControlGroupStyleConfiguration) -> AnyView {
    bodyClosure(configuration)
  }
}

extension EnvironmentValues {
  private enum ControlGroupStyleKey: EnvironmentKey {
    static let defaultValue = _AnyControlGroupStyle(AutomaticControlGroupStyle())
  }

  var controlGroupStyle: _AnyControlGroupStyle {
    get {
      self[ControlGroupStyleKey.self]
    }
    set {
      self[ControlGroupStyleKey.self] = newValue
    }
  }
}

public extension View {
  func controlGroupStyle<S>(
    _ style: S
  ) -> some View where S: ControlGroupStyle {
    environment(\.controlGroupStyle, .init(style))
  }
}
