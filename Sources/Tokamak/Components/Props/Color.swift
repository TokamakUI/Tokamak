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
    let cString = hex.utf8CString

    // - 1 for the trailing null terminator
    let hexSize = cString.count - 1

    // If the first character is a '#', skip it
    var offset = cString.first == 0x23 ? 1 : 0

    // We only support 6 hexadecimal characters
    if hexSize - offset != 6 {
      return nil
    }

    func nextByte() -> Int8? {
      if
        let high = cString[offset].hexDecoded(),
        let low = cString[offset].hexDecoded()
      {
        // In this case, unchecked is still safe as it's between 0 and 6
        offset = offset &+ 2
        
        return (high << 4) &+ low
      }
  
      return nil
    }

    guard
      let red = nextByte(),
      let green = nextByte(),
      let blue = nextByte()
      else {
        return nil
    }

    self.red = Double(UInt8(bitPattern: red)) / 255
    self.green = Double(UInt8(bitPattern: green)) / 255
    self.blue = Double(UInt8(bitPattern: blue)) / 255
    self.alpha = 1
    self.space = .sRGB
  }
}

fileprivate let lowerRadix16table: [UInt8] = [0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46]
fileprivate let upperRadix16table: [UInt8] = [0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66]

fileprivate extension Int8 {
  func hexDecoded() -> Int8? {
    if self >= 0x30 && self <= 0x39 {
      return self &- 0x30
    } else if self >= 0x41 && self <= 0x46 {
      return self &- Int8.lowercasedOffset
    } else if self >= 0x61 && self <= 0x66 {
      return self &- Int8.uppercasedOffset
    }

    return nil
  }

  static let lowercasedOffset: Int8 = 0x41 &- 10
  static let uppercasedOffset: Int8 = 0x61 &- 10
}
