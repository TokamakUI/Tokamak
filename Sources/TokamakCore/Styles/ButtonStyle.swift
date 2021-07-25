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

public protocol ButtonStyle {
  associatedtype Body: View
  @ViewBuilder
  func makeBody(configuration: Self.Configuration) -> Self.Body
  typealias Configuration = ButtonStyleConfiguration
}

public struct ButtonStyleConfiguration {
  public struct Label: View {
    public let body: AnyView
  }

  public let role: ButtonRole?
  public let label: ButtonStyleConfiguration.Label
  public let isPressed: Bool
}

struct AnyButtonStyle: ButtonStyle {
  let bodyClosure: (ButtonStyleConfiguration) -> AnyView
  let type: Any.Type

  init<S: ButtonStyle>(_ style: S) {
    type = S.self
    bodyClosure = {
      AnyView(style.makeBody(configuration: $0))
    }
  }

  func makeBody(configuration: Configuration) -> some View {
    bodyClosure(configuration)
  }
}
