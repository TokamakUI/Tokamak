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

/// Options that control how adding a gesture to a view affects other gestures recognized by the view and its subviews.
@frozen public struct GestureMask: Equatable, ExpressibleByArrayLiteral, OptionSet, Sendable {
    public typealias RawValue = Int8
    public var rawValue: Int8

    // MARK: - OptionSet

    public init(rawValue: Int8) {
        self.rawValue = rawValue
    }

    // MARK: - Equatable

    public static func == (lhs: GestureMask, rhs: GestureMask) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    // MARK: - ExpressibleByArrayLiteral

    /// Creates a gesture mask from an array of gesture options.
    ///
    /// - Parameter elements: An array of `GestureMask` elements.
    public init(arrayLiteral elements: GestureMask...) {
        self.rawValue = elements.reduce(0) { $0 | $1.rawValue }
    }

    // MARK: - SetAlgebra

    static var allZeros: GestureMask {
        return GestureMask(rawValue: 0)
    }

    static func | (lhs: GestureMask, rhs: GestureMask) -> GestureMask {
        return GestureMask(rawValue: lhs.rawValue | rhs.rawValue)
    }

    static func & (lhs: GestureMask, rhs: GestureMask) -> GestureMask {
        return GestureMask(rawValue: lhs.rawValue & rhs.rawValue)
    }

    static prefix func ~ (x: GestureMask) -> GestureMask {
        return GestureMask(rawValue: ~x.rawValue)
    }

    // MARK: - Gesture Options

    /// Enable both the added gesture as well as all other gestures on the view and its subviews.
    public static let all: Self = .gesture | .subviews

    /// Enable the added gesture but disable all gestures in the subview hierarchy.
    public static let gesture: Self = GestureMask(rawValue: 1 << 0)

    /// Enable all gestures in the subview hierarchy but disable the added gesture.
    public static let subviews: Self = GestureMask(rawValue: 1 << 1)

    /// Disable all gestures in the subview hierarchy, including the added gesture.
    public static let none: Self = []

    // MARK: - Helper Methods

    /// Enables a specific gesture option in the mask.
    ///
    /// - Parameter option: The `GestureMask` representing the gesture option to enable.
    mutating func enableGesture(_ option: GestureMask) {
        self.insert(option)
    }

    /// Disables a specific gesture option in the mask.
    ///
    /// - Parameter option: The `GestureMask` representing the gesture option to disable.
    mutating func disableGesture(_ option: GestureMask) {
        self.remove(option)
    }
}

