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

public struct _GestureView<Content: View, G: Gesture>: _PrimitiveView {
    @Environment(\.isEnabled) var isEnabled
    @Environment(\._gestureListener) var gestureListener
    @State public var gestureId: String = UUID().uuidString
    @State public var gesture: G
    @State var eventId: String? = nil
    
    let mask: GestureMask
    let priority: _GesturePriority
    public let content: Content
    
    var minimumDuration: Double? {
        guard let longPressGesture = gesture as? LongPressGesture else {
            return nil
        }
        return longPressGesture.minimumDuration
    }
    
    public init(
        gesture: G,
        mask: GestureMask,
        priority: _GesturePriority = .standard,
        content: Content
    ) {
        self._gesture = State(wrappedValue: gesture)
        self.mask = mask
        self.priority = priority
        self.content = content
    }
    
    public func onPhaseChange(_ phase: _GesturePhase, eventId id: String? = nil) {
        guard isEnabled, let currentEventId = eventId ?? id else { return }
        
        let value = GestureValue(gestureId: gestureId, mask: mask, priority: priority)

        switch phase {
        case .began:
            startDelay()
            eventId = id
            gestureListener.registerStart(value, for: currentEventId)
        case .cancelled, .ended:
            eventId = nil
        default:
            break
        }
        
        guard gestureListener.canProcessGesture(value, for: currentEventId) else {
            // Event being processed by another gestures
            return
        }
        
        if gesture._onPhaseChange(phase) {
            gestureListener.recognizeGesture(value, for: currentEventId)
        }
    }
    
    private func startDelay() {
        guard let minimumDuration else { return }
        Task {
            do {
                try await Task.sleep(for: .seconds(minimumDuration))
                if let eventId {
                    await MainActor.run {
                        onPhaseChange(.changed(location: nil), eventId: eventId)
                    }
                }
            } catch {
                //TODO: What do we do with this error?
                print(error)
            }
        }
    }
}

// MARK: View Extension

extension View {
    /// Attaches a single gesture to the view.
    ///
    /// - Parameter gesture: The gesture to attach.
    /// - Returns: A modified version of the view with the gesture attached.
    @ViewBuilder
    public func gesture<T>(_ gesture: T?, including mask: GestureMask = .all) -> some View where T: Gesture {
        if let gesture {
            _GestureView(gesture: gesture.body, mask: mask, content: self)
        } else {
            self
        }
    }
    
    /// Attaches a gesture to the view to process simultaneously with gestures defined by the view.
    /// - Parameter gesture: The gesture to attach.
    /// - Returns: A modified version of the view with the gesture attached.
    @ViewBuilder
    public func simultaneousGesture<T>(_ gesture: T?, including mask: GestureMask = .all) -> some View where T : Gesture {
        if let gesture {
            _GestureView(
                gesture: gesture.body,
                mask: mask,
                priority: .simultaneous,
                content: self
            )
        } else {
            self
        }
    }
    
    /// Attaches a gesture to the view with a higher precedence than gestures defined by the view.
    /// - Parameters:
    ///   - gesture: A gesture to attach to the view.
    ///   - mask: A value that controls how adding this gesture to the view affects other gestures recognized by the view and its subviews. Defaults to all.
    /// - Returns: A modified version of the view with the gesture attached.
    @ViewBuilder
    public func highPriorityGesture<T>(_ gesture: T?, including mask: GestureMask = .all) -> some View where T : Gesture {
        if let gesture {
            _GestureView(
                gesture: gesture.body,
                mask: mask,
                priority: .highPriority,
                content: self
            )
        } else {
            self
        }
    }
}
