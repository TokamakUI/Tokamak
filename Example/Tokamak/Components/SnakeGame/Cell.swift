//
//  Cell.swift
//  TokamakDemo
//
//  Created by Matvii Hodovaniuk on 2/25/19.
//  Copyright © 2019 Tokamak. All rights reserved.
//

import Tokamak

struct Cell: PureLeafComponent {
  struct Props: Equatable {
    let color: Color
    let size: Double
    let location: Point
  }

  static func render(props: Props) -> AnyNode {
    let location = props.location
    let size = props.size
    return View.node(
      .init(
        Style(
          Rectangle(
            Point(x: size * location.x, y: size * location.y),
            Size(width: size, height: size)
          ),
          backgroundColor: props.color
        )
      )
    )
  }
}
