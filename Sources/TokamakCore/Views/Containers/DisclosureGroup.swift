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
//  Created by Carson Katri on 7/3/20.
//

public struct DisclosureGroup<Label, Content>: _PrimitiveView where Label: View, Content: View {
  @State
  var isExpanded: Bool = false
  let isExpandedBinding: Binding<Bool>?

  @Environment(\._outlineGroupStyle)
  var style

  let label: Label
  let content: () -> Content

  public init(@ViewBuilder content: @escaping () -> Content, @ViewBuilder label: () -> Label) {
    isExpandedBinding = nil
    self.label = label()
    self.content = content
  }

  public init(
    isExpanded: Binding<Bool>,
    @ViewBuilder content: @escaping () -> Content,
    @ViewBuilder label: () -> Label
  ) {
    isExpandedBinding = isExpanded
    self.label = label()
    self.content = content
  }
}

public extension DisclosureGroup where Label == Text {
  // FIXME: Implement LocalizedStringKey
//  public init(_ titleKey: LocalizedStringKey,
//              @ViewBuilder content: @escaping () -> Content)
//  public init(_ titleKey: SwiftUI.LocalizedStringKey,
//              isExpanded: SwiftUI.Binding<Swift.Bool>,
//              @SwiftUI.ViewBuilder content: @escaping () -> Content)

  @_disfavoredOverload
  init<S>(_ label: S, @ViewBuilder content: @escaping () -> Content)
    where S: StringProtocol
  {
    self.init(content: content, label: { Text(label) })
  }

  @_disfavoredOverload
  init<S>(
    _ label: S,
    isExpanded: Binding<Bool>,
    @ViewBuilder content: @escaping () -> Content
  ) where S: StringProtocol {
    self.init(isExpanded: isExpanded, content: content, label: { Text(label) })
  }
}

public struct _DisclosureGroupProxy<Label, Content>
  where Label: View, Content: View
{
  public var subject: DisclosureGroup<Label, Content>

  public init(_ subject: DisclosureGroup<Label, Content>) { self.subject = subject }

  public var label: Label { subject.label }
  public var content: () -> Content { subject.content }
  public var style: _OutlineGroupStyle { subject.style }
  public var isExpanded: Bool {
    subject.isExpandedBinding?.wrappedValue ?? subject.isExpanded
  }

  public func toggleIsExpanded() {
    subject.isExpandedBinding?.wrappedValue.toggle()
    subject.isExpanded.toggle()
  }
}
