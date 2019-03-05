//
//  Scoll.swift
//  TokamakDemo
//
//  Created by Matvii Hodovaniuk on 2/28/19.
//  Copyright © 2019 Tokamak. All rights reserved.
//

import Tokamak

struct ScrollViewExample: LeafComponent {
  typealias Props = Null

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let refView = hooks.ref(type: UIView.self)
    let refStackView = hooks.ref(type: UIStackView.self)
    var labels: [AnyNode] = []
    for i in 1..<100 {
      labels.append(Label.node(.init(alignment: .center), "Text \(i)"))
    }

    hooks.effect() {
      guard let view = refView.value else { return }
      guard let stack = refStackView.value else { return }

      NSLayoutConstraint.activate([
        stack.heightAnchor.constraint(equalTo: view.heightAnchor),
        stack.widthAnchor.constraint(equalTo: view.widthAnchor),
        stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      ])

//      view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|", options: .alignAllCenterX, metrics: nil, views: ["scrollView": stack]))
//      view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|", options: .alignAllCenterX, metrics: nil, views: ["scrollView": stack]))
//
//      view.translatesAutoresizingMaskIntoConstraints = false
//      view.topAnchor.constraint(equalTo: stack.topAnchor).isActive = true
//      view.bottomAnchor.constraint(equalTo: stack.bottomAnchor).isActive = true
//      view.leadingAnchor.constraint(equalTo: stack.leadingAnchor).isActive = true
//      view.trailingAnchor.constraint(equalTo: stack.trailingAnchor).isActive = true

//      stack.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//      stack.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//      stack.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//      stack.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//      stack.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
//      stack.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }

    return View.node(
      .init(
        Style(
          [
            Width.equal(to: .parent),
            Height.equal(to: .parent),
            CenterX.equal(to: .parent),
          ]
        )
      ),
      ScrollView.node(
        .init(
          Style(
            [
//              Edges.equal(to: .parent),
//              Top.equal(to: .parent),
//              Trailing.equal(to: .parent),
//              Leading.equal(to: .parent),
              Width.equal(to: .parent),
              Height.equal(to: .parent),
              CenterX.equal(to: .parent),
            ]
          )
        ),
        StackView.node(
          .init([
//            Width.equal(to: .parent),
//            Height.equal(to: .parent),
            CenterX.equal(to: .parent),
          ],
                axis: .vertical),
          labels,
          ref: refStackView
        )
      ),
      ref: refView
    )
  }
}
