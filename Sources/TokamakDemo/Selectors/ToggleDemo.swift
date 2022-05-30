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

import TokamakShim

public struct ToggleDemo: View {
  @State
  var checked = false

  public var body: some View {
    VStack {
      Toggle("Check me!", isOn: $checked)
      Toggle("Toggle binding that should mirror the toggle above", isOn: $checked)
      Toggle(isOn: Binding(get: { true }, set: { _ in })) {
        Group { Text("I’m always checked!").italic() }.foregroundColor(.red)
      }
    }
  }
}

struct ToggleDemo_Previews: PreviewProvider {
  static var previews: some View {
    ToggleDemo()
  }
}
