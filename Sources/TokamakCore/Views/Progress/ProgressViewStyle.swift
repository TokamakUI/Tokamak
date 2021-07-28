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
//  Created by Carson Katri on 7/9/21.
//

import Foundation

public protocol ProgressViewStyle {
  associatedtype Body: View
  typealias Configuration = ProgressViewStyleConfiguration

  @ViewBuilder
  func makeBody(configuration: Self.Configuration) -> Self.Body
}

public struct ProgressViewStyleConfiguration {
  public struct Label: View {
    public let body: AnyView
  }

  public struct CurrentValueLabel: View {
    public let body: AnyView
  }

  public let fractionCompleted: Double?
  public var label: ProgressViewStyleConfiguration.Label?
  public var currentValueLabel: ProgressViewStyleConfiguration.CurrentValueLabel?
}

public struct DefaultProgressViewStyle: ProgressViewStyle {
  public init() {}
  public func makeBody(configuration: Configuration) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack { Spacer() }
      configuration.label
        .foregroundStyle(HierarchicalShapeStyle.primary)
      if let fractionCompleted = configuration.fractionCompleted {
        _FractionalProgressView(fractionCompleted)
      } else {
        _IndeterminateProgressView()
      }
      configuration.currentValueLabel
        .font(.caption)
        .foregroundStyle(HierarchicalShapeStyle.primary)
        .opacity(0.5)
    }
  }
}

public struct _AnyProgressViewStyle: ProgressViewStyle {
  public typealias Body = AnyView

  private let bodyClosure: (ProgressViewStyleConfiguration) -> AnyView
  public let type: Any.Type

  public init<S: ProgressViewStyle>(_ style: S) {
    type = S.self
    bodyClosure = { configuration in
      AnyView(style.makeBody(configuration: configuration))
    }
  }

  public func makeBody(configuration: ProgressViewStyleConfiguration) -> AnyView {
    bodyClosure(configuration)
  }
}

extension EnvironmentValues {
  private enum ProgressViewStyleKey: EnvironmentKey {
    static let defaultValue = _AnyProgressViewStyle(DefaultProgressViewStyle())
  }

  var progressViewStyle: _AnyProgressViewStyle {
    get {
      self[ProgressViewStyleKey.self]
    }
    set {
      self[ProgressViewStyleKey.self] = newValue
    }
  }
}

public extension View {
  func progressViewStyle<S>(_ style: S) -> some View where S: ProgressViewStyle {
    environment(\.progressViewStyle, .init(style))
  }
}
