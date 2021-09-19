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
//  Created by Carson Katri on 9/18/21.
//

import Foundation

public extension GraphicsContext {
  struct ResolvedImage {
    public let _image: Image

    public let size: CGSize
    public let baseline: CGFloat
    public var shading: Shading?

    public static func _resolved(
      _ image: Image,
      size: CGSize,
      baseline: CGFloat,
      shading: Shading? = nil
    ) -> Self {
      self.init(_image: image, size: size, baseline: baseline, shading: shading)
    }
  }

  func resolve(_ image: Image) -> ResolvedImage {
    _storage.imageResolver(image, _storage.environment)
  }

  func draw(_ image: ResolvedImage, in rect: CGRect, style: FillStyle = FillStyle()) {
    _storage.perform(.drawImage(image, .in(rect), style: style))
  }

  func draw(_ image: ResolvedImage, at point: CGPoint, anchor: UnitPoint = .center) {
    _storage.perform(.drawImage(image, .at(point, anchor: anchor), style: nil))
  }

  func draw(_ image: Image, in rect: CGRect, style: FillStyle = FillStyle()) {
    draw(resolve(image), in: rect, style: style)
  }

  func draw(_ image: Image, at point: CGPoint, anchor: UnitPoint = .center) {
    draw(resolve(image), at: point, anchor: anchor)
  }

  struct ResolvedText {
    public let _text: Text
    public var shading: Shading

    private let lazyLayoutComputer: (CGSize) -> _Layout

    public struct _Layout {
      let size: CGSize
      let firstBaseline: CGFloat
      let lastBaseline: CGFloat

      public init(size: CGSize, firstBaseline: CGFloat, lastBaseline: CGFloat) {
        self.size = size
        self.firstBaseline = firstBaseline
        self.lastBaseline = lastBaseline
      }
    }

    public static func _resolved(
      _ text: Text,
      shading: Shading,
      lazyLayoutComputer: @escaping (CGSize) -> _Layout
    ) -> Self {
      .init(_text: text, shading: shading, lazyLayoutComputer: lazyLayoutComputer)
    }

    public func measure(in size: CGSize) -> CGSize {
      lazyLayoutComputer(size).size
    }

    public func firstBaseline(in size: CGSize) -> CGFloat {
      lazyLayoutComputer(size).firstBaseline
    }

    public func lastBaseline(in size: CGSize) -> CGFloat {
      lazyLayoutComputer(size).lastBaseline
    }
  }

  func resolve(_ text: Text) -> ResolvedText {
    _storage.textResolver(text, _storage.environment)
  }

  func draw(_ text: ResolvedText, in rect: CGRect) {
    _storage.perform(.drawText(text, .in(rect)))
  }

  func draw(_ text: ResolvedText, at point: CGPoint, anchor: UnitPoint = .center) {
    _storage.perform(.drawText(text, .at(point, anchor: anchor)))
  }

  func draw(_ text: Text, in rect: CGRect) {
    draw(resolve(text), in: rect)
  }

  func draw(_ text: Text, at point: CGPoint, anchor: UnitPoint = .center) {
    draw(resolve(text), at: point, anchor: anchor)
  }

  struct ResolvedSymbol {
    public let _id: AnyHashable
    public let size: CGSize

    public static func _resolve(_ id: AnyHashable, size: CGSize) -> Self {
      .init(_id: id, size: size)
    }
  }

  func resolveSymbol<ID>(id: ID) -> ResolvedSymbol? where ID: Hashable {
    _storage.symbolResolver(AnyHashable(id))
  }

  func draw(_ symbol: ResolvedSymbol, in rect: CGRect) {
    _storage.perform(.drawSymbol(symbol, .in(rect)))
  }

  func draw(_ symbol: ResolvedSymbol, at point: CGPoint, anchor: UnitPoint = .center) {
    _storage.perform(.drawSymbol(symbol, .at(point, anchor: anchor)))
  }
}
