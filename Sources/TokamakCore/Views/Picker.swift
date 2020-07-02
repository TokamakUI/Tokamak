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

public struct _PickerLabel<Label: View>: View {
  let label: Label

  public var body: Never {
    neverBody("_PickerLabel")
  }
}

public struct _PickerElement: View {
  let content: AnyView

  public var body: Never {
    neverBody("_PickerElement")
  }
}

public struct Picker<Label: View, SelectionValue: Hashable, Content: View>: View {
  let selection: Binding<SelectionValue>
  let label: Label
  let content: Content
  @Environment(\.pickerStyle) var style: PickerStyle

  public init(
    selection: Binding<SelectionValue>,
    label: Label,
    @ViewBuilder content: () -> Content
  ) {
    self.selection = selection
    self.label = label
    self.content = content()
  }

  public var body: some View {
    let children = self.children
    // Need to implement a special behavior here. If one of the children is `ForEach`
    // and its `Data.Element` type is the same as `SelectionValue` type, then we can
    // update the binding.
    Group {
      _PickerLabel(label: label)
      ForEach(0..<children.count) {
        _PickerElement(content: children[$0])
      }
    }
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

extension Picker: ParentView {
  public var children: [AnyView] {
    (content as? GroupView)?.children ?? [AnyView(content)]
  }
}
