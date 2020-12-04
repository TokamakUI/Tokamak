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

public enum ColorScheme: CaseIterable, Equatable {
  case dark
  case light
}

public struct _ColorSchemeKey: EnvironmentKey {
  public static var defaultValue: ColorScheme {
    fatalError("\(self) must have a renderer-provided default value")
  }
}

public extension EnvironmentValues {
  var colorScheme: ColorScheme {
    get { self[_ColorSchemeKey.self] }
    set { self[_ColorSchemeKey.self] = newValue }
  }
}

public extension View {
  func colorScheme(_ colorScheme: ColorScheme) -> some View {
    environment(\.colorScheme, colorScheme)
  }
}

public struct PreferredColorSchemeKey: PreferenceKey {
  public typealias Value = ColorScheme?
  public static func reduce(value: inout Value, nextValue: () -> Value) {
    value = nextValue()
  }
}

public extension View {
  func preferredColorScheme(_ colorScheme: ColorScheme?) -> some View {
    preference(key: PreferredColorSchemeKey.self, value: colorScheme)
  }
}
