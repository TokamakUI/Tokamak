// Copyright 2020-2021 Tokamak contributors
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

/// A type-erased view.
public struct AnyView: _PrimitiveView {
  /// The type of the underlying `view`.
  let type: Any.Type

  /** The name of the unapplied generic type of the underlying `view`. `Button<Text>` and
   `Button<Image>` types are different, but when reconciling the tree of mounted views
   they are treated the same, thus the `Button` part of the type (the type constructor)
   is stored in this property.
   */
  let typeConstructorName: String

  /// The actual `View` value wrapped within this `AnyView`.
  var view: Any

  /** Type-erased `body` of the underlying `view`. Needs to take a fresh version of `view` as an
   argument, otherwise it captures an old value of the `body` property.
   */
  let bodyClosure: (Any) -> AnyView

  /** The type of the `body` of the underlying `view`. Used to cast the result of the applied
   `bodyClosure` property.
   */
  let bodyType: Any.Type

  let visitChildren: (ViewVisitor, Any) -> ()

  public init<V>(_ view: V) where V: View {
    if let anyView = view as? AnyView {
      self = anyView
    } else {
      type = V.self

      typeConstructorName = TokamakCore.typeConstructorName(type)

      bodyType = V.Body.self
      self.view = view
      // swiftlint:disable:next force_cast
      bodyClosure = { AnyView(($0 as! V).body) }
      // swiftlint:disable:next force_cast
      visitChildren = { $0.visit($1 as! V) }
    }
  }

  public func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
    visitChildren(visitor, view)
  }
}

public func mapAnyView<T, V>(_ anyView: AnyView, transform: (V) -> T) -> T? {
  guard let view = anyView.view as? V else { return nil }

  return transform(view)
}

extension AnyView: ParentView {
  @_spi(TokamakCore)
  public var children: [AnyView] {
    (view as? ParentView)?.children ?? []
  }
}

public struct _AnyViewProxy {
  public var subject: AnyView

  public init(_ subject: AnyView) { self.subject = subject }

  public var type: Any.Type { subject.type }
  public var view: Any { subject.view }
}
