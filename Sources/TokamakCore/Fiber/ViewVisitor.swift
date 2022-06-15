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
//  Created by Carson Katri on 2/3/22.
//

/// A type that can visit a `View`.
public protocol ViewVisitor {
  func visit<V: View>(_ view: V)
}

public extension View {
  func _visitChildren<V: ViewVisitor>(_ visitor: V) {
    visitor.visit(body)
  }
}

public typealias ViewVisitorF<V: ViewVisitor> = (V) -> ()

/// A type that creates a `Result` by visiting multiple `View`s.
protocol ViewReducer {
  associatedtype Result
  static func reduce<V: View>(into partialResult: inout Result, nextView: V)
  static func reduce<V: View>(partialResult: Result, nextView: V) -> Result
}

extension ViewReducer {
  static func reduce<V: View>(into partialResult: inout Result, nextView: V) {
    partialResult = Self.reduce(partialResult: partialResult, nextView: nextView)
  }

  static func reduce<V: View>(partialResult: Result, nextView: V) -> Result {
    var result = partialResult
    Self.reduce(into: &result, nextView: nextView)
    return result
  }
}

/// A `ViewVisitor` that uses a `ViewReducer`
/// to collapse the `View` values into a single `Result`.
final class ReducerVisitor<R: ViewReducer>: ViewVisitor {
  var result: R.Result

  init(initialResult: R.Result) {
    result = initialResult
  }

  func visit<V>(_ view: V) where V: View {
    R.reduce(into: &result, nextView: view)
  }
}

extension ViewReducer {
  typealias Visitor = ReducerVisitor<Self>
}
