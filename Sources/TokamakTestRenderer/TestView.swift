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
//  Created by Max Desiatov on 18/12/2018.
//

import TokamakCore

/// A class that `TestRenderer` uses as a target.
/// When rendering to a `TestView` instance it is possible
/// to examine its `subviews` and `props` for testing.
public final class TestView: Target {
  /// Subviews of this test view.
  public private(set) var subviews: [TestView]

  /// Parent `TestView` instance that owns this instance as a child
  private weak var parent: TestView?

  public var view: AnyView

  /** Initialize a new test view. */
  init<V: View>(_ view: V, _ subviews: [TestView] = []) {
    self.subviews = subviews
    self.view = AnyView(view)
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
