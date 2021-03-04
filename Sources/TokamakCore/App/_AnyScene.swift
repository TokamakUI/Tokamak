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
//
//  Created by Carson Katri on 7/19/20.
//

public struct _AnyScene: Scene {
  /** The result type of `bodyClosure` allowing to disambiguate between scenes that
   produce other scenes or scenes that only produce containing views.
   */
  enum BodyResult {
    case scene(_AnyScene)
    case view(AnyView)
  }

  /** The name of the unapplied generic type of the underlying `view`. `Button<Text>` and
   `Button<Image>` types are different, but when reconciling the tree of mounted views
   they are treated the same, thus the `Button` part of the type (the type constructor)
   is stored in this property.
   */
  let typeConstructorName: String

  /// The actual `Scene` value wrapped within this `_AnyScene`.
  var scene: Any

  /// The type of the underlying `scene`
  let type: Any.Type

  /** Type-erased `body` of the underlying `scene`. Needs to take a fresh version of `scene` as an
   argument, otherwise it captures an old value of the `body` property.
   */
  let bodyClosure: (Any) -> BodyResult

  /** The type of the `body` of the underlying `scene`. Used to cast the result of the applied
   `bodyClosure` property.
   */
  let bodyType: Any.Type

  init<S: Scene>(_ scene: S) {
    if let anyScene = scene as? _AnyScene {
      self = anyScene
    } else {
      self.scene = scene
      type = S.self
      bodyType = S.Body.self
      if scene is SceneDeferredToRenderer {
        // swiftlint:disable:next force_cast
        bodyClosure = { .view(($0 as! SceneDeferredToRenderer).deferredBody) }
      } else {
        // swiftlint:disable:next force_cast
        bodyClosure = { .scene(_AnyScene(($0 as! S).body)) }
      }

      typeConstructorName = TokamakCore.typeConstructorName(type)
    }
  }

  @_spi(TokamakCore)
  public var body: Never {
    neverScene("_AnyScene")
  }
}
