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
public struct SequenceGesture<First, Second> where First: Gesture, Second: Gesture {
  /// The value of a sequence gesture that helps to detect whether the first gesture succeeded, so
  /// the second gesture can start.
  public typealias Value = SequenceGesture.SequenceValue

  public struct SequenceValue {
    public var first: First.Value
    public var second: First.Value
  }

  /// The first gesture in a sequence of two gestures.
  public var first: First
  /// The second gesture in a sequence of two gestures.
  public var second: Second

  /// Creates a sequence gesture with two gestures.
  init(first: First, second: Second) {
    self.first = first
    self.second = second
  }
}
