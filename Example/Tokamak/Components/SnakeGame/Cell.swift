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
    let size: Int
    let location: Point
  }

  static func render(props: Props) -> AnyNode {
    let location = props.location
    let size = props.size
    return View.node(
      .init(
        Style(
          Rectangle(
            Point(x: Double(size) * location.x, y: Double(size) * location.y),
            Size(width: Double(size), height: Double(size))
          ),
          backgroundColor: props.color
        )
      )
    )
  }
}
