//
//  Diffable.swift
//  Gluon
//
//  Created by Max Desiatov on 28/11/2018.
//

protocol Diffable {
  func diffKeyPaths(other: Self) -> [PartialKeyPath<Self>]
}

struct Props: Equatable, Diffable {
  func diffKeyPaths(other: Props) -> [PartialKeyPath<Props>] {
    var result = [PartialKeyPath<Props>]()
    if height != other.height {
      result.append(\Props.height)
    }

    if width != other.width {
      result.append(\Props.width)
    }

    return result
  }

  var height: Double
  var width: Float

  static let kp = [\Props.height, \Props.width]
}
