//
//  TestView.swift
//  GluonTestRenderer
//
//  Created by Max Desiatov on 18/12/2018.
//

import Gluon

/// A class that `TestRenderer` uses as a target.
/// When rendering to a `TestView` instance it is possible
/// to examine its `subviews` and `props` for testing.
public final class TestView {
  /// Subviews of this test view.
  public private(set) var subviews = [TestView]()

  /// Props assigned to this test view.
  public internal(set) var props: AnyEquatable

  /// Children assigned to this test view.
  public internal(set) var children: AnyEquatable

  /// Component that renders to this test view as a target
  public let component: AnyHostComponent.Type

  /// Parent `TestView` instance that owns this instance as a child
  private weak var parent: TestView?

  /** Initialize a new test view.
   - parameter props: base component props to initialize the test view
   */
  init(component: AnyHostComponent.Type,
       props: AnyEquatable,
       children: AnyEquatable) {
    self.component = component
    self.props = props
    self.children = children
  }

  /** Add a subview to this test view.
   - parameter subview: the subview to be added to this view.
   */
  func add(subview: TestView) {
    subviews.append(subview)
    subview.parent = self
  }

  /** Remove a subview from this test view.
   - parameter subview: the subview to be removed from this view.
   */
  func remove(subview: TestView) {
    subviews.removeAll { $0 === subview }
  }

  /// Remove this test view from a superview if there is any
  func removeFromSuperview() {
    parent?.remove(subview: self)
  }
}
