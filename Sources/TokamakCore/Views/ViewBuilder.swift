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
//  Created by Max Desiatov on 08/04/2020.
//

/// A `View` with no effect on rendering.
public struct EmptyView: _PrimitiveView {
  @inlinable
  public init() {}
}

// swiftlint:disable:next type_name
public struct _ConditionalContent<TrueContent, FalseContent>: _PrimitiveView
  where TrueContent: View, FalseContent: View
{
  enum Storage {
    case trueContent(TrueContent)
    case falseContent(FalseContent)
  }

  let storage: Storage
}

extension _ConditionalContent: GroupView {
  public var children: [AnyView] {
    switch storage {
    case let .trueContent(view):
      return [AnyView(view)]
    case let .falseContent(view):
      return [AnyView(view)]
    }
  }
}

extension Optional: View where Wrapped: View {
  public var body: some View {
    if let view = self {
      view
    } else {
      EmptyView()
    }
  }
}

protocol AnyOptional {
  var value: Any? { get }
}

extension Optional: AnyOptional {
  var value: Any? {
    switch self {
    case let .some(value): return value
    case .none: return nil
    }
  }
}

@resultBuilder
public enum ViewBuilder {
  public static func buildBlock() -> EmptyView { EmptyView() }

  public static func buildBlock<Content>(
    _ content: Content
  ) -> Content where Content: View {
    content
  }

  public static func buildIf<Content>(_ content: Content?) -> Content? where Content: View {
    content
  }

  public static func buildEither<TrueContent, FalseContent>(
    first: TrueContent
  ) -> _ConditionalContent<TrueContent, FalseContent> where TrueContent: View, FalseContent: View {
    .init(storage: .trueContent(first))
  }

  public static func buildEither<TrueContent, FalseContent>(
    second: FalseContent
  ) -> _ConditionalContent<TrueContent, FalseContent> where TrueContent: View, FalseContent: View {
    .init(storage: .falseContent(second))
  }
}

// swiftlint:disable large_tuple
// swiftlint:disable function_parameter_count

public extension ViewBuilder {
  static func buildBlock<C0, C1>(_ c0: C0, _ c1: C1) -> TupleView<(C0, C1)>
    where C0: View, C1: View
  {
    TupleView(c0, c1)
  }
}

public extension ViewBuilder {
  static func buildBlock<C0, C1, C2>(
    _ c0: C0,
    _ c1: C1,
    _ c2: C2
  ) -> TupleView<(C0, C1, C2)> where C0: View, C1: View, C2: View {
    TupleView(c0, c1, c2)
  }
}

public extension ViewBuilder {
  static func buildBlock<C0, C1, C2, C3>(
    _ c0: C0,
    _ c1: C1,
    _ c2: C2,
    _ c3: C3
  ) -> TupleView<(C0, C1, C2, C3)> where C0: View, C1: View, C2: View, C3: View {
    TupleView(c0, c1, c2, c3)
  }
}

public extension ViewBuilder {
  static func buildBlock<C0, C1, C2, C3, C4>(
    _ c0: C0,
    _ c1: C1,
    _ c2: C2,
    _ c3: C3,
    _ c4: C4
  ) -> TupleView<(C0, C1, C2, C3, C4)> where C0: View, C1: View, C2: View, C3: View, C4: View {
    TupleView(c0, c1, c2, c3, c4)
  }
}

public extension ViewBuilder {
  static func buildBlock<C0, C1, C2, C3, C4, C5>(
    _ c0: C0,
    _ c1: C1,
    _ c2: C2,
    _ c3: C3,
    _ c4: C4,
    _ c5: C5
  ) -> TupleView<(C0, C1, C2, C3, C4, C5)>
    where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View
  {
    TupleView(c0, c1, c2, c3, c4, c5)
  }
}

public extension ViewBuilder {
  static func buildBlock<C0, C1, C2, C3, C4, C5, C6>(
    _ c0: C0,
    _ c1: C1,
    _ c2: C2,
    _ c3: C3,
    _ c4: C4,
    _ c5: C5,
    _ c6: C6
  ) -> TupleView<(C0, C1, C2, C3, C4, C5, C6)>
    where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View
  {
    TupleView(c0, c1, c2, c3, c4, c5, c6)
  }
}

public extension ViewBuilder {
  static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7>(
    _ c0: C0,
    _ c1: C1,
    _ c2: C2,
    _ c3: C3,
    _ c4: C4,
    _ c5: C5,
    _ c6: C6,
    _ c7: C7
  ) -> TupleView<(C0, C1, C2, C3, C4, C5, C6, C7)>
    where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View
  {
    TupleView(c0, c1, c2, c3, c4, c5, c6, c7)
  }
}

public extension ViewBuilder {
  static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8>(
    _ c0: C0,
    _ c1: C1,
    _ c2: C2,
    _ c3: C3,
    _ c4: C4,
    _ c5: C5,
    _ c6: C6,
    _ c7: C7,
    _ c8: C8
  ) -> TupleView<(C0, C1, C2, C3, C4, C5, C6, C7, C8)>
    where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View
  {
    TupleView(c0, c1, c2, c3, c4, c5, c6, c7, c8)
  }
}

public extension ViewBuilder {
  static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>(
    _ c0: C0,
    _ c1: C1,
    _ c2: C2,
    _ c3: C3,
    _ c4: C4,
    _ c5: C5,
    _ c6: C6,
    _ c7: C7,
    _ c8: C8,
    _ c9: C9
  ) -> TupleView<(C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>
    where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View,
    C9: View
  {
    TupleView(c0, c1, c2, c3, c4, c5, c6, c7, c8, c9)
  }
}
