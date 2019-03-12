//
//  Image.swift
//  TokamakDemo
//
//  Created by Matvii Hodovaniuk on 2/18/19.
//  Copyright © 2019 Tokamak. Tokamak is available under the Apache 2.0
//  license. See the LICENSE file for more info.
//

import Tokamak

class ScrollDelegate: NSObject, UIScrollViewDelegate {
  var view: UIView?

  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return view
  }
}

struct ImageExample: LeafComponent {
  typealias Props = Null

  static func render(props _: Null, hooks: Hooks) -> AnyNode {
    let refScroll = hooks.ref(type: UIScrollView.self)
    let refImage = hooks.ref(type: UIImageView.self)
    let delegate = hooks.ref(ScrollDelegate())

    hooks.effect {
      guard let image = refImage.value else { return }
      guard let scroll = refScroll.value else { return }

      delegate.value.view = image
      scroll.delegate = delegate.value
    }

    return StackView.node(.init(
      Edges.equal(to: .safeArea),
      alignment: .center,
      axis: .vertical,
      distribution: .fill
    ), [
      Label.node("You can pan and zoom this image"),
      ScrollView.node(
        .init(
          Style(Width.equal(to: .parent)),
          maximumZoomScale: 2.0
        ),
        ImageView.node(.init(
          Style(Edges.equal(to: .parent)),
          image: Image(contentMode: .scaleAspectFit, name: "tokamak")
        ), ref: refImage),
        ref: refScroll
      ),
    ])
  }
}
