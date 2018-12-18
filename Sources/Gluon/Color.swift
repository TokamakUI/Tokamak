//
//  Color.swift
//  Gluon
//
//  Created by Max Desiatov on 16/10/2018.
//

public struct Color: Equatable {
  enum Space {
    case sRGB
    case displayP3
  }

  let red: Double
  let green: Double
  let blue: Double
  let alpha: Double
  let space: Space

  init(red: Double,
       green: Double,
       blue: Double,
       alpha: Double,
       space: Space = .sRGB) {
    self.red = red
    self.green = green
    self.blue = blue
    self.alpha = alpha
    self.space = space
  }

  public static var white = Color(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
  public static var black = Color(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
}
