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

public struct Group<Content> {
  let content: Content
  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }
}

extension Group: _PrimitiveView, View where Content: View {
  public func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
    visitor.visit(content)
  }
}

extension Group: ParentView where Content: View {
  @_spi(TokamakCore)
  public var children: [AnyView] { (content as? ParentView)?.children ?? [AnyView(content)] }
}

extension Group: GroupView where Content: View {}
