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
//  Created by Carson Katri on 7/31/20.
//

public struct RedactionReasons: OptionSet {
  public let rawValue: Int
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }

  public static let placeholder: Self = .init(rawValue: 1 << 0)
}

public extension View {
  func redacted(reason: RedactionReasons) -> some View {
    environment(\.redactionReasons, reason)
  }

  func unredacted() -> some View {
    environment(\.redactionReasons, [])
  }
}

private struct RedactionReasonsKey: EnvironmentKey {
  static let defaultValue: RedactionReasons = []
}

public extension EnvironmentValues {
  var redactionReasons: RedactionReasons {
    get {
      self[RedactionReasonsKey.self]
    }
    set {
      self[RedactionReasonsKey.self] = newValue
    }
  }
}
