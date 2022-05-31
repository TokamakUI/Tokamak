// Copyright 2018-2021 Tokamak contributors
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

import Foundation

public struct Rectangle: Shape {
  public func path(in rect: CGRect) -> Path {
    .init(storage: .rect(rect), sizing: .flexible)
  }

  public init() {}
}

extension Rectangle: InsettableShape {
  public func inset(by amount: CGFloat) -> _Inset {
    _Inset(amount: amount)
  }

  public struct _Inset: InsettableShape {
    public var amount: CGFloat

    init(amount: CGFloat) {
      self.amount = amount
    }

    public func path(in rect: CGRect) -> Path {
      .init(
        storage: .rect(CGRect(
          origin: rect.origin,
          size: CGSize(
            width: max(0, rect.size.width - (amount / 2)),
            height: max(0, rect.size.height - (amount / 2))
          )
        )),
        sizing: .flexible
      )
    }

    public func inset(by amount: CGFloat) -> Rectangle._Inset {
      var copy = self
      copy.amount += amount
      return copy
    }
  }
}

public struct RoundedRectangle: Shape {
  public var cornerSize: CGSize
  public var style: RoundedCornerStyle

  public init(cornerSize: CGSize, style: RoundedCornerStyle = .circular) {
    self.cornerSize = cornerSize
    self.style = style
  }

  public init(cornerRadius: CGFloat, style: RoundedCornerStyle = .circular) {
    let cornerSize = CGSize(width: cornerRadius, height: cornerRadius)
    self.init(cornerSize: cornerSize, style: style)
  }

  public func path(in rect: CGRect) -> Path {
    .init(
      storage: .roundedRect(.init(
        rect: rect,
        cornerSize: cornerSize,
        style: style
      )),
      sizing: .flexible
    )
  }
}

extension RoundedRectangle: InsettableShape {
  @inlinable
  public func inset(by amount: CGFloat) -> some InsettableShape {
    _Inset(base: self, amount: amount)
  }

  @usableFromInline
  struct _Inset: InsettableShape {
    @usableFromInline
    var base: RoundedRectangle

    @usableFromInline
    var amount: CGFloat

    @inlinable
    init(base: RoundedRectangle, amount: CGFloat) {
      self.base = base
      self.amount = amount
    }

    @usableFromInline
    func path(in rect: CGRect) -> Path {
      .init(
        storage: .roundedRect(.init(
          rect: CGRect(
            origin: rect.origin,
            size: CGSize(
              width: max(0, rect.size.width - (amount / 2)),
              height: max(0, rect.size.height - (amount / 2))
            )
          ),
          cornerSize: CGSize(
            width: max(0, base.cornerSize.width - (amount / 2)),
            height: max(0, base.cornerSize.height - (amount / 2))
          ),
          style: base.style
        )),
        sizing: .flexible
      )
    }

    @usableFromInline
    func inset(by amount: CGFloat) -> Self {
      var copy = self
      copy.amount += amount
      return copy
    }
  }
}
