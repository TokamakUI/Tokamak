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
//  Created by Carson Katri on 06/29/2020.
//

public enum Axis: Int8, CaseIterable {
  case horizontal
  case vertical

  public struct Set: OptionSet {
    public let rawValue: Int8
    public init(rawValue: Int8) {
      self.rawValue = rawValue
    }

    public static let horizontal: Axis.Set = .init(rawValue: 1 << 0)
    public static let vertical: Axis.Set = .init(rawValue: 1 << 1)
  }
}
