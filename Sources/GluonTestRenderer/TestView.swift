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
  
  /// Initialize a new test view.
  init(props: AnyEquatable) {
    self.props = props
  }
  
  func add(subview: TestView) {
    subviews.append(subview)
  }
}
