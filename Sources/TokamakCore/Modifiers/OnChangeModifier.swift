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
//  Created by Szymon on 20/8/2023.
//

import Foundation
import OpenCombineShim

struct OnChangeModifier<V: Equatable>: ViewModifier {
  @State
  private var oldValue: V?

  let value: V
  let initial: Bool
  let action: (V, V) -> ()

  func body(content: Content) -> some View {
    content
      .onReceive(Just(value)) { newValue in
        // TODO: Fix, when @State if working with in a ViewModifier
        // ignore first call when oldValue == nil. For now old value is always nil
        if newValue != oldValue {
          action(oldValue ?? value, newValue)
        }
        oldValue = value
      }
      .onAppear {
        if initial {
          action(value, value)
        }
      }
  }
}

public extension View {
  /// Adds a modifier for this view that fires an action when a specific value changes.
  /// - Parameters:
  ///   - value: The value to check against when determining whether to run the closure.
  ///   - initial: Whether the action should be run when this view initially appears.
  ///   - action: A closure to run when the value changes.
  ///   - oldValue: The old value that failed the comparison check (or the initial value when
  /// requested).
  ///   - newValue: The new value that failed the comparison check.
  /// - Returns: A view that fires an action when the specified value changes.
  func onChange<V>(
    of value: V,
    initial: Bool = false,
    _ action: @escaping (V, V) -> ()
  ) -> some View where V: Equatable {
    modifier(OnChangeModifier(value: value, initial: initial, action: action))
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
    _ action: @escaping () -> ()
  ) -> some View where V: Equatable {
    modifier(OnChangeModifier(value: value, initial: initial) { _, _ in action() })
  }
}
