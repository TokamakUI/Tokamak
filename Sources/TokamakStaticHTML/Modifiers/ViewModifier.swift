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

@_spi(TokamakCore)
import TokamakCore

public protocol DOMViewModifier {
  var attributes: [HTMLAttribute: String] { get }
  /// Can the modifier be flattened?
  var isOrderDependent: Bool { get }
}

public extension DOMViewModifier {
  var isOrderDependent: Bool { false }
}

extension ModifiedContent: DOMViewModifier
  where Content: DOMViewModifier, Modifier: DOMViewModifier
{
  // Merge attributes
  public var attributes: [HTMLAttribute: String] {
    var attr = content.attributes
    for (key, val) in modifier.attributes {
      if let prev = attr[key] {
        attr[key] = prev + val
      }
    }
    return attr
  }
}

extension _ZIndexModifier: DOMViewModifier {
  public var attributes: [HTMLAttribute: String] {
    ["style": "z-index: \(index);"]
  }
}

@_spi(TokamakStaticHTML)
public protocol HTMLModifierConvertible {
  func primitiveVisitor<V, Content: View>(
    content: Content,
    useDynamicLayout: Bool
  ) -> ((V) -> ())? where V: ViewVisitor
}

@_spi(TokamakStaticHTML)
extension ModifiedContent: HTMLConvertible where Content: View,
  Modifier: HTMLConvertible
{
  public var tag: String { modifier.tag }
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    modifier.attributes(useDynamicLayout: useDynamicLayout)
  }

  public var innerHTML: String? { modifier.innerHTML }

  public func primitiveVisitor<V>(useDynamicLayout: Bool) -> ((V) -> ())? where V: ViewVisitor {
    (modifier as? HTMLModifierConvertible)?
      .primitiveVisitor(
        content: content,
        useDynamicLayout: useDynamicLayout
      )
  }
}
