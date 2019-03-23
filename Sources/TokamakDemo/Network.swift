//
//  Network.swift
//  TokamakDemo
//
//  Created by Max Desiatov on 21/03/2019.
//  Copyright © 2019 Tokamak contributors. Tokamak is available under the
//  Apache 2.0 license. See the LICENSE file for more info.
//

import Alamofire
import Tokamak

public struct Network: LeafComponent {
  public typealias Props = Null

  enum State {
    case initial
    case loading
    case finished(Result<String>)
  }

  public static func render(props: Null, hooks: Hooks) -> AnyNode {
    let state = hooks.state(State.initial)
    let style = Style(Edges.equal(to: .safeArea, inset: 10))

    switch state.value {
    case .initial:
      return Button.node(.init(
        style,
        onPress: Handler {
          state.set(.loading)
          Alamofire.request("https://httpbin.org/drip").responseString {
            state.set(.finished($0.result))
          }
        },
        text: "Load"
      ))
    case .loading:
      return View.node(
        .init(Style(
          [Size.equal(to: 100), Center.equal(to: .parent)],
          backgroundColor: .black,
          cornerRadius: 10
        )),
        Throbber.node(
          .init(
            style,
            isAnimating: true,
            variety: .whiteLarge
          )
        )
      )
    case let .finished(.success(value)):
      return Label.node(.init(
        style,
        alignment: .center,
        lineBreakMode: .wordWrap,
        numberOfLines: 0,
        text: value
      ))
    case let .finished(.failure(error)):
      return Label.node(.init(
        style,
        alignment: .center,
        text: error.localizedDescription
      ))
    }
  }
}
