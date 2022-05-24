// Copyright 2022 Tokamak contributors
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
//  Created by Andrew Barba on 5/20/22.
//

import TokamakCore

public struct HTMLMeta: View {
  public enum MetaTag: Equatable, Hashable {
    case charset(_ charset: String)
    case name(_ name: String, content: String)
    case property(_ property: String, content: String)
    case httpEquiv(_ httpEquiv: String, content: String)
  }

  var meta: MetaTag

  public init(_ value: MetaTag) {
    meta = value
  }

  public init(charset: String) {
    meta = .charset(charset)
  }

  public init(name: String, content: String) {
    meta = .name(name, content: content)
  }

  public init(property: String, content: String) {
    meta = .property(property, content: content)
  }

  public init(httpEquiv: String, content: String) {
    meta = .httpEquiv(httpEquiv, content: content)
  }

  public var body: some View {
    EmptyView()
      .preference(key: HTMLMetaPreferenceKey.self, value: [meta])
  }
}

public extension View {
  func htmlMeta(_ value: HTMLMeta.MetaTag) -> some View {
    htmlMeta(.init(value))
  }

  func htmlMeta(charset: String) -> some View {
    htmlMeta(.init(charset: charset))
  }

  func htmlMeta(name: String, content: String) -> some View {
    htmlMeta(.init(name: name, content: content))
  }

  func htmlMeta(property: String, content: String) -> some View {
    htmlMeta(.init(property: property, content: content))
  }

  func htmlMeta(httpEquiv: String, content: String) -> some View {
    htmlMeta(.init(httpEquiv: httpEquiv, content: content))
  }

  func htmlMeta(_ meta: HTMLMeta) -> some View {
    Group {
      self
      meta
    }
  }
}
