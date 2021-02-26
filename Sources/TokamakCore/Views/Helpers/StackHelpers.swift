//
//  HStack.swift
//  SwiftUILayout
//
//  Created by Chris Eidhof on 03.11.20.
//
//  NOTE: This file is a product of objc.io. Please see LICENSE.md
//  From https://github.com/objcio/S01E232-swiftui-layout-explained-hstack-with-flexible-views

import Foundation

class StackHelper {
  let axis: Axis

  init(axis: Axis) {
    self.axis = axis
  }
//  var alignment: VerticalAlignment = .center
//  let spacing: CGFloat? = 0

  public func layout<T>(size: CGSize, hostView: MountedHostView<T>) {
    print("LAYOUT", size)

    guard let context = hostView.target?.context else { return }
    let children = hostView.getChildren()
    let sizes = _layout(proposed: ProposedSize(size), children: children)
    var currentAlongAxis: CGFloat = 0
    for idx in children.indices {
      let childSize = sizes[idx]
      let child = children[idx]
      context.push()
      context.translate(x: axis == .horizontal ? currentAlongAxis : 0, y: axis == .vertical ? currentAlongAxis : 0)
      guard let childView = mapAnyView(
        child.view,
        transform: { (view: View) in view }
      ) else {
        continue
      }
      childView._layout(size: childSize, hostView: child)
      context.pop()
      currentAlongAxis += axis == .horizontal ? childSize.width : childSize.height
    }
  }

  public func size<T>(for proposedSize: ProposedSize, hostView: MountedHostView<T>) -> CGSize {
    print("PROPOSED", proposedSize)
    let children = hostView.getChildren()
    let sizes = _layout(proposed: proposedSize, children: children)
    let width: CGFloat
    let height: CGFloat
    if axis == .horizontal {
      width = sizes.map(\.width).reduce(0, +)
      height = sizes.map(\.height).reduce(0, max)
    } else {
      width = sizes.map(\.width).reduce(0, max)
      height = sizes.map(\.height).reduce(0, +)
    }
    print("SIZE", width, height)
    return CGSize(width: width, height: height)
  }

  private func _layout<T>(proposed: ProposedSize, children: [MountedHostView<T>]) -> [CGSize] {
    var remainingAlongAxis = axis == .horizontal ? proposed.width! : proposed.height! // TODO
    var remaining = children
    var sizes: [CGSize] = []
    while !remaining.isEmpty {
      let alongAxis = remainingAlongAxis / CGFloat(remaining.count)
      let child = remaining.removeFirst()
      guard let childView = mapAnyView(
        child.view,
        transform: { (view: View) in view }
      ) else {
        continue
      }

      let size = childView._size(for: ProposedSize(width: axis == .horizontal ? alongAxis : proposed.width, height: axis == .vertical ? alongAxis : proposed.height), hostView: child)
      sizes.append(size)
      remainingAlongAxis -= axis == .horizontal ? size.width : size.height
      // todo check what happens when remaining width < 0
    }
    return sizes
  }
}
