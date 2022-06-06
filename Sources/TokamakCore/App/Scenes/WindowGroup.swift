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
//  Created by Carson Katri on 7/16/20.
//

public struct WindowGroup<Content>: Scene, TitledScene where Content: View {
  public let id: String
  public let title: Text?
  public let content: Content
  var anyContent: AnyView { AnyView(content) }

  public init(id: String, @ViewBuilder content: () -> Content) {
    self.id = id
    title = nil
    self.content = content()
  }

  @_disfavoredOverload
  public init(_ title: Text, id: String, @ViewBuilder content: () -> Content) {
    self.id = id
    self.title = title
    self.content = content()
  }

  @_disfavoredOverload
  public init<S>(_ title: S, id: String, @ViewBuilder content: () -> Content)
    where S: StringProtocol
  {
    self.id = id
    self.title = Text(title)
    self.content = content()
  }

  public init(@ViewBuilder content: () -> Content) {
    id = ""
    title = nil
    self.content = content()
  }

  @_disfavoredOverload
  public init(_ title: Text, @ViewBuilder content: () -> Content) {
    id = ""
    self.title = title
    self.content = content()
  }

  @_disfavoredOverload
  public init<S>(_ title: S, @ViewBuilder content: () -> Content) where S: StringProtocol {
    id = ""
    self.title = Text(title)
    self.content = content()
  }

  @_spi(TokamakCore)
  public var body: Never {
    neverScene("WindowGroup")
  }

  // TODO: Implement LocalizedStringKey
//  public init(_ titleKey: LocalizedStringKey,
//              id: String,
//              @ViewBuilder content: () -> Content)
//  public init(_ titleKey: LocalizedStringKey,
//              @ViewBuilder content: () -> Content) {
//  }

  public func _visitChildren<V>(_ visitor: V) where V: SceneVisitor {
    visitor.visit(content)
  }
}
