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

public protocol Gesture {
  // MARK: Required

  /// The type representing the gesture’s value.
  associatedtype Value

  /// The type of gesture representing the body of Self.
  associatedtype Body: Gesture

  /// The content and behavior of the gesture.
  var body: Self.Body { get }

  /// Adds an action to perform when the gesture’s phase changes.
  /// - Parameter phase: Gesture new phase
  /// - Returns: Returns `true` if the  gesture is recognized, false otherwise.
  mutating func _onPhaseChange(_ phase: _GesturePhase) -> Bool
  /// Adds an action to perform when the gesture’s value changes.
  func _onChanged(perform action: @escaping (Value) -> ()) -> Self
  /// Adds an action to perform when the gesture ends.
  func _onEnded(perform action: @escaping (Value) -> ()) -> Self
}

// MARK: Performing the gesture

public extension Gesture {
  /// Adds an action to perform when the gesture ends.
  func onEnded(_ action: @escaping (Self.Value) -> ()) -> _EndedGesture<Self> {
    _EndedGesture(self, onEnded: action)
  }

  /// Updates the provided gesture value property as the gesture’s value changes.
  func updating<State>(
    _ state: GestureState<State>,
    body: @escaping (Self.Value, inout State, inout Transaction) -> ()
  ) -> GestureStateGesture<Self, State> {
    GestureStateGesture(base: self, state: state, updatingBody: body)
  }
}

// MARK: Performing the gesture

public extension Gesture where Value: Equatable {
  /// Adds an action to perform when the gesture’s value changes.
  /// Available when Value conforms to Equatable.
  func onChanged(_ action: @escaping (Self.Value) -> ()) -> _ChangedGesture<Self> {
    _ChangedGesture(self, onChanged: action)
  }
}

// MARK: Composing gestures

public extension Gesture {
  /// Combines a gesture with another gesture to create a new gesture that recognizes both gestures
  /// at the same time.
  func simultaneously<Other>(with gesture: Other) -> SimultaneousGesture<Self, Other> {
    SimultaneousGesture(first: self, second: gesture)
  }

  /// Sequences a gesture with another one to create a new gesture, which results in the second
  /// gesture only receiving events after the first gesture succeeds.
  func sequenced<Other>(before gesture: Other) -> SequenceGesture<Self, Other> {
    SequenceGesture(first: self, second: gesture)
  }

  /// Combines two gestures exclusively to create a new gesture where only one gesture succeeds,
  /// giving precedence to the first gesture.
  func exclusively<Other>(before gesture: Other) -> ExclusiveGesture<Self, Other> {
    ExclusiveGesture(first: self, second: gesture)
  }
}

// MARK: Transforming a gesture

extension Gesture {}

// MARK: Private Helpers

extension Gesture {
  func calculateDistance(xOffset: Double, yOffset: Double) -> Double {
    let xSquared = pow(xOffset, 2)
    let ySquared = pow(yOffset, 2)
    let sumOfSquares = xSquared + ySquared
    let distance = sqrt(sumOfSquares)
    return distance
  }

  func calculateTranslation(from pointA: CGPoint, to pointB: CGPoint) -> CGSize {
    let dx = pointB.x - pointA.x
    let dy = pointB.y - pointA.y
    return CGSize(width: dx, height: dy)
  }

  func calculateVelocity(from translation: CGSize, timeElapsed: Double) -> CGSize {
    guard timeElapsed > .zero else { return .zero }
    let velocityX = translation.width / timeElapsed
    let velocityY = translation.height / timeElapsed

    return CGSize(width: velocityX, height: velocityY)
  }

  func calculatePredictedEndLocation(from location: CGPoint, velocity: CGSize) -> CGPoint {
    let predictedX = location.x + velocity.width
    let predictedY = location.y + velocity.height

    return CGPoint(x: predictedX, y: predictedY)
  }

  func calculatePredictedEndTranslation(from translation: CGSize, velocity: CGSize) -> CGSize {
    let predictedWidth = translation.width + velocity.width
    let predictedHeight = translation.height + velocity.height

    return CGSize(width: predictedWidth, height: predictedHeight)
  }
}
