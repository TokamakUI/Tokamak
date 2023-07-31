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


public struct GestureView<Content: View, G: Gesture>: _PrimitiveView {
    @Environment(\.isEnabled) var isEnabled
    // TODO: Allow for array of gestures with priority
    // TODO: Add AnyGesture, for type erease
    // TODO: Add GestureReader? 
    @State public var gesture: G
    public let content: Content

    public init(_ content: Content, gesture: G) {
        self.content = content
        self._gesture = State(wrappedValue: gesture)
    }
}

extension View {
    /// Attaches a single gesture to the view.
    ///
    /// - Parameter gesture: The gesture to attach.
    /// - Returns: A modified version of the view with the gesture attached.
    public func gesture<T>(_ gesture: T, including mask: GestureMask = .all) -> some View where T: Gesture {
        GestureView(self, gesture: gesture.body)
    }
    
    /// Attaches a gesture to the view to process simultaneously with gestures defined by the view.
    /// - Parameter gesture: The gesture to attach.
    /// - Returns: A modified version of the view with the gesture attached.
    public func simultaneousGesture<T>(_ gesture: T, including mask: GestureMask = .all) -> some View where T : Gesture {
        GestureView(self, gesture: gesture.body)
    }
    
    /// Attaches a gesture to the view with a higher precedence than gestures defined by the view.
    /// - Parameters:
    ///   - gesture: A gesture to attach to the view.
    ///   - mask: A value that controls how adding this gesture to the view affects other gestures recognized by the view and its subviews. Defaults to all.
    /// - Returns: A modified version of the view with the gesture attached.
    func highPriorityGesture<T>(_ gesture: T, including mask: GestureMask = .all) -> some View where T : Gesture {
        GestureView(self, gesture: gesture.body)
    }
}
