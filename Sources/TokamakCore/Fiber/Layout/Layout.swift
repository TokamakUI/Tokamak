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

/// A type that participates in the layout pass.
///
/// Any `View` or `Scene` that implements this protocol will be used to computed layout in
/// a `FiberRenderer` with `useDynamicLayout` enabled.
public protocol Layout: Animatable, _AnyLayout {
  static var layoutProperties: LayoutProperties { get }

  associatedtype Cache = ()

  /// Proxies for the children of this container.
  typealias Subviews = LayoutSubviews

  /// Create a fresh `Cache`. Use it to store complex operations,
  /// or to pass data between `sizeThatFits` and `placeSubviews`.
  ///
  /// - Note: There are no guarantees about when the cache will be recreated,
  /// and the behavior could change at any time.
  func makeCache(subviews: Self.Subviews) -> Self.Cache

  /// Update the existing `Cache` before each layout pass.
  func updateCache(_ cache: inout Self.Cache, subviews: Self.Subviews)

  /// The preferred spacing for this `View` and its subviews.
  func spacing(subviews: Self.Subviews, cache: inout Self.Cache) -> ViewSpacing

  /// Request a size to contain the subviews and fit within `proposal`.
  /// If you provide a size that does not fit within `proposal`, the parent will still respect it.
  func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Self.Subviews,
    cache: inout Self.Cache
  ) -> CGSize

  /// Place each subview with `LayoutSubview.place(at:anchor:proposal:)`.
  ///
  /// - Note: The bounds are not necessarily at `(0, 0)`, so use `bounds.minX` and `bounds.minY`
  /// to correctly position relative to the container.
  func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Self.Subviews,
    cache: inout Self.Cache
  )

  /// Override the value of a `HorizontalAlignment` value.
  func explicitAlignment(
    of guide: HorizontalAlignment,
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Self.Subviews,
    cache: inout Self.Cache
  ) -> CGFloat?

  /// Override the value of a `VerticalAlignment` value.
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

  func updateCache(_ cache: inout Self.Cache, subviews: Self.Subviews) {
    cache = makeCache(subviews: subviews)
  }

  func spacing(subviews: Self.Subviews, cache: inout Self.Cache) -> ViewSpacing {
    subviews.reduce(
      into: subviews.first.map {
        .init(
          viewType: $0.spacing.viewType,
          top: { _ in 0 },
          leading: { _ in 0 },
          bottom: { _ in 0 },
          trailing: { _ in 0 }
        )
      } ?? .zero
    ) { $0.formUnion($1.spacing) }
  }

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
}

public extension Layout {
  /// Render `content` using `self` as the layout container.
  func callAsFunction<V>(@ViewBuilder _ content: () -> V) -> some View where V: View {
    LayoutView(layout: self, content: content())
  }
}

/// A `View` that renders its children with a `Layout`.
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

/// A default `Layout` that fits to the first subview and places its children at its origin.
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
