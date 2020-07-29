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
//  Created by Carson Katri on 7/19/20.
//

public struct _AnyScene: Scene {
  enum BodyResult {
    case scene(_AnyScene)
    case view(AnyView)
  }

  var scene: Any

  /// The type of the underlying `scene`
  let type: Any.Type
  let bodyClosure: (Any) -> BodyResult
  let bodyType: Any.Type

  init<S: Scene>(_ scene: S) {
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
  }

  public var body: Never {
    neverScene("_AnyScene")
  }
}
