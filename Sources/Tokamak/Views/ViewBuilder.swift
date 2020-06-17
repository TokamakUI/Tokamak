//
//  Created by Max Desiatov on 08/04/2020.
//

public struct EmptyView: View {
  @inlinable public init() {}
}

// swiftlint:disable:next type_name
public enum _ConditionalContent<TrueBranch, FalseBranch>: View
  where TrueBranch: View, FalseBranch: View {
  case trueBranch(TrueBranch)
  case falseBranch(FalseBranch)
}

@_functionBuilder public struct ViewBuilder {
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
    .trueBranch(first)
  }

  public static func buildEither<TrueContent, FalseContent>(
    second: FalseContent
  ) -> _ConditionalContent<TrueContent, FalseContent> where TrueContent: View, FalseContent: View {
    .falseBranch(second)
  }
}

// swiftlint:disable line_length
// swiftlint:disable large_tuple
// swiftlint:disable function_parameter_count

extension ViewBuilder {
  public static func buildBlock<C0, C1>(_ c0: C0, _ c1: C1) -> TupleView<(C0, C1)> where C0: View, C1: View {
    TupleView(c0, c1)
  }
}

extension ViewBuilder {
  public static func buildBlock<C0, C1, C2>(_ c0: C0, _ c1: C1, _ c2: C2) -> TupleView<(C0, C1, C2)> where C0: View, C1: View, C2: View {
    TupleView(c0, c1, c2)
  }
}

extension ViewBuilder {
  public static func buildBlock<C0, C1, C2, C3>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3) -> TupleView<(C0, C1, C2, C3)> where C0: View, C1: View, C2: View, C3: View {
    TupleView(c0, c1, c2, c3)
  }
}

extension ViewBuilder {
  public static func buildBlock<C0, C1, C2, C3, C4>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4) -> TupleView<(C0, C1, C2, C3, C4)> where C0: View, C1: View, C2: View, C3: View, C4: View {
    TupleView(c0, c1, c2, c3, c4)
  }
}

extension ViewBuilder {
  public static func buildBlock<C0, C1, C2, C3, C4, C5>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5) -> TupleView<(C0, C1, C2, C3, C4, C5)> where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View {
    TupleView(c0, c1, c2, c3, c4, c5)
  }
}

extension ViewBuilder {
  public static func buildBlock<C0, C1, C2, C3, C4, C5, C6>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6) -> TupleView<(C0, C1, C2, C3, C4, C5, C6)> where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View {
    TupleView(c0, c1, c2, c3, c4, c5, c6)
  }
}

extension ViewBuilder {
  public static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7) -> TupleView<(C0, C1, C2, C3, C4, C5, C6, C7)> where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View {
    TupleView(c0, c1, c2, c3, c4, c5, c6, c7)
  }
}

extension ViewBuilder {
  public static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8) -> TupleView<(C0, C1, C2, C3, C4, C5, C6, C7, C8)> where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View {
    TupleView(c0, c1, c2, c3, c4, c5, c6, c7, c8)
  }
}

extension ViewBuilder {
  public static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9) -> TupleView<(C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)> where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View, C9: View {
    TupleView(c0, c1, c2, c3, c4, c5, c6, c7, c8, c9)
  }
}
