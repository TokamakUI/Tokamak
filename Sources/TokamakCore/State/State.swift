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
//  Created by Max Desiatov on 08/04/2020.
//

import OpenCombine

protocol AnyLocation: AnyObject {
  var value: Any { get set }
}

protocol ValueStorage {
  var _location: AnyLocation! { get set }
  var anyInitialValue: Any { get }
}

@propertyWrapper public struct State<Value>: DynamicProperty {
  private let initialValue: Value
  var _location: AnyLocation!
  var anyInitialValue: Any { initialValue as Any }

  public init(wrappedValue value: Value) {
    initialValue = value
  }

  public var wrappedValue: Value {
    get { _location.value as? Value ?? initialValue }
    nonmutating set { _location.value = newValue }
  }

  public var projectedValue: Binding<Value> {
    .init {
      // swiftlint:disable:next force_cast
      _location.value as! Value
    } set: {
      _location.value = $0
    }
  }
}

extension State: ValueStorage {}

extension State where Value: ExpressibleByNilLiteral {
  @inlinable public init() { self.init(wrappedValue: nil) }
}
