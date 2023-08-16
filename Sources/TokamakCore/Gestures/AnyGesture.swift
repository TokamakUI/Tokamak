// Copyright 2020-2021 Tokamak contributors
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
//  Created by Szymon on 11/8/2023.
//

import Foundation

/// A type-erased gesture.
public struct AnyGesture<Value>: Gesture {
    typealias ActionClosure = (Value) -> Void
    /// The type of the underlying `Gesture`.
    let gestureType: Any.Type
    /// The type of the `body` of the underlying `gesture`. Used to cast the result of the applied `bodyClosure` property.
    let bodyType: Any.Type
    /// The actual `Gesture` value wrapped within this `gesture`.
    var gesture: Any
    
    let bodyClosure: (Any, ActionClosure?, ActionClosure?) -> any Gesture
    var onEnded: ActionClosure?
    var onChanged: ActionClosure?
    
    // `AnyGesture`, just to make it compile for now
    public var body: AnyGesture {
        fatalError("\(String(reflecting: Self.self)) should return underlaying gesture")
        // TODO: Type 'any Gesture' cannot conform to 'Gesture'
        // return bodyClosure(gesture, onChanged, onEnded).body
    }
    
    public init<G: Gesture>(_ gesture: G) where Value == G.Value {
        if let anyGesture = gesture as? AnyGesture {
            self = anyGesture
        } else {
            self.gestureType = G.self
            self.bodyType = G.Body.self
            self.gesture = gesture
            self.bodyClosure = { gesture, onChanged, onEnded in
                // swiftlint:disable:next force_cast
                var gesture = (gesture as! G)
                if let onChanged {
                    gesture = gesture._onChanged(perform: onChanged)
                }
                if let onEnded {
                    gesture = gesture._onEnded(perform: onEnded)
                }
                return gesture
            }
        }
    }
    
    mutating public func _onPhaseChange(_ phase: _GesturePhase) -> Bool {
        fatalError("\(String(reflecting: Self.self)) is a proxy `Gesture`, onPhaseChange should never be called.")
    }
    
    public func _onEnded(perform action: @escaping (Value) -> Void) -> Self {
        var gesture = self
        gesture.onEnded = action
        return gesture
    }

    public func _onChanged(perform action: @escaping (Value) -> Void) -> Self {
        var gesture = self
        gesture.onChanged = action
        return gesture
    }
}
