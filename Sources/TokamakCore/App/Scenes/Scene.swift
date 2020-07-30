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
//  Created by Carson Katri on 7/16/20.
//

public protocol Scene {
  associatedtype Body: Scene

  // FIXME: If I put `@SceneBuilder` in front of this
  // it fails to build with no useful error message.
  var body: Self.Body { get }
}

protocol TitledScene {
  var title: Text? { get }
}

protocol ParentScene {
  var children: [_AnyScene] { get }
}

protocol GroupScene: ParentScene {}

public protocol SceneDeferredToRenderer {
  var deferredBody: AnyView { get }
}

extension Never: Scene {}

/// Calls `fatalError` with an explanation that a given `type` is a primitive `Scene`
public func neverScene(_ type: String) -> Never {
  fatalError("\(type) is a primitive `Scene`, you're not supposed to access its `body`.")
}
