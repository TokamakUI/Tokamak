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

import Foundation

public struct ProposedViewSize: Equatable, Sendable {
  public var width: CGFloat?
  public var height: CGFloat?

  @inlinable
  public init(width: CGFloat?, height: CGFloat?) {
    self.width = width
    self.height = height
  }
}

public extension ProposedViewSize {
  @inlinable
  init(_ size: CGSize) {
    self.init(width: size.width, height: size.height)
  }

  static let unspecified = ProposedViewSize(width: nil, height: nil)
  static let zero = ProposedViewSize(width: 0, height: 0)
  static let infinity = ProposedViewSize(width: .infinity, height: .infinity)
}

public extension ProposedViewSize {
  @inlinable
  func replacingUnspecifiedDimensions(
    by size: CGSize = CGSize(width: 10, height: 10)
  ) -> CGSize {
    CGSize(
      width: width ?? size.width,
      height: height ?? size.height
    )
  }
}
