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

public struct _PickerContainer<Label: View, SelectionValue: Hashable, Content: View>: View {
  @Binding public var selection: SelectionValue
  public let label: Label
  public let content: Content
  @Environment(\.pickerStyle) public var style

  public init(
    selection: Binding<SelectionValue>,
    label: Label,
    @ViewBuilder content: () -> Content
  ) {
    _selection = selection
    self.label = label
    self.content = content()
  }

  public var body: Never {
    neverBody("_PickerLabel")
  }
}

public struct _PickerElement: View {
  public let valueIndex: Int?
  public let content: AnyView
  @Environment(\.pickerStyle) public var style

  public var body: Never {
    neverBody("_PickerElement")
  }
}

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

  public var body: some View {
    var indices = [SelectionValue: Int]()
    var values = [SelectionValue]()

    return _PickerContainer(
      selection: Binding<Int>(
        get: { indices[selection.wrappedValue]! },
        set: { selection.wrappedValue = values[$0] }
      ),
      label: label
    ) {
      // A special behavior is implemented here. If one of the children is `ForEach`
      // and its `Data.Element` type is the same as `SelectionValue` type, then we can
      // update the binding.
      if let forEach = cast(content) {
        map(forEach, &indices, &values)
      } else {
        // cache the `children` computed property
        let children = self.children

        ForEach(0..<children.count) { index in
          if let forEach = cast(children[index]) {
            map(forEach, &indices, &values)
          } else {
            _PickerElement(valueIndex: nil, content: children[index])
          }
        }
      }
    }
  }

  @ViewBuilder
  private func map(
    _ forEach: ForEachProtocol,
    _ indices: inout [SelectionValue: Int],
    _ values: inout [SelectionValue]
  ) -> some View {
    let nestedChildren = forEach.children

    ForEach(0..<nestedChildren.count) { nestedIndex -> _PickerElement in
      if let value = forEach.element(at: nestedIndex) as? SelectionValue {
        indices[value] = nestedIndex
        values.append(value)
      }
      return _PickerElement(valueIndex: nestedIndex, content: nestedChildren[nestedIndex])
    }
  }

  private func cast<V: View>(_ view: V) -> ForEachProtocol? {
    let forEach: ForEachProtocol?

    if let view = view as? AnyView {
      forEach = mapAnyView(view) { (v: ForEachProtocol) in v }
    } else {
      forEach = view as? ForEachProtocol
    }

    guard forEach?.elementType == SelectionValue.self else { return nil }

    return forEach
  }
}

extension Picker where Label == Text {
  @_disfavoredOverload
  public init<S: StringProtocol>(
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
