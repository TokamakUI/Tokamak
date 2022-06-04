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
//  Created by Jed Fox on 07/04/2020.
//

public struct Toggle<Label>: View where Label: View {
  @Binding
  var isOn: Bool

  var label: Label

  @Environment(\.toggleStyle)
  var toggleStyle

  public init(isOn: Binding<Bool>, label: () -> Label) {
    _isOn = isOn
    self.label = label()
  }

  @_spi(TokamakCore)
  public var body: AnyView {
    toggleStyle.makeBody(
      configuration: ToggleStyleConfiguration(label: AnyView(label), isOn: $isOn)
    )
  }
}

public extension Toggle where Label == Text {
  init<S>(_ title: S, isOn: Binding<Bool>) where S: StringProtocol {
    self.init(isOn: isOn) {
      Text(title)
    }
  }
}

public extension Toggle where Label == AnyView {
  init(_ configuration: ToggleStyleConfiguration) {
    label = configuration.label
    _isOn = configuration.$isOn
  }
}

extension Toggle: ParentView {
  @_spi(TokamakCore)
  public var children: [AnyView] {
    (label as? GroupView)?.children ?? [AnyView(label)]
  }
}
