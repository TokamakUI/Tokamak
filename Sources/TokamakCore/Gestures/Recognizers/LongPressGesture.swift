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

public struct LongPressGesture: Gesture {
    public typealias Value = Bool
    private var startLocation: CGPoint? = nil
    private var touchStartTime = Date(timeIntervalSince1970: 0)
    private var maximumDistance: Double = 0
    private var onEndedAction: ((Value) -> Void)? = nil
    private var onChangedAction: ((Value) -> Void)? = nil
    public private(set) var minimumDuration: Double
    public var body: LongPressGesture {
        self
    }
    
    /// Creates a long-press gesture with a minimum duration
    /// - Parameter minimumDuration: The minimum duration of the long press that must elapse before the gesture succeeds.
    public init(minimumDuration: Double = 0.5) {
        self.minimumDuration = minimumDuration
    }
    
    /// Creates a long-press gesture with a minimum duration and a maximum distance that the interaction can move before the gesture fails.
    /// - Parameters:
    ///   - minimumDuration: The minimum duration of the long press that must elapse before the gesture succeeds.
    ///   - maximumDistance: The maximum distance that the long press can move before the gesture fails.
    public init(minimumDuration: Double, maximumDistance: Double) {
        self.minimumDuration = minimumDuration
        self.maximumDistance = maximumDistance
    }
    
    public mutating func _onPhaseChange(_ phase: _GesturePhase) {
        switch phase {
        case .began(let location):
            startLocation = location
            touchStartTime = Date()
            onChangedAction?(startLocation != nil)
        case .changed(let location) where startLocation != nil:
            guard let startLocation else { return }
            let translation = calculateTranslation(from: startLocation, to: location)
            let distance = calculateDistance(xOffset: translation.width, yOffset: translation.height)
            
            guard maximumDistance >= distance  else {
                // Fail longpress if distance is to big.
                self.startLocation = nil
                return
            }
            
            let touch = Date()
            let delayInSeconds = touch.timeIntervalSince(touchStartTime)
            
            if delayInSeconds >= minimumDuration {
                // Reset state, so behaviour matches SwiftUI. Although, SwiftUI doesn't trigger it, but we have to.
                onChangedAction?(false)
                // The LongPress gesture ends when the required duration is met.
                onEndedAction?(true)
                self.startLocation = nil
            }
        case .changed:
            break
        case .cancelled, .ended:
            onChangedAction?(false)
            startLocation = nil
        }
    }

    public func _onEnded(perform action: @escaping (Value) -> Void) -> Self {
        var gesture = self
        gesture.onEndedAction = action
        return gesture
    }
    
    public func _onChanged(perform action: @escaping (Value) -> Void) -> Self {
        var gesture = self
        gesture.onChangedAction = action
        return gesture
    }
}

// MARK: View Modifiers

extension View {
    /// Adds an action to perform when this view recognizes a remote long touch gesture.
    /// A long touch gesture is when the finger is on the remote touch surface without actually pressing.
    public func onLongPressGesture(perform action: @escaping () -> Void) -> some View {
        self.modifier(LongPressGestureModifier(action: action))
    }
    
    /// Adds an action to perform when this view recognizes a long press gesture.
    public func onLongPressGesture(
        minimumDuration: Double,
        maximumDistance: Double,
        perform action: @escaping () -> Void,
        onPressingChanged: ((Bool) -> Void)?
    ) -> some View {
        self.modifier(
            LongPressGestureModifier(
                minimumDuration: minimumDuration,
                maximumDistance: maximumDistance,
                onPressingChanged: onPressingChanged,
                action: action
            )
        )
    }
    
    /// Adds an action to perform when this view recognizes a long press gesture.
    public func onLongPressGesture(
        minimumDuration: Double = 0.5,
        maximumDistance: Double = 10.0,
        pressing: ((Bool) -> Void)? = nil,
        perform action: @escaping () -> Void
    ) -> some View {
        self.modifier(
            LongPressGestureModifier(
                minimumDuration: minimumDuration,
                maximumDistance: maximumDistance,
                onPressingChanged: pressing,
                action: action
            )
        )
    }
}

struct LongPressGestureModifier: ViewModifier {
    var minimumDuration: Double = 0.5
    var maximumDistance: Double = 10.0
    var onPressingChanged: ((Bool) -> Void)? = nil
    let action: () -> Void
    
    @GestureState private var isPressing = false
    
    func body(content: Content) -> some View {
        content.gesture(
            LongPressGesture(minimumDuration: minimumDuration, maximumDistance: maximumDistance)
                .updating($isPressing) { currentState, gestureState, _ in
                    gestureState = currentState
                    onPressingChanged?(isPressing)
                }
                .onEnded { _ in
                    action()
                }
        )
    }
}
