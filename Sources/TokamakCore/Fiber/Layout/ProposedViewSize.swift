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
