// Copyright 2020 Tokamak contributors
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
//  Created by Szymon on 30/7/2023.
//

import Foundation

/// Options that control how adding a gesture to a view affects other gestures recognized by the
/// view and its subviews.
@frozen
public struct GestureMask: OptionSet, Sendable {
  public typealias RawValue = Int8
  public var rawValue: Int8

  // MARK: - OptionSet

  public init(rawValue: Int8) {
    self.rawValue = rawValue
  }

  // MARK: - Gesture Options

  /// Enable both the added gesture as well as all other gestures on the view and its subviews.
  public static let all: Self = [.gesture, .subviews]

  /// Enable the added gesture but disable all gestures in the subview hierarchy.
  public static let gesture: Self = GestureMask(rawValue: 1 << 0)

  /// Enable all gestures in the subview hierarchy but disable the added gesture.
  public static let subviews: Self = GestureMask(rawValue: 1 << 1)

  /// Disable all gestures in the subview hierarchy, including the added gesture.
  public static let none: Self = []
}
