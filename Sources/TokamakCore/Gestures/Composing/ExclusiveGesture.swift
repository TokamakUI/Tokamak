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

@frozen
/// The ExclusiveGesture gives precedence to its first gesture.
public struct ExclusiveGesture<First, Second> where First: Gesture, Second: Gesture {
  /// The value of an exclusive gesture that indicates which of two gestures succeeded.
  public typealias Value = ExclusiveGesture.ExclusiveValue

  public struct ExclusiveValue {
    public var first: First.Value
    public var second: First.Value
  }

  /// The first of two gestures.
  public var first: First
  /// The second of two gestures.
  public var second: Second

  /// Creates a gesture from two gestures where only one of them succeeds.
  init(first: First, second: Second) {
    self.first = first
    self.second = second
  }
}
