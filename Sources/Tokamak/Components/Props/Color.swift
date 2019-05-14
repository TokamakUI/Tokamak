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

private extension Int8 {
  func hexDecoded() -> Int8? {
    // If the character is between 0x30 and 0x39 it is a textual number
    // 0x30 is equal to the ASCII `0` and 0x30 is equal to `0x39`
    if self >= 0x30 && self <= 0x39 {
      // The binary representation of this character can be found by subtracting `0` in ASCII
      // This will then match `0` in binary. Which means `1` in ASCII matches `1` in binary
      return self &- 0x30
    } else if self >= 0x41 && self <= 0x46 {
      // This block executes if the integer is within the `a-z` lowercased ASCII range
      // Then uses the algorithm described below to find the correct representation
      return self &- Int8.lowercasedOffset
    } else if self >= 0x61 && self <= 0x66 {
      // This block executes if the integer is within the `A-Z` uppercased ASCII range
      // Then uses the algorithm described below to find the correct representation
      return self &- Int8.uppercasedOffset
    }

    return nil
  }

  // 'a' in hexadecimal is equal to `10` in decimal
  // So by subtracting `a` we get the lowercased character narrowed down to base10 offset by 10
  // By adding 10 (or reducing the subtraction size by 10) we represent this character correctly as base10
  static let lowercasedOffset: Int8 = 0x41 &- 10

  // The same as the lowercasedOffset, except for uppercased ASCII
  static let uppercasedOffset: Int8 = 0x61 &- 10
}
