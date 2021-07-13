// Copyright 2018-2020 Tokamak contributors
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
//  Created by Carson Katri on 7/12/21.
//

import Foundation

struct AccentColorKey: EnvironmentKey {
  static let defaultValue: Color? = nil
}

public extension EnvironmentValues {
  var accentColor: Color? {
    get {
      self[AccentColorKey.self]
    }
    set {
      self[AccentColorKey.self] = newValue
    }
  }
}

public extension View {
  func accentColor(_ accentColor: Color?) -> some View {
    environment(\.accentColor, accentColor)
  }
}

struct ForegroundColorKey: EnvironmentKey {
  static let defaultValue: Color? = nil
}

public extension EnvironmentValues {
  var foregroundColor: Color? {
    get {
      self[ForegroundColorKey.self]
    }
    set {
      self[ForegroundColorKey.self] = newValue
    }
  }
}

public extension View {
  func foregroundColor(_ color: Color?) -> some View {
    environment(\.foregroundColor, color)
  }
}
