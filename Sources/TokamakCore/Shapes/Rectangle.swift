// Copyright 2018-2020 Tokamak contributors
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

public struct Rectangle: Shape {
  public func path(in rect: CGRect) -> Path {
    .init(rect)
  }

  public init() {}
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
    .init(roundedRect: rect, cornerSize: cornerSize, style: style)
  }
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
      .init(CGRect(rect.origin,
                   CGSize(width: rect.size.width - (amount / 2),
                          height: rect.size.height - (amount / 2))))
    }

    public func inset(by amount: CGFloat) -> Rectangle._Inset {
      var copy = self
      copy.amount += amount
      return copy
    }
  }
}
