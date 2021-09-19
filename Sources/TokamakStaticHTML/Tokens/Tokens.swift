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

import TokamakCore

extension Color {
  func cssValue(_ environment: EnvironmentValues) -> String {
    _ColorProxy(self).resolve(in: environment).cssValue
  }
}

public extension AnyColorBox.ResolvedValue {
  var cssValue: String {
    "rgba(\(red * 255), \(green * 255), \(blue * 255), \(opacity))"
  }
}

extension GridItem: CustomStringConvertible {
  public var description: String {
    switch size {
    case let .adaptive(minimum: min, maximum: max):
      let min = min == .infinity ? "1fr" : "\(min)px"
      let max = max == .infinity ? "1fr" : "\(max)px"
      return "repeat(auto-fill, minmax(\(min), \(max)))"
    case let .fixed(size):
      return "\(size)px"
    case let .flexible(minimum: min, maximum: max):
      let min = min == .infinity ? "1fr" : min.description
      let max = max == .infinity ? "1fr" : max.description
      return "minmax(\(min), \(max))"
    }
  }
}

extension UnitPoint {
  var cssValue: String {
    "\(x * 100)% \(y * 100)%"
  }
}
