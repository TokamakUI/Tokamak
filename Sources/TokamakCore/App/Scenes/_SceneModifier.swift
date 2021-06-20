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
//  Created by Carson Katri on 7/20/20.
//

public protocol _SceneModifier {
  associatedtype Body: Scene
  typealias SceneContent = _SceneModifier_Content<Self>
  func body(content: SceneContent) -> Self.Body
}

public struct _SceneModifier_Content<Modifier>: Scene where Modifier: _SceneModifier {
  public let modifier: Modifier
  public let scene: _AnyScene

  @_spi(TokamakCore)
  public var body: Never {
    neverScene("_SceneModifier_Content")
  }
}

public extension Scene {
  func modifier<Modifier>(_ modifier: Modifier) -> ModifiedContent<Self, Modifier> {
    .init(content: self, modifier: modifier)
  }
}

public extension _SceneModifier where Body == Never {
  func body(content: SceneContent) -> Body {
    fatalError("""
    \(self) is a primitive `_SceneModifier`, you're not supposed to run `body(content:)`
    """)
  }
}
