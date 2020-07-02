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

import TokamakDOM

struct EnvironmentDemo: View {
  @Environment(\.colorScheme) var scheme: ColorScheme

  @Environment(\.font) var font: Font?

  var body: some View {
    if let font = font {
      return Text("ColorScheme is \(scheme), font is \(font)")
    } else {
      return Text("ColorScheme is \(scheme), `font` environment not set.")
    }
  }
}
