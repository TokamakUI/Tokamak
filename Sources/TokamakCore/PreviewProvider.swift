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

import Foundation

/// This protocol has no functionality currently, and is only provided for compatibility purposes.
public protocol PreviewProvider {
  associatedtype Previews: View

  @ViewBuilder
  static var previews: Previews { get }
}

public struct PreviewDevice: RawRepresentable, ExpressibleByStringLiteral {
  public let rawValue: String
  public init(rawValue: String) {
    self.rawValue = rawValue
  }

  public init(stringLiteral: String) {
    rawValue = stringLiteral
  }
}

public protocol PreviewContextKey {
  associatedtype Value
  static var defaultValue: Self.Value { get }
}

public protocol PreviewContext {
  subscript<Key>(key: Key.Type) -> Key.Value where Key: PreviewContextKey { get }
}

public enum PreviewLayout {
  case device
  case sizeThatFits
  case fixed(width: CGFloat, height: CGFloat)
}

public extension View {
  func previewDevice(_ value: PreviewDevice?) -> some View {
    self
  }

  func previewLayout(_ value: PreviewLayout) -> some View {
    self
  }

  func previewDisplayName(_ value: String?) -> some View {
    self
  }

  func previewContext<C>(_ value: C) -> some View where C: PreviewContext {
    self
  }
}
