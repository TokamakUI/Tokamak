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
//  Created by Jed Fox on 06/28/2020.
//

public struct SecureField<Label>: View where Label: View {
  let label: Label

  // FIXME: this should be internal
  public let textBinding: Binding<String>
  public let commitAction: () -> ()

  public var body: Never {
    neverBody("SecureField")
  }
}

extension SecureField where Label == Text {
  public init<S>(
    _ title: S, text: Binding<String>,
    onCommit: @escaping () -> () = {}
  ) where S: StringProtocol {
    label = Text(title)
    textBinding = text.projectedValue
    commitAction = onCommit
  }
}

public func secureFieldLabel(_ secureField: SecureField<Text>) -> String {
  secureField.label.content
}
