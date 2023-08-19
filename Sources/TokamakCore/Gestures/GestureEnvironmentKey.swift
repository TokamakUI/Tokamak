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
//  Created by Szymon on 13/8/2023.
//

private struct GestureEnvironmentKey: EnvironmentKey {
    static let defaultValue: GestureEnvironmentValue = GestureEnvironmentValue()
}

extension EnvironmentValues {
    var _gestureListener: GestureEnvironmentValue {
        get { self[GestureEnvironmentKey.self] }
        set { self[GestureEnvironmentKey.self] = newValue }
    }
}

class GestureEnvironmentValue {
    var activeGestures: [String: Set<GestureValue>] = [:]

    func registerStart(_ gesture: GestureValue, for event: String) {
        if activeGestures[event] == nil {
            activeGestures[event] = [gesture]
        } else if case .highPriority = gesture.priority {
            activeGestures[event] = [gesture]
        } else {
            activeGestures[event]?.insert(gesture)
        }
    }
    
    func recognizeGesture(_ gesture: GestureValue, for event: String) {
        guard activeGestures[event]?.contains(gesture) == true else {
            return
        }
        var gestures: Set<GestureValue> = activeGestures[event]?.removeLowerPriorities(than: gesture.priority) ?? []
        gestures.insert(gesture)
        activeGestures[event] = gestures
    }
    
    func canProcessGesture(_ gesture: GestureValue, for event: String) -> Bool {
        guard activeGestures[event]?.contains(gesture) == true else {
            return false
        }
        return true
    }
}

struct GestureValue: Hashable {
    let gestureId: String
    let mask: GestureMask
    let priority: _GesturePriority
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(gestureId)
    }
}

// MARK: Helpers

extension Set where Element == GestureValue {
    func removeLowerPriorities(than priority: _GesturePriority) -> Self {
        return self.filter {
            switch priority {
            case .standard, .simultaneous:
                return $0.priority != .standard
            case .highPriority:
                return $0.priority == .highPriority
            }
        }
    }
}
