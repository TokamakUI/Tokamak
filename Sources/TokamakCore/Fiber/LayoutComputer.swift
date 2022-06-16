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
//  Created by Carson Katri on 2/16/22.
//

import Foundation

public protocol _AnyLayout {
  func _makeActions() -> LayoutActions
}

public protocol Layout: Animatable, _AnyLayout {
  static var layoutProperties: LayoutProperties { get }

  associatedtype Cache = ()

  typealias Subviews = LayoutSubviews

  func makeCache(subviews: Self.Subviews) -> Self.Cache

  func updateCache(_ cache: inout Self.Cache, subviews: Self.Subviews)

  func spacing(subviews: Self.Subviews, cache: inout Self.Cache) -> ViewSpacing

  func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Self.Subviews,
    cache: inout Self.Cache
  ) -> CGSize

  func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Self.Subviews,
    cache: inout Self.Cache
  )

  func explicitAlignment(
    of guide: HorizontalAlignment,
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Self.Subviews,
    cache: inout Self.Cache
  ) -> CGFloat?

  func explicitAlignment(
    of guide: VerticalAlignment,
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Self.Subviews,
    cache: inout Self.Cache
  ) -> CGFloat?
}

public extension Layout {
  func _makeActions() -> LayoutActions {
    .init(self)
  }
}

public extension Layout where Self.Cache == () {
  func makeCache(subviews: Self.Subviews) -> Self.Cache {
    ()
  }
}

public extension Layout {
  static var layoutProperties: LayoutProperties {
    .init()
  }

  func updateCache(_ cache: inout Self.Cache, subviews: Self.Subviews) {}
  func explicitAlignment(
    of guide: HorizontalAlignment,
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Self.Subviews,
    cache: inout Self.Cache
  ) -> CGFloat? {
    nil
  }

  func explicitAlignment(
    of guide: VerticalAlignment,
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Self.Subviews,
    cache: inout Self.Cache
  ) -> CGFloat? {
    nil
  }

  func spacing(subviews: Self.Subviews, cache: inout Self.Cache) -> ViewSpacing {
    .init()
  }
}

public struct LayoutProperties {
  public var stackOrientation: Axis?

  public init() {
    stackOrientation = nil
  }
}

@frozen
public struct ProposedViewSize: Equatable {
  public var width: CGFloat?
  public var height: CGFloat?
  public static let zero: ProposedViewSize = .init(width: 0, height: 0)
  public static let unspecified: ProposedViewSize = .init(width: nil, height: nil)
  public static let infinity: ProposedViewSize = .init(width: .infinity, height: .infinity)
  @inlinable
  public init(width: CGFloat?, height: CGFloat?) {
    (self.width, self.height) = (width, height)
  }

  @inlinable
  public init(_ size: CGSize) {
    self.init(width: size.width, height: size.height)
  }

  @inlinable
  public func replacingUnspecifiedDimensions(by size: CGSize = CGSize(
    width: 10,
    height: 10
  )) -> CGSize {
    CGSize(width: width ?? size.width, height: height ?? size.height)
  }
}

public struct ViewSpacing {
  private var top: CGFloat
  private var leading: CGFloat
  private var bottom: CGFloat
  private var trailing: CGFloat

  public static let zero: ViewSpacing = .init()

  public init() {
    top = 0
    leading = 0
    bottom = 0
    trailing = 0
  }

  public mutating func formUnion(_ other: ViewSpacing, edges: Edge.Set = .all) {
    if edges.contains(.top) {
      top = max(top, other.top)
    }
    if edges.contains(.leading) {
      leading = max(leading, other.leading)
    }
    if edges.contains(.bottom) {
      bottom = max(bottom, other.bottom)
    }
    if edges.contains(.trailing) {
      trailing = max(trailing, other.trailing)
    }
  }

  public func union(_ other: ViewSpacing, edges: Edge.Set = .all) -> ViewSpacing {
    var spacing = self
    spacing.formUnion(other, edges: edges)
    return spacing
  }

  /// The smallest spacing that accommodates the preferences of `self` and `next`.
  public func distance(to next: ViewSpacing, along axis: Axis) -> CGFloat {
    // Assume `next` comes after `self` either horizontally or vertically.
    switch axis {
    case .horizontal:
      return max(trailing, next.leading)
    case .vertical:
      return max(bottom, next.top)
    }
  }
}

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
  private let dimensions: (ProposedViewSize) -> ViewDimensions
  private let place: (CGPoint, UnitPoint, ProposedViewSize) -> ()

  init(
    id: ObjectIdentifier,
    sizeThatFits: @escaping (ProposedViewSize) -> CGSize,
    dimensions: @escaping (ProposedViewSize) -> ViewDimensions,
    place: @escaping (CGPoint, UnitPoint, ProposedViewSize) -> ()
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
    fatalError("Implement \(#function)")
  }

  public func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
    sizeThatFits(proposal)
  }

  public func dimensions(in proposal: ProposedViewSize) -> ViewDimensions {
    dimensions(proposal)
  }

  public var spacing: ViewSpacing {
    ViewSpacing()
  }

  public func place(
    at position: CGPoint,
    anchor: UnitPoint = .topLeading,
    proposal: ProposedViewSize
  ) {
    place(position, anchor, proposal)
  }
}

