//
//  TextViewExample.swift
//  TokamakDemo-iOS
//
//  Created by Matvii Hodovaniuk on 3/27/19.
//  Copyright © 2019 Tokamak contributors. Tokamak is available under the
//  Apache 2.0 license. See the LICENSE file for more info.
//

import Tokamak

struct TextViewExample: LeafComponent {
  typealias Props = Null

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let alignment = hooks.state(0)

    let cases = TextAlignment.allCases

    return StackView.node(.init(
      Edges.equal(to: .safeArea),
      axis: .vertical,
      distribution: .fill,
      spacing: 10
    ), [
      SegmentedControl.node(
        .init(
          value: alignment.value,
          valueHandler: Handler { alignment.set($0) }
        ),
        cases.map { String(describing: $0) }
      ),
      TextView.node(.init(
        textAlignment: cases[alignment.value],
        value: exampleText
      )),
    ])
  }
}

let exampleText = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam rhoncus eros eros,\
id laoreet libero vehicula posuere. Etiam sit amet auctor mauris. In bibendum\
rhoncus tincidunt. Nulla facilisis sagittis tellus, vitae tempus elit interdum\
eget. Nam varius, velit ut condimentum suscipit, erat nunc molestie velit, a\
feugiat metus ante sit amet quam. Phasellus lobortis risus ac urna sagittis\
congue. Mauris vel eros lacus. Praesent sed feugiat felis, at ullamcorper\
massa. Integer vitae iaculis turpis, in dapibus nunc. Fusce maximus fermentum\
eros sed pellentesque. Mauris sed diam sed justo elementum iaculis non dignissi
erat.\

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam rhoncus eros eros,\
id laoreet libero vehicula posuere. Etiam sit amet auctor mauris. In bibendum\
rhoncus tincidunt. Nulla facilisis sagittis tellus, vitae tempus elit interdum\
eget. Nam varius, velit ut condimentum suscipit, erat nunc molestie velit, a\
feugiat metus ante sit amet quam. Phasellus lobortis risus ac urna sagittis\
congue. Mauris vel eros lacus. Praesent sed feugiat felis, at ullamcorper\
massa. Integer vitae iaculis turpis, in dapibus nunc. Fusce maximus fermentum\
eros sed pellentesque. Mauris sed diam sed justo elementum iaculis non dignissi
erat.\

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam rhoncus eros eros,\
id laoreet libero vehicula posuere. Etiam sit amet auctor mauris. In bibendum\
rhoncus tincidunt. Nulla facilisis sagittis tellus, vitae tempus elit interdum\
eget. Nam varius, velit ut condimentum suscipit, erat nunc molestie velit, a\
feugiat metus ante sit amet quam. Phasellus lobortis risus ac urna sagittis\
congue. Mauris vel eros lacus. Praesent sed feugiat felis, at ullamcorper\
massa. Integer vitae iaculis turpis, in dapibus nunc. Fusce maximus fermentum\
eros sed pellentesque. Mauris sed diam sed justo elementum iaculis non dignissi\
erat.
"""
