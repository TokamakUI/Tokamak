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
//  Created by Jed Fox on 07/04/2020.
//
// swiftlint:disable line_length
//  Adapted from https://github.com/SwiftWebUI/SwiftWebUI/blob/16b84d46/Sources/SwiftWebUI/Views/Forms/Toggle.swift
// swiftlint:enable line_length
//

// NOTE: ToggleStyleConfiguration.label is supposed to be a special Never View.
// It seems like during the rendering process it’s dynamically replaced with the actual label.
// That’s complicated so instead we’re providing the label view directly.

public struct ToggleStyleConfiguration {
  public let label: AnyView
  @Binding
  public var isOn: Swift.Bool
}

public protocol ToggleStyle {
  associatedtype Body: View

  func makeBody(configuration: Self.Configuration) -> Self.Body

  typealias Configuration = ToggleStyleConfiguration
}

public struct _AnyToggleStyle: ToggleStyle {
  public typealias Body = AnyView

  private let bodyClosure: (ToggleStyleConfiguration) -> AnyView

  public init<S: ToggleStyle>(_ style: S) {
    bodyClosure = { configuration in
      AnyView(style.makeBody(configuration: configuration))
    }
  }

  public func makeBody(configuration: ToggleStyleConfiguration) -> AnyView {
    bodyClosure(configuration)
  }
}

public enum _ToggleStyleKey: EnvironmentKey {
  public static var defaultValue: _AnyToggleStyle {
    fatalError("\(self) must have a renderer-provided default value")
  }
}

extension EnvironmentValues {
  var toggleStyle: _AnyToggleStyle {
    get {
      self[_ToggleStyleKey.self]
    }
    set {
      self[_ToggleStyleKey.self] = newValue
    }
  }
}

public extension View {
  func toggleStyle<S>(_ style: S) -> some View where S: ToggleStyle {
    environment(\.toggleStyle, _AnyToggleStyle(style))
  }
}
