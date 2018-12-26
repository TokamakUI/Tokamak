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
  
  /** Initialize a new test view.
    - parameter props: base component props to initialize the test view
  */
  init(props: AnyEquatable) {
    self.props = props
  }
  
  /** Add a subview to this test view.
    - parameter subview: the subview to be added to this view.
  */
  func add(subview: TestView) {
    subviews.append(subview)
  }
  
  /** Remove a subview from this test view.
    - parameter subview: the subview to be removed from this view.
  */
  func remove(subview: TestView) {
    subviews.removeAll { $0 === subview }
  }
}
