// Copyright 2019-2020 Tokamak contributors
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
//  Created by Carson Katri on 7/25/20.
//

import OpenCombine

/// A simple container for `State` properties.
/// When `value` changes, the new value is sent to the subscribers of `publisher`.
final class StateLocation: AnyLocation {
  var publisher: CurrentValueSubject<Any, Never>
  var value: Any {
    didSet {
      publisher.send(value)
    }
  }

  init(initialValue: Any) {
    publisher = CurrentValueSubject(initialValue)
    value = initialValue
  }
}
