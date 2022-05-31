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
//  Created by Carson Katri on 6/30/20.
//

import TokamakShim

class TestEnvironment: ObservableObject {
  @Published
  var envTest = "Hello, world!"

  init() {}
}

struct EnvironmentObjectDemo: View {
  @EnvironmentObject
  var testEnv: TestEnvironment

  var body: some View {
    Button(testEnv.envTest) {
      testEnv.envTest = "EnvironmentObject modified."
    }
  }
}

extension ColorScheme: CustomStringConvertible {
  public var description: String {
    switch self {
    case .dark: return "dark"
    case .light: return "light"
    @unknown default: return "unknown"
    }
  }
}

struct EnvironmentDemo: View {
  @Environment(\.colorScheme)
  var colorScheme

  @Environment(\.font)
  var font

  @EnvironmentObject
  var testEnv: TestEnvironment

  var body: some View {
    VStack {
      Text("`colorScheme` is \(colorScheme.description)")
      if let font = font {
        Text("`font` environment is \(String(describing: font))")
      }
      Text(testEnv.envTest)
      EnvironmentObjectDemo()
    }
  }
}
