//
//  ViewController.swift
//  TokamakDemoMac
//
//  Created by Max Desiatov on 10/03/2019.
//  Copyright © 2019 Tokamak. Tokamak is available under the Apache 2.0
//  license. See the LICENSE file for more info.
//

import Tokamak
import TokamakAppKit
import TokamakDemo

final class ViewController: TokamakViewController {
  override var node: AnyNode {
    return View.node(
      .init(Style([
        Edges.equal(to: .parent),
        Width.equal(to: 200),
        Height.equal(to: 100),
      ])),
      Counter.node(.init(countFrom: 1))
    )
  }
}