public enum LayoutDirection: Hashable, CaseIterable {
  case leftToRight
  case rightToLeft
}

extension EnvironmentValues {
  private enum LayoutDirectionKey: EnvironmentKey {
    static var defaultValue: LayoutDirection = .leftToRight
  }

  public var layoutDirection: LayoutDirection {
    get { self[LayoutDirectionKey.self] }
    set { self[LayoutDirectionKey.self] = newValue }
  }
}

public protocol LayoutValueKey {
  associatedtype Value
  static var defaultValue: Self.Value { get }
}

public extension View {
  @inlinable
  func layoutValue<K>(key: K.Type, value: K.Value) -> some View where K: LayoutValueKey {
    _trait(_LayoutTrait<K>.self, value)
  }
}

public struct _LayoutTrait<K>: _ViewTraitKey where K: LayoutValueKey {
  public static var defaultValue: K.Value {
    K.defaultValue
  }
}

public extension Layout {
  func callAsFunction<V>(@ViewBuilder _ content: () -> V) -> some View where V: View {
    LayoutView(layout: self, content: content())
  }
}

@_spi(TokamakCore)
public struct LayoutView<L: Layout, Content: View>: View, Layout {
  let layout: L
  let content: Content

  public typealias Cache = L.Cache

  public func makeCache(subviews: Subviews) -> L.Cache {
    layout.makeCache(subviews: subviews)
  }

  public func updateCache(_ cache: inout L.Cache, subviews: Subviews) {
    layout.updateCache(&cache, subviews: subviews)
  }

  public func spacing(subviews: Subviews, cache: inout L.Cache) -> ViewSpacing {
    layout.spacing(subviews: subviews, cache: &cache)
  }

  public func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout Cache
  ) -> CGSize {
    layout.sizeThatFits(proposal: proposal, subviews: subviews, cache: &cache)
  }

  public func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout Cache
  ) {
    layout.placeSubviews(in: bounds, proposal: proposal, subviews: subviews, cache: &cache)
  }

  public func explicitAlignment(
    of guide: HorizontalAlignment,
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout L.Cache
  ) -> CGFloat? {
    layout.explicitAlignment(
      of: guide, in: bounds, proposal: proposal, subviews: subviews, cache: &cache
    )
  }

  public func explicitAlignment(
    of guide: VerticalAlignment,
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout L.Cache
  ) -> CGFloat? {
    layout.explicitAlignment(
      of: guide, in: bounds, proposal: proposal, subviews: subviews, cache: &cache
    )
  }

  public var body: some View {
    content
  }
}

struct DefaultLayout: Layout {
  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    let size = subviews.first?.sizeThatFits(proposal) ?? .zero
    return size
  }

  func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) {
    for subview in subviews {
      subview.place(at: bounds.origin, proposal: proposal)
    }
  }
}

// TODO: AnyLayout
// class AnyLayoutBox {
//
// }
//
// final class ConcreteLayoutBox<L: Layout>: AnyLayoutBox {
//
// }

// @frozen public struct AnyLayout: Layout {
//  internal var storage: AnyLayoutBox
//
//    public init<L>(_ layout: L) where L: Layout {
//        storage = ConcreteLayoutBox(layout)
//    }
//
//  public struct Cache {
//  }
//
//  public typealias AnimatableData = _AnyAnimatableData
//  public func makeCache(subviews: AnyLayout.Subviews) -> AnyLayout.Cache
//  public func updateCache(_ cache: inout AnyLayout.Cache, subviews: AnyLayout.Subviews)
//  public func spacing(subviews: AnyLayout.Subviews, cache: inout AnyLayout.Cache) -> ViewSpacing
//  public func sizeThatFits(proposal: ProposedViewSize, subviews: AnyLayout.Subviews, cache: inout AnyLayout.Cache) -> CGSize
//  public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: AnyLayout.Subviews, cache: inout AnyLayout.Cache)
//  public func explicitAlignment(of guide: HorizontalAlignment, in bounds: CGRect, proposal: ProposedViewSize, subviews: AnyLayout.Subviews, cache: inout AnyLayout.Cache) -> CGFloat?
//  public func explicitAlignment(of guide: VerticalAlignment, in bounds: CGRect, proposal: ProposedViewSize, subviews: AnyLayout.Subviews, cache: inout AnyLayout.Cache) -> CGFloat?
//  public var animatableData: AnyLayout.AnimatableData {
//    get
//    set
//  }
// }
