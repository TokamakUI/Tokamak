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

public enum Edge: Int8, CaseIterable {
  case top, leading, bottom, trailing

  public struct Set: OptionSet {
    public let rawValue: Int8

    public init(rawValue: Int8) {
      self.rawValue = rawValue
    }

    public static let top: Edge.Set = .init(rawValue: 1 << 0)
    public static let leading: Edge.Set = .init(rawValue: 1 << 1)
    public static let bottom: Edge.Set = .init(rawValue: 1 << 2)
    public static let trailing: Edge.Set = .init(rawValue: 1 << 3)

    public static let all: Edge.Set = [.top, .leading, .bottom, .trailing]
    public static let horizontal: Edge.Set = [.leading, .trailing]
    public static let vertical: Edge.Set = [.top, .bottom]

    public init(_ e: Edge) {
      switch e {
      case .top: self = .top
      case .leading: self = .leading
      case .bottom: self = .bottom
      case .trailing: self = .trailing
      }
    }
  }
}

public struct EdgeInsets: Equatable {
  public var top: CGFloat
  public var leading: CGFloat
  public var bottom: CGFloat
  public var trailing: CGFloat

  public init(top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat) {
    self.top = top
    self.leading = leading
    self.bottom = bottom
    self.trailing = trailing
  }

  public init() {
    self.init(top: 0, leading: 0, bottom: 0, trailing: 0)
  }

  public init(_all: CGFloat) {
    self.init(top: _all, leading: _all, bottom: _all, trailing: _all)
  }
}

extension EdgeInsets: Animatable, _VectorMath {
  public typealias AnimatableData = AnimatablePair<
    CGFloat,
    AnimatablePair<
      CGFloat,
      AnimatablePair<CGFloat, CGFloat>
    >
  >

  public var animatableData: AnimatableData {
    @inlinable get {
      .init(top, .init(leading, .init(bottom, trailing)))
    }
    @inlinable set {
      let top = newValue[].0
      let leading = newValue[].1[].0
      let (bottom, trailing) = newValue[].1[].1[]
      self = .init(
        top: top,
        leading: leading,
        bottom: bottom,
        trailing: trailing
      )
    }
  }
}
