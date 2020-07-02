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
protocol ForEachProtocol {
  var elementType: Any.Type { get }
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
public struct ForEach<Data, ID, Content>: View
  where Data: RandomAccessCollection, ID: Hashable, Content: View {
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

  public var body: Never {
    neverBody("ForEach")
  }
}

extension ForEach: ForEachProtocol {
  var elementType: Any.Type { Data.Element.self }
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
  public var children: [AnyView] {
    data.map { AnyView(content($0)) }
  }
}

extension ForEach: GroupView {}
