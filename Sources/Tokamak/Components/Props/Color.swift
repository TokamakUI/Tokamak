//
//  Color.swift
//  Tokamak
//
//  Created by Max Desiatov on 16/10/2018.
//

public struct Color: Equatable {
  public enum Space {
    case sRGB
    case displayP3
  }

  public let red: Double
  public let green: Double
  public let blue: Double
  public let alpha: Double
  public let space: Space

  public init(red: Double,
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
  public static var red = Color(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
  public static var green = Color(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
  public static var blue = Color(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
}

extension Color: ExpressibleByIntegerLiteral {
  /// Allows initializing value of `Color` type from hex values
  public init(integerLiteral bitMask: UInt32) {
    red = Double((bitMask & 0xFF0000) >> 16) / 255
    green = Double((bitMask & 0x00FF00) >> 8) / 255
    blue = Double(bitMask & 0x0000FF) / 255
    alpha = 1
    space = .sRGB
  }
}

extension Color {
  public init?(hex: String) {
    let cArray = Array(hex.replacingOccurrences(of: "#", with: ""))

    guard
      let red = Int(String(cArray[0...1]), radix: 16),
      let green = Int(String(cArray[2...3]), radix: 16),
      let blue = Int(String(cArray[4...5]), radix: 16)
    else {
      return nil
    }
    self.red = Double(red) / 255
    self.green = Double(green) / 255
    self.blue = Double(blue) / 255
    alpha = 1
    space = .sRGB
  }
}
