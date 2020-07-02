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

public struct Picker<Label: View, SelectionValue: Hashable, Content: View>: View {
  let selection: Binding<SelectionValue>
  let label: Label
  let content: Content

  public init(
    selection: Binding<SelectionValue>,
    label: Label,
    @ViewBuilder content: () -> Content
  ) {
    self.selection = selection
    self.label = label
    self.content = content()
  }

  public var body: Never {
    neverBody("Picker")
  }
}

extension Picker where Label == Text {
  @_disfavoredOverload public init<S: StringProtocol>(
    _ title: S,
    selection: Binding<SelectionValue>,
    @ViewBuilder content: () -> Content
  ) {
    self.init(selection: selection, label: Text(title)) {
      content()
    }
  }
}

/// This is a helper class that works around absence of "package private" access control in Swift
public struct _PickerProxy<Label: View, SelectionValue: Hashable, Content: View> {
  public let subject: Picker<Label, SelectionValue, Content>

  public init(_ subject: Picker<Label, SelectionValue, Content>) { self.subject = subject }

  public var selection: Binding<SelectionValue> { subject.selection }
  public var label: Label { subject.label }
  public var content: Content { subject.content }
}
