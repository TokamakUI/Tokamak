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
//  Created by Carson Katri on 2/18/22.
//

import Foundation

/// Used to identify an alignment guide.
///
/// Typically, you would define an alignment guide inside
/// an extension on `HorizontalAlignment` or `VerticalAlignment`:
///
///     extension HorizontalAlignment {
///       private enum MyAlignmentGuide: AlignmentID {
///         static func defaultValue(in context: ViewDimensions) -> CGFloat {
///           return 0.0
///         }
///       }
///       public static let myAlignmentGuide = Self(MyAlignmentGuide.self)
///     }
///
/// Which you can then use with the `alignmentGuide` modifier:
///
///     VStack(alignment: .myAlignmentGuide) {
///       Text("Align Leading")
///         .border(.red)
///         .alignmentGuide(.myAlignmentGuide) { $0[.leading] }
///       Text("Align Trailing")
///         .border(.blue)
///         .alignmentGuide(.myAlignmentGuide) { $0[.trailing] }
///     }
///     .border(.green)
public protocol AlignmentID {
  /// The default value for this alignment guide
  /// when not set via the `alignmentGuide` modifier.
  static func defaultValue(in context: ViewDimensions) -> CGFloat
}

/// An alignment position along the horizontal axis.
@frozen
public struct HorizontalAlignment: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }

  let id: AlignmentID.Type

  public init(_ id: AlignmentID.Type) {
    self.id = id
  }
}

extension HorizontalAlignment {
  public static let leading = Self(Leading.self)

  private enum Leading: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
      0
    }
  }

  public static let center = Self(Center.self)

  private enum Center: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
      context.width / 2
    }
  }

  public static let trailing = Self(Trailing.self)

  private enum Trailing: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
      context.width
    }
  }
}

@frozen
public struct VerticalAlignment: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }

  let id: AlignmentID.Type

  public init(_ id: AlignmentID.Type) {
    self.id = id
  }
}

extension VerticalAlignment {
  public static let top = Self(Top.self)
  private enum Top: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
      0
    }
  }

  public static let center = Self(Center.self)
  private enum Center: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
      context.height / 2
    }
  }

  public static let bottom = Self(Bottom.self)
  private enum Bottom: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
      context.height
    }
  }

  // TODO: Add baseline vertical alignment guides.
  // public static let firstTextBaseline: VerticalAlignment
  // public static let lastTextBaseline: VerticalAlignment
}

/// An alignment in both axes.
public struct Alignment: Equatable {
  public var horizontal: HorizontalAlignment
  public var vertical: VerticalAlignment

  public init(
    horizontal: HorizontalAlignment,
    vertical: VerticalAlignment
  ) {
    self.horizontal = horizontal
    self.vertical = vertical
  }

  public static let topLeading = Self(horizontal: .leading, vertical: .top)
  public static let top = Self(horizontal: .center, vertical: .top)
  public static let topTrailing = Self(horizontal: .trailing, vertical: .top)
  public static let leading = Self(horizontal: .leading, vertical: .center)
  public static let center = Self(horizontal: .center, vertical: .center)
  public static let trailing = Self(horizontal: .trailing, vertical: .center)
  public static let bottomLeading = Self(horizontal: .leading, vertical: .bottom)
  public static let bottom = Self(horizontal: .center, vertical: .bottom)
  public static let bottomTrailing = Self(horizontal: .trailing, vertical: .bottom)
}
