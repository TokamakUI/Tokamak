//
//  Created by Max Desiatov on 07/04/2020.
//

public protocol View {
  associatedtype Body: View

  var body: Self.Body { get }
}

extension Never: View {
  public typealias Body = Never
}

public extension View where Body == Never {
  var body: Never { fatalError() }
}

/// A `View` type that renders with subviews, usually specified in the `Content` type argument
protocol ParentView {
  var children: [AnyView] { get }
}

/// A `View` type that is not rendered, but "flattened" rendering all its children instead.
protocol GroupView: ParentView {}
