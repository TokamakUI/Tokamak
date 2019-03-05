//
//  Scroll.swift
//  TokamakDemo
//
//  Created by Matvii Hodovaniuk on 2/28/19.
//  Copyright © 2019 Tokamak. All rights reserved.
//

import Tokamak

class ScrollDelegate: NSObject, UIScrollViewDelegate {
  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    let a = "b"
    print(a)
//    let imageViewSize = imageView.frame.size
//    let scrollViewSize = scrollView.bounds.size
//
//    let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
//    let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
//
//    scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
  }
}

struct ScrollViewExample: LeafComponent {
  typealias Props = Null

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let refView = hooks.ref(type: UIView.self)
    let refScrollView = hooks.ref(type: UIScrollView.self)
    let refImage = hooks.ref(type: UIImageView.self)
    let delegate = hooks.ref(ScrollDelegate())
    let n = hooks.state(0)

    hooks.effect(n) {
      guard let image = refImage.value else { return }
      guard let scroll = refScrollView.value else { return }

      scroll.delegate = delegate.value

      let imageViewSize = image.bounds.size
      let scrollViewSize = scroll.bounds.size
      let widthScale = scrollViewSize.width / imageViewSize.width
      let heightScale = scrollViewSize.height / imageViewSize.height

      scroll.minimumZoomScale = min(widthScale, heightScale)
      scroll.zoomScale = 1.0

      let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
      let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0

      scroll.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }

    return View.node(
      .init(Style(Edges.equal(to: .safeArea))),
      ScrollView.node(
        .init(Style(Edges.equal(to: .parent))),
        ImageView.node(
          .init(
            Style(Edges.equal(to: .parent), contentMode: .scaleAspectFit),
            image: Image(name: "tokamak")
          ),
          ref: refImage
        ),
        ref: refScrollView
      ),
      ref: refView
    )
//    return View.node(
//      .init(Style(Edges.equal(to: .safeArea))),
//      ScrollView.node(
//        .init(Style(Edges.equal(to: .parent))),
//        StackView.node(
//          .init(
//            Edges.equal(to: .parent),
//            axis: .vertical,
//            distribution: .fill
//          ),
//          (1..<100).map { Label.node("Text \($0)") }
//        )
//      )
//    )
  }
}
