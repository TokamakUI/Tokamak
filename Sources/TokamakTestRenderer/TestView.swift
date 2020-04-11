//
//  TestView.swift
//  TokamakTestRenderer
//
//  Created by Max Desiatov on 18/12/2018.
//

import Tokamak

/// A class that `TestRenderer` uses as a target.
/// When rendering to a `TestView` instance it is possible
/// to examine its `subviews` and `props` for testing.
public final class TestView: Target {
  /// Subviews of this test view.
  public private(set) var subviews: [TestView]

  /// Parent `TestView` instance that owns this instance as a child
  private weak var parent: TestView?

  /** Initialize a new test view.
   */
  init<V: View>(_ view: V,
                _ subviews: [TestView] = []) {
    self.subviews = subviews
    super.init(view: view)
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
