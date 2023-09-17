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
public struct SimultaneousGesture<First, Second> where First: Gesture, Second: Gesture {
  public typealias Value = SimultaneousGesture.SimultaneousValue

  public struct SimultaneousValue {
    public let first: First.Value?
    public let second: First.Value?
  }

  /// The first of two gestures that can happen simultaneously.
  public let first: First
  /// The second of two gestures that can happen simultaneously.
  public let second: Second

  /// Creates a gesture with two gestures that can receive updates or succeed independently of each
  /// other.
  init(first: First, second: Second) {
    self.first = first
    self.second = second
  }
}
