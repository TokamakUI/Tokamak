//
//  File.swift
//
//
//  Created by Carson Katri on 2/16/22.
//

import Foundation

struct LayoutContext {
  let children: [Child]

  struct Child {
    let index: Int
    let dimensions: ViewDimensions
  }
}

/// A type that is able to propose sizes for its children.
protocol LayoutComputer: AnyObject {
  /// Will be called every time a child is evaluated.
  /// The calls will always be in order, and no more than one call will be made per child.
  func proposeSize<V: View>(for child: V, at index: Int) -> CGSize
  /// The child responds with their size and we place them relative to our origin.
  func position(_ child: LayoutContext.Child, in context: LayoutContext) -> CGPoint
  /// Request a size for ourself from our parent.
  func requestSize(in context: LayoutContext) -> CGSize
}

/// A `LayoutComputer` that takes the size of its children.
final class ShrinkWrapLayout: LayoutComputer {
  let proposedSize: CGSize
  var childSize: CGSize?

  init(proposedSize: CGSize) {
    self.proposedSize = proposedSize
  }

  func proposeSize<V>(for child: V, at index: Int) -> CGSize where V: View {
    proposedSize
  }

  func position(_ child: LayoutContext.Child, in context: LayoutContext) -> CGPoint {
    childSize = child.dimensions.size
    return .zero
  }

  func requestSize(in context: LayoutContext) -> CGSize {
    childSize ?? .zero
  }
}

/// A `LayoutComputer` that fills its parent.
final class FlexLayout: LayoutComputer {
  let proposedSize: CGSize

  init(proposedSize: CGSize) {
    self.proposedSize = proposedSize
  }

  func proposeSize<V>(for child: V, at index: Int) -> CGSize where V: View {
    proposedSize
  }

  func position(_ child: LayoutContext.Child, in context: LayoutContext) -> CGPoint {
    .zero
  }

  func requestSize(in context: LayoutContext) -> CGSize {
    proposedSize
  }
}

extension VStack {
  private final class VStackLayout: LayoutComputer {
    let proposedSize: CGSize
    let alignment: HorizontalAlignment

    init(proposedSize: CGSize, alignment: HorizontalAlignment) {
      self.proposedSize = proposedSize
      self.alignment = alignment
    }

    func proposeSize<V>(for child: V, at index: Int) -> CGSize where V: View {
      // FIXME: Only propose the remaining space after each child is processed.
      proposedSize
    }

    func position(_ child: LayoutContext.Child, in context: LayoutContext) -> CGPoint {
      let maxWidth = context.children.max(by: { $0.dimensions.width < $1.dimensions.width })
      return .init(
        x: (maxWidth?.dimensions[alignment] ?? .zero) - child.dimensions[alignment],
        y: context.children[0..<child.index].reduce(0) { $0 + $1.dimensions.height }
      )
    }

    func requestSize(in context: LayoutContext) -> CGSize {
      .init(
        width: context.children.max(by: { $0.dimensions.width < $1.dimensions.width })?.dimensions
          .width
          ?? .zero,
        height: context.children.reduce(0) { $0 + $1.dimensions.height }
      )
    }
  }

  public static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs {
    .init(
      inputs: inputs,
      layoutComputer: VStackLayout(
        proposedSize: inputs.proposedSize,
        alignment: inputs.view.alignment
      )
    )
  }
}

extension HStack {
  private final class HStackLayout: LayoutComputer {
    let proposedSize: CGSize
    let alignment: VerticalAlignment

    init(proposedSize: CGSize, alignment: VerticalAlignment) {
      self.proposedSize = proposedSize
      self.alignment = alignment
    }

    func proposeSize<V>(for child: V, at index: Int) -> CGSize where V: View {
      // FIXME: Only propose the remaining space after each child is processed.
      proposedSize
    }

    func position(_ child: LayoutContext.Child, in context: LayoutContext) -> CGPoint {
      let maxHeight = context.children.max(by: { $0.dimensions.height < $1.dimensions.height })
      return .init(
        x: context.children[0..<child.index].reduce(0) { $0 + $1.dimensions.width },
        y: (maxHeight?.dimensions[alignment] ?? .zero) - child.dimensions[alignment]
      )
    }

    func requestSize(in context: LayoutContext) -> CGSize {
      .init(
        width: context.children.reduce(0) { $0 + $1.dimensions.width },
        height: context.children.max(by: { $0.dimensions.height < $1.dimensions.height })?
          .dimensions.height
          ?? .zero
      )
    }
  }

  public static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs {
    .init(
      inputs: inputs,
      layoutComputer: HStackLayout(
        proposedSize: inputs.proposedSize,
        alignment: inputs.view.alignment
      )
    )
  }
}

/// Measures the bounds of the `Text` with modifiers and wrapping inside the `proposedSize`.
final class TextLayoutComputer: LayoutComputer {
  let text: Text
  let proposedSize: CGSize

  init(text: Text, proposedSize: CGSize) {
    self.text = text
    self.proposedSize = proposedSize
  }

  func proposeSize<V>(for child: V, at index: Int) -> CGSize where V: View {
    fatalError("Text views cannot have children.")
  }

  func position(_ child: LayoutContext.Child, in context: LayoutContext) -> CGPoint {
    fatalError("Text views cannot have children.")
  }

  func requestSize(in context: LayoutContext) -> CGSize {
    // FIXME: Renderer-provided text measurement.
    .init(width: 100, height: 50)
  }
}

public extension Text {
  static func _makeView(_ inputs: ViewInputs<Text>) -> ViewOutputs {
    .init(
      inputs: inputs,
      layoutComputer: TextLayoutComputer(text: inputs.view, proposedSize: inputs.proposedSize)
    )
  }
}
