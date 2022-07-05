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

/// A collection of `LayoutSubview` proxies.
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

/// A proxy representing a child of a `Layout`.
///
/// Access size requests, alignment guide values, spacing preferences, and any layout values using
/// this proxy.
///
/// `Layout` types are expected to call `place(at:anchor:proposal:)` on all subviews.
/// If `place(at:anchor:proposal:)` is not called, the center will be used as its position.
public struct LayoutSubview: Equatable {
  private let id: ObjectIdentifier
  private let storage: AnyStorage

  /// A protocol used to erase `Storage<R>`.
  private class AnyStorage {
    let traits: _ViewTraitStore?

    init(traits: _ViewTraitStore?) {
      self.traits = traits
    }

    func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
      fatalError("Implement \(#function) in subclass")
    }

    func dimensions(_ sizeThatFits: CGSize) -> ViewDimensions {
      fatalError("Implement \(#function) in subclass")
    }

    func place(
      _ proposal: ProposedViewSize,
      _ dimensions: ViewDimensions,
      _ position: CGPoint,
      _ anchor: UnitPoint
    ) {
      fatalError("Implement \(#function) in subclass")
    }

    func spacing() -> ViewSpacing {
      fatalError("Implement \(#function) in subclass")
    }
  }

  /// The backing storage for a `LayoutSubview`. This contains the underlying implementations for
  /// methods accessing the `fiber`, `element`, and `cache` this subview represents.
  private final class Storage<R: FiberRenderer>: AnyStorage {
    weak var fiber: FiberReconciler<R>.Fiber?
    weak var element: R.ElementType?
    unowned var caches: FiberReconciler<R>.Caches

    init(
      traits: _ViewTraitStore?,
      fiber: FiberReconciler<R>.Fiber?,
      element: R.ElementType?,
      caches: FiberReconciler<R>.Caches
    ) {
      self.fiber = fiber
      self.element = element
      self.caches = caches
      super.init(traits: traits)
    }

    override func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
      guard let fiber = fiber else { return .zero }
      let request = FiberReconciler<R>.Caches.LayoutCache.SizeThatFitsRequest(proposal)
      return caches.updateLayoutCache(for: fiber) { cache in
        guard let layout = fiber.layout else { return .zero }
        if let size = cache.sizeThatFits[request] {
          return size
        } else {
          let size = layout.sizeThatFits(
            proposal: proposal,
            subviews: caches.layoutSubviews(for: fiber),
            cache: &cache.cache
          )
          cache.sizeThatFits[request] = size
          if let alternate = fiber.alternate {
            caches.updateLayoutCache(for: alternate) { alternateCache in
              alternateCache.cache = cache.cache
              alternateCache.sizeThatFits[request] = size
            }
          }
          return size
        }
      } ?? .zero
    }

    override func dimensions(_ sizeThatFits: CGSize) -> ViewDimensions {
      // TODO: Add `alignmentGuide` modifier and pass into `ViewDimensions`
      ViewDimensions(size: sizeThatFits, alignmentGuides: [:])
    }

    override func place(
      _ proposal: ProposedViewSize,
      _ dimensions: ViewDimensions,
      _ position: CGPoint,
      _ anchor: UnitPoint
    ) {
      guard let fiber = fiber, let element = element else { return }
      let geometry = ViewGeometry(
        // Shift to the anchor point in the parent's coordinate space.
        origin: .init(origin: .init(
          x: position.x - (dimensions.width * anchor.x),
          y: position.y - (dimensions.height * anchor.y)
        )),
        dimensions: dimensions,
        proposal: proposal
      )
      // Push a layout mutation if needed.
      if geometry != fiber.alternate?.geometry {
        caches.mutations.append(.layout(element: element, geometry: geometry))
      }
      // Update ours and our alternate's geometry
      fiber.geometry = geometry
      fiber.alternate?.geometry = geometry
    }

    override func spacing() -> ViewSpacing {
      guard let fiber = fiber else { return .init() }

      return caches.updateLayoutCache(for: fiber) { cache in
        fiber.layout?.spacing(
          subviews: caches.layoutSubviews(for: fiber),
          cache: &cache.cache
        ) ?? .zero
      } ?? .zero
    }
  }

  init<R: FiberRenderer>(
    id: ObjectIdentifier,
    traits: _ViewTraitStore?,
    fiber: FiberReconciler<R>.Fiber,
    element: R.ElementType,
    caches: FiberReconciler<R>.Caches
  ) {
    self.id = id
    storage = Storage(
      traits: traits,
      fiber: fiber,
      element: element,
      caches: caches
    )
  }

  public func _trait<K>(key: K.Type) -> K.Value where K: _ViewTraitKey {
    storage.traits?.value(forKey: key) ?? K.defaultValue
  }

  public subscript<K>(key: K.Type) -> K.Value where K: LayoutValueKey {
    _trait(key: _LayoutTrait<K>.self)
  }

  public var priority: Double {
    _trait(key: LayoutPriorityTraitKey.self)
  }

  public func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
    storage.sizeThatFits(proposal)
  }

  public func dimensions(in proposal: ProposedViewSize) -> ViewDimensions {
    storage.dimensions(sizeThatFits(proposal))
  }

  public var spacing: ViewSpacing {
    storage.spacing()
  }

  public func place(
    at position: CGPoint,
    anchor: UnitPoint = .topLeading,
    proposal: ProposedViewSize
  ) {
    storage.place(
      proposal,
      dimensions(in: proposal),
      position,
      anchor
    )
  }

  public static func == (lhs: LayoutSubview, rhs: LayoutSubview) -> Bool {
    lhs.storage === rhs.storage
  }
}
