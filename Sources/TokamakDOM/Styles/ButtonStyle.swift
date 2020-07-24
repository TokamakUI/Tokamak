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
//  Created by Gene Z. Ragan on 07/22/2020.
//

import TokamakCore

public struct DefaultButtonStyle: ButtonStyle {
  public func makeBody(configuration: ButtonStyleConfiguration) -> some View {
    HTML("button",
         listeners: ["click": { _ in
           configuration.action()
         }]) {
      configuration.label
    }
  }
}
