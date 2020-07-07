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

import TokamakCore

public typealias ViewModifier = TokamakCore.ViewModifier
public typealias ModifiedContent = TokamakCore.ModifiedContent

public protocol DOMViewModifier {
  var attributes: [String: String] { get }
  /// Can the modifier be flattened?
  var isOrderDependent: Bool { get }
}

extension DOMViewModifier {
  public var isOrderDependent: Bool { false }
}

extension ModifiedContent: DOMViewModifier
  where Content: DOMViewModifier, Modifier: DOMViewModifier {
  // Merge attributes
  public var attributes: [String: String] {
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
  public var attributes: [String: String] {
    ["style": "z-index: \(index);"]
  }
}

extension _BackgroundModifier: DOMViewModifier where Background == Color {
  public var isOrderDependent: Bool { true }
  public var attributes: [String: String] {
    ["style": "background-color: \(background.description)"]
  }
}
