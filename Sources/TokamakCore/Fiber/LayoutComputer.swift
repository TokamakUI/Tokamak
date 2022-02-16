//
//  File.swift
//
//
//  Created by Carson Katri on 2/16/22.
//

import Foundation

/// A type that is able to propose sizes for its children.
protocol LayoutComputer {
  /// Will be called every time a child is evaluated.
  /// The calls will always be in order, and no more than one call will be made per child.
  func proposeSize<V: View>(for child: V, at index: Int) -> CGSize
}
