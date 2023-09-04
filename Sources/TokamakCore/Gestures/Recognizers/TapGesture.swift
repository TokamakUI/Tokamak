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
//  Created by Szymon on 16/7/2023.
//

import Foundation

public struct TapGesture: Gesture {
  public typealias Value = ()
  /// The required number of taps to complete the tap gesture.
  private var count: Int
  /// The maximum duration between the taps
  private var delay: Double = 0.3
  private var touchEndTime = Date()
  private var numberOfTapsSinceGestureBegan: Int = 0
  private var phase: _GesturePhase = .cancelled
  private var onEndedAction: ((Value) -> ())? = nil

  private var isActive: Bool {
    switch phase {
    case .began, .changed:
      return true
    default:
      return false
    }
  }

  public mutating func _onPhaseChange(_ phase: _GesturePhase) -> Bool {
    switch phase {
    case .cancelled:
      numberOfTapsSinceGestureBegan = 0
    case .ended:
      if isActive {
        let touch = Date()
        let delayInSeconds = touch.timeIntervalSince(touchEndTime)
        touchEndTime = touch

        // If we have multi count tap gesture, handle it if the taps are with in desired delays
        if numberOfTapsSinceGestureBegan > 0, delayInSeconds > delay {
          numberOfTapsSinceGestureBegan = 0
        } else {
          numberOfTapsSinceGestureBegan += 1
        }
      }
      // If we ended touch and have desired count we complete gesture
      if numberOfTapsSinceGestureBegan >= count {
        onEndedAction?(())
        numberOfTapsSinceGestureBegan = 0
        return true
      }
    default:
      // TapGesture in SwiftUI have no change update nor events
      break
    }
    self.phase = phase
    // Tap gesture is recognized on touch up
    return false
  }

  public var body: TapGesture {
    self
  }

  /// Creates a tap gesture with the number of required taps.
  /// - Parameter count: The required number of taps to complete the tap gesture.
  public init(count: Int = 1) {
    self.count = count
  }

  public func _onEnded(perform action: @escaping (Value) -> ()) -> Self {
    var gesture = self
    gesture.onEndedAction = action
    return gesture
  }

  public func _onChanged(perform action: @escaping (Value) -> ()) -> Self {
    // TapGesture in SwiftUI have no change update nor events
    self
  }
}

// MARK: View Modifiers

public extension View {
  /// Adds an action to perform when this view recognizes a tap gesture.
  func onTapGesture(count: Int = 1, perform action: @escaping () -> ()) -> some View {
    gesture(
      TapGesture(count: count).onEnded(action)
    )
  }
}
