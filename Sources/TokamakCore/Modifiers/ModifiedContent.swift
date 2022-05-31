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

protocol ModifierContainer {
  var environmentModifier: _EnvironmentModifier? { get }
}

protocol ModifiedContentProtocol {}

/// A value with a modifier applied to it.
public struct ModifiedContent<Content, Modifier>: ModifiedContentProtocol {
  @Environment(\.self)
  public var environment

  public typealias Body = Never
  public private(set) var content: Content
  public private(set) var modifier: Modifier

  public init(content: Content, modifier: Modifier) {
    self.content = content
    self.modifier = modifier
  }
}

extension ModifiedContent: ModifierContainer {
  var environmentModifier: _EnvironmentModifier? { modifier as? _EnvironmentModifier }
}

extension ModifiedContent: EnvironmentReader where Modifier: EnvironmentReader {
  mutating func setContent(from values: EnvironmentValues) {
    modifier.setContent(from: values)
  }
}

extension ModifiedContent: View, GroupView, ParentView where Content: View, Modifier: ViewModifier {
  public var body: Body {
    neverBody("ModifiedContent<View, ViewModifier>")
  }

  public var children: [AnyView] {
    [AnyView(content)]
  }
}

extension ModifiedContent: ViewModifier where Content: ViewModifier, Modifier: ViewModifier {
  public func body(content: _ViewModifier_Content<Self>) -> Never {
    neverBody("ModifiedContent<ViewModifier, ViewModifier>")
  }
}

public extension ViewModifier {
  func concat<T>(_ modifier: T) -> ModifiedContent<Self, T> where T: ViewModifier {
    .init(content: self, modifier: modifier)
  }
}
