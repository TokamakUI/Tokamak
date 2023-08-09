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
//  Created by Szymon on 6/8/2023.
//

import Foundation
import OpenCombineShim

extension View {
    /// Adds an action to perform when this view detects data emitted by the given publisher.
    /// - Parameters:
    ///   - publisher: The publisher to subscribe to.
    ///   - action: The action to perform when an event is emitted by publisher. The event emitted by publisher is passed as a parameter to action.
    /// - Returns: A view that triggers action when publisher emits an event.
    func onReceive<P>(
        _ publisher: P,
        perform action: @escaping (P.Output) -> Void
    ) -> some View where P : Publisher, P.Failure == Never {
        return self.modifier(OnReceiveModifier(publisher: publisher, action: action))
    }
    
    /// Adds a modifier for this view that fires an action when a specific value changes.
    /// - Parameters:
    ///   - value: The value to check against when determining whether to run the closure.
    ///   - initial: Whether the action should be run when this view initially appears.
    ///   - action: A closure to run when the value changes.
    ///   - oldValue: The old value that failed the comparison check (or the initial value when requested).
    ///   - newValue: The new value that failed the comparison check.
    /// - Returns: A view that fires an action when the specified value changes.
    func onChange<V>(
        of value: V,
        initial: Bool = false,
        _ action: @escaping (V, V) -> Void
    ) -> some View where V : Equatable {
        return self.modifier(OnChangeModifier(value: value, initial: initial, action: action))
    }
    
    /// Adds a modifier for this view that fires an action when a specific value changes.
    /// - Parameters:
    ///   - value: The value to check against when determining whether to run the closure.
    ///   - initial: Whether the action should be run when this view initially appears.
    ///   - action: A closure to run when the value changes.
    /// - Returns: A view that fires an action when the specified value changes.
    func onChange<V>(
        of value: V,
        initial: Bool = false,
        _ action: @escaping () -> Void
    ) -> some View where V : Equatable {
        return self.modifier(OnChangeModifier(value: value, initial: initial) { _, _ in action() })
    }
}

private struct OnReceiveModifier<P: Publisher>: ViewModifier where P.Failure == Never {
    let publisher: P
    let action: (P.Output) -> Void

    func body(content: Content) -> some View {
        content.onAppear() {
            let _ = publisher.sink { value in
                self.action(value)
            }
        }
    }
}

private struct OnChangeModifier<V: Equatable>: ViewModifier {
    let value: V
    let initial: Bool
    let action: (V, V) -> Void

    init(value: V, initial: Bool, action: @escaping (V, V) -> Void) {
        self.value = value
        self.initial = initial
        self.action = action
    }

    func body(content: Content) -> some View {
        content.onAppear() {
            if initial {
                action(value, value)
            }
        }
        .onReceive(Just(value)) { newValue in
            if newValue != value {
                action(value, newValue)
            }
        }
    }
}
