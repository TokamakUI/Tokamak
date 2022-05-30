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

public protocol _PickerContainerProtocol {
  var elements: [_AnyIDView] { get }
}

public struct _PickerContainer<
  Label: View,
  SelectionValue: Hashable,
  Content: View
>: _PrimitiveView,
  _PickerContainerProtocol
{
  @Binding
  public var selection: SelectionValue

  public let label: Label
  public let content: Content
  public let elements: [_AnyIDView]

  @Environment(\.pickerStyle)
  public var style

  public init(
    selection: Binding<SelectionValue>,
    label: Label,
    elements: [_AnyIDView],
    @ViewBuilder content: () -> Content
  ) {
    _selection = selection
    self.label = label
    self.elements = elements
    self.content = content()
  }
}

public struct _PickerElement: _PrimitiveView {
  public let valueIndex: Int?
  public let content: AnyView

  @Environment(\.pickerStyle)
  public var style
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

  @_spi(TokamakCore)
  public var body: some View {
    let children = self.children

    return _PickerContainer(selection: selection, label: label, elements: elements) {
      // Need to implement a special behavior here. If one of the children is `ForEach`
      // and its `Data.Element` type is the same as `SelectionValue` type, then we can
      // update the binding.
      ForEach(0..<children.count) { index in
        if let forEach = mapAnyView(children[index], transform: { (v: ForEachProtocol) in v }),
           forEach.elementType == SelectionValue.self
        {
          let nestedChildren = forEach.children

          ForEach(0..<nestedChildren.count) { nestedIndex in
            _PickerElement(valueIndex: nestedIndex, content: nestedChildren[nestedIndex])
          }
        } else {
          _PickerElement(valueIndex: nil, content: children[index])
        }
      }
    }
  }
}

public extension Picker where Label == Text {
  @_disfavoredOverload
  init<S: StringProtocol>(
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
  @_spi(TokamakCore)
  public var children: [AnyView] {
    (content as? GroupView)?.children ?? [AnyView(content)]
  }
}

@_spi(TokamakCore)
extension Picker: _PickerContainerProtocol {
  @_spi(TokamakCore)
  public var elements: [_AnyIDView] {
    (content as? ForEachProtocol)?.children
      .compactMap {
        mapAnyView($0, transform: { (v: _AnyIDView) in v })
      } ?? []
    // .filter { $0.elementType == SelectionValue.self }
    // .map(\.children) ?? []
  }
}
