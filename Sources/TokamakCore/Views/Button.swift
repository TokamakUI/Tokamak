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
//  Created by Max Desiatov on 02/12/2018.
//

public struct Button<Label>: View where Label: View {
  let label: Label

  // FIXME: this should be internal
  public let action: () -> ()

  public init(action: @escaping () -> (), @ViewBuilder label: () -> Label) {
    self.label = label()
    self.action = action
  }

  public var body: Never {
    neverBody("Text")
  }
}

extension Button where Label == Text {
  public init<S>(_ title: S, action: @escaping () -> ()) where S: StringProtocol {
    self.init(action: action) {
      Text(title)
    }
  }
}

extension Button: ParentView {
  public var children: [AnyView] {
    (label as? GroupView)?.children ?? [AnyView(label)]
  }
}

public func buttonLabel(_ button: Button<Text>) -> String {
  button.label.content
}
