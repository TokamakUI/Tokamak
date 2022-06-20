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
//  Created by Carson Katri on 6/20/22.
//

import Foundation

public struct LayoutSubviews: Equatable, RandomAccessCollection {
  public var layoutDirection: LayoutDirection
  var storage: [LayoutSubview]

  init(layoutDirection: LayoutDirection, storage: [LayoutSubview]) {
    self.layoutDirection = layoutDirection
    self.storage = storage
  }

  init<R: FiberRenderer>(_ node: FiberReconciler<R>.Fiber) {
    self.init(
      layoutDirection: node.outputs.environment.environment.layoutDirection,
      storage: []
    )
  }

  public typealias SubSequence = LayoutSubviews
  public typealias Element = LayoutSubview
  public typealias Index = Int
  public typealias Indices = Range<LayoutSubviews.Index>
  public typealias Iterator = IndexingIterator<LayoutSubviews>

  public var startIndex: Int {
    storage.startIndex
  }

  public var endIndex: Int {
    storage.endIndex
  }

  public subscript(index: Int) -> LayoutSubviews.Element {
    storage[index]
  }

  public subscript(bounds: Range<Int>) -> LayoutSubviews {
    .init(layoutDirection: layoutDirection, storage: .init(storage[bounds]))
  }

  public subscript<S>(indices: S) -> LayoutSubviews where S: Sequence, S.Element == Int {
    .init(
      layoutDirection: layoutDirection,
      storage: storage.enumerated()
        .filter { indices.contains($0.offset) }
        .map(\.element)
    )
  }
}

public struct LayoutSubview: Equatable {
  private let id: ObjectIdentifier
  public static func == (lhs: LayoutSubview, rhs: LayoutSubview) -> Bool {
    lhs.id == rhs.id
  }

  private let sizeThatFits: (ProposedViewSize) -> CGSize
  private let dimensions: (CGSize) -> ViewDimensions
  private let place: (ViewDimensions, CGPoint, UnitPoint) -> ()

  init(
    id: ObjectIdentifier,
    sizeThatFits: @escaping (ProposedViewSize) -> CGSize,
    dimensions: @escaping (CGSize) -> ViewDimensions,
    place: @escaping (ViewDimensions, CGPoint, UnitPoint) -> ()
  ) {
    self.id = id
    self.sizeThatFits = sizeThatFits
    self.dimensions = dimensions
    self.place = place
  }

  public func _trait<K>(key: K.Type) -> K.Value where K: _ViewTraitKey {
    fatalError("Implement \(#function)")
  }

  public subscript<K>(key: K.Type) -> K.Value where K: LayoutValueKey {
    fatalError("Implement \(#function)")
  }

  public var priority: Double {
    0
  }

  public func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
    sizeThatFits(proposal)
  }

  public func dimensions(in proposal: ProposedViewSize) -> ViewDimensions {
    dimensions(sizeThatFits(proposal))
  }

  public var spacing: ViewSpacing {
    ViewSpacing()
  }

  public func place(
    at position: CGPoint,
    anchor: UnitPoint = .topLeading,
    proposal: ProposedViewSize
  ) {
    place(dimensions(in: proposal), position, anchor)
  }
}
