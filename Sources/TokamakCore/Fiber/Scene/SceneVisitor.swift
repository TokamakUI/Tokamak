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
//  Created by Carson Katri on 5/30/22.
//

/// A type that can visit a `Scene`.
public protocol SceneVisitor: ViewVisitor {
  func visit<S: Scene>(_ scene: S)
}

public extension Scene {
  func _visitChildren<V: SceneVisitor>(_ visitor: V) {
    visitor.visit(body)
  }
}

/// A type that creates a `Result` by visiting multiple `Scene`s.
protocol SceneReducer: ViewReducer {
  associatedtype Result
  static func reduce<S: Scene>(into partialResult: inout Result, nextScene: S)
  static func reduce<S: Scene>(partialResult: Result, nextScene: S) -> Result
}

extension SceneReducer {
  static func reduce<S: Scene>(into partialResult: inout Result, nextScene: S) {
    partialResult = Self.reduce(partialResult: partialResult, nextScene: nextScene)
  }

  static func reduce<S: Scene>(partialResult: Result, nextScene: S) -> Result {
    var result = partialResult
    Self.reduce(into: &result, nextScene: nextScene)
    return result
  }
}

/// A `SceneVisitor` that uses a `SceneReducer`
/// to collapse the `Scene` values into a single `Result`.
final class SceneReducerVisitor<R: SceneReducer>: SceneVisitor {
  var result: R.Result

  init(initialResult: R.Result) {
    result = initialResult
  }

  func visit<S>(_ scene: S) where S: Scene {
    R.reduce(into: &result, nextScene: scene)
  }

  func visit<V>(_ view: V) where V: View {
    R.reduce(into: &result, nextView: view)
  }
}

extension SceneReducer {
  typealias SceneVisitor = SceneReducerVisitor<Self>
}
