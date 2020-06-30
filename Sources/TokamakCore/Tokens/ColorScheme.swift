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

public enum ColorScheme: CaseIterable {
  case dark
  case light
}

struct ColorSchemeKey: EnvironmentKey {
  static let defaultValue: ColorScheme = .light
}

public extension EnvironmentValues {
  var colorScheme: ColorScheme {
    get {
      self[ColorSchemeKey.self]
    }
    set {
      self[ColorSchemeKey.self] = newValue
    }
  }
}
