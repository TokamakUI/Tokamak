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

public struct GestureStateGesture<Base: Gesture, State>: Gesture {
  public typealias Value = Base.Value

  @GestureState
  private var gestureState: State
  private var gesture: Base

  private let updatingBody: (Base.Value, inout State, inout Transaction) -> ()
  private var onEnded: ((Value) -> ())?

  public var body: Base.Body {
    var gesture = gesture._onChanged(perform: { value in
      // TODO: Is this transaction working?
      var transaction = Transaction._active ?? .init(animation: nil)
      updatingBody(value, &gestureState, &transaction)
    })
    if let onEnded {
      gesture = gesture._onEnded(perform: onEnded)
    }
    return gesture.body
  }

  init(
    base: Base,
    state: GestureState<State>,
    updatingBody: @escaping (Base.Value, inout State, inout Transaction) -> ()
  ) {
    gesture = base
    _gestureState = state
    self.updatingBody = updatingBody
  }

  public mutating func _onPhaseChange(_ phase: _GesturePhase) -> Bool {
    fatalError(
      "\(String(reflecting: Self.self)) is a proxy `Gesture`, onPhaseChange should never be called."
    )
  }

  public func _onEnded(perform action: @escaping (Value) -> ()) -> Self {
    var gesture = self
    gesture.onEnded = action
    return gesture
  }

  public func _onChanged(perform action: @escaping (Value) -> ()) -> Self {
    self
  }
}
