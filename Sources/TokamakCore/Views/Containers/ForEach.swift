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

/// A protocol that allows matching against type-erased `ForEach` at run time.
protocol ForEachProtocol: GroupView {
  var elementType: Any.Type { get }
  func element(at: Int) -> Any
}

/// A structure that computes `View`s from a collection of identified data.
///
/// Available when `Data` conforms to `RandomAccessCollection`,
/// `ID` conforms to `Hashable`, and `Content` conforms to `View`.
///
/// The children computed by `ForEach` are directly passed to the encapsulating `View`.
/// Similar to `TupleView` and `Group`.
///
///     HStack {
///       ForEach(0..<5) {
///         Text("\($0)")
///       }
///     }
public struct ForEach<Data, ID, Content>: _PrimitiveView where Data: RandomAccessCollection,
  ID: Hashable,
  Content: View
{
  let data: Data
  let id: KeyPath<Data.Element, ID>
  public let content: (Data.Element) -> Content

  public init(
    _ data: Data,
    id: KeyPath<Data.Element, ID>,
    @ViewBuilder content: @escaping (Data.Element) -> Content
  ) {
    self.data = data
    self.id = id
    self.content = content
  }

  public func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
    for element in data {
      visitor.visit(content(element))
    }
  }
}

extension ForEach: ForEachProtocol where Data.Index == Int {
  var elementType: Any.Type { Data.Element.self }
  func element(at index: Int) -> Any { data[index] }
}

public extension ForEach where Data.Element: Identifiable, ID == Data.Element.ID {
  init(
    _ data: Data,
    @ViewBuilder content: @escaping (Data.Element) -> Content
  ) {
    self.init(data, id: \.id, content: content)
  }
}

public extension ForEach where Data == Range<Int>, ID == Int {
  init(
    _ data: Range<Int>,
    @ViewBuilder content: @escaping (Data.Element) -> Content
  ) {
    self.data = data
    id = \.self
    self.content = content
  }
}

extension ForEach: ParentView {
  @_spi(TokamakCore)
  public var children: [AnyView] {
    data.map { AnyView(IDView(content($0), id: $0[keyPath: id])) }
  }
}

extension ForEach: GroupView {}

struct _IDKey: EnvironmentKey {
  static let defaultValue: AnyHashable? = nil
}

public extension EnvironmentValues {
  var _id: AnyHashable? {
    get {
      self[_IDKey.self]
    }
    set {
      self[_IDKey.self] = newValue
    }
  }
}

public protocol _AnyIDView {
  var anyId: AnyHashable { get }
  var anyContent: AnyView { get }
}

struct IDView<Content, ID>: View, _AnyIDView where Content: View, ID: Hashable {
  let content: Content
  let id: ID
  var anyId: AnyHashable { AnyHashable(id) }
  var anyContent: AnyView { AnyView(content) }

  init(_ content: Content, id: ID) {
    self.content = content
    self.id = id
  }

  var body: some View {
    content
      .environment(\._id, AnyHashable(id))
  }
}

public extension View {
  func id<ID>(_ id: ID) -> some View where ID: Hashable {
    IDView(self, id: id)
  }
}
