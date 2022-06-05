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

  /// Override the default implementation for `Scene`s with body types of `Never`
  /// or in cases where the body would normally need to be type erased.
  ///
  /// You can `visit(_:)` either another `Scene` or a `View` with a `SceneVisitor`
  func _visitChildren<V: SceneVisitor>(_ visitor: V)

  /// Create `SceneOutputs`, including any modifications to the environment, preferences, or a custom
  /// `LayoutComputer` from the `SceneInputs`.
  ///
  /// > At the moment, `SceneInputs`/`SceneOutputs` are identical to `ViewInputs`/`ViewOutputs`.
  static func _makeScene(_ inputs: SceneInputs<Self>) -> SceneOutputs
}

public typealias SceneInputs<S: Scene> = ViewInputs<S>
public typealias SceneOutputs = ViewOutputs

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
