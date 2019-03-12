//
//  CollectionExample.swift
//  TokamakDemo
//
//  Created by Matvii Hodovaniuk on 3/7/19.
//  Copyright © 2019 Tokamak. All rights reserved.
//

import Tokamak

enum ElementaryParticles: String, CaseIterable {
  case up
  case down
  case charm
  case strange
  case top
  case bottom
  case gluon
  case photon
  case higs
  case electron
  case muon
  case tau
  case electronNeutrino = "Electron Neutrino"
  case muonNeutrino = "Muon Neutrino"
  case tauNeutrino = "Tau Neutrino"
  case zBoson = "Z Boson"
  case wBoson = "W Boson"
}

extension ElementaryParticles: CustomStringConvertible {
  var description: String { return rawValue.localizedCapitalized }
}

private struct Cells: SimpleCellProvider {
  static func cell(
    props: Null,
    item: ElementaryParticles,
    path: CellPath
  ) -> AnyNode {
    return Label.node(.init(
      Style(
        [CenterY.equal(to: .parent),
         Height.equal(to: 44),
         Leading.equal(to: .parent),
         Trailing.equal(to: .parent)]
      ),
      text: "\(item.description)"
    ))
  }

  typealias Props = Null

  typealias Model = [[ElementaryParticles]]
}

struct CollectionExample: PureLeafComponent {
  typealias Props = Null

  static func render(props: Props) -> AnyNode {
    return CollectionView<Cells>.node(.init(
      Style(
        Edges.equal(to: .parent, inset: 20),
        backgroundColor: .white
      ),
      model: [ElementaryParticles.allCases]
    ))
  }
}
