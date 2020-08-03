// Copyright 2018-2020 Tokamak contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Created by Max Desiatov on 16/10/2018.
//

public struct Color: Hashable, Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    var lightEnv = EnvironmentValues()
    lightEnv.colorScheme = .light
    var darkEnv = EnvironmentValues()
    darkEnv.colorScheme = .dark
    return lhs._evaluate(lightEnv) == rhs._evaluate(lightEnv) &&
      lhs._evaluate(darkEnv) == rhs._evaluate(darkEnv)
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(evaluator(EnvironmentValues()))
  }

  public enum RGBColorSpace {
    case sRGB
    case sRGBLinear
    case displayP3
  }

  public struct _RGBA: Hashable, Equatable {
    public let red: Double
    public let green: Double
    public let blue: Double
    public let opacity: Double
    public let space: RGBColorSpace
  }

  let evaluator: (EnvironmentValues) -> _RGBA

  private init(_ evaluator: @escaping (EnvironmentValues) -> _RGBA) {
    self.evaluator = evaluator
  }

  public init(_ colorSpace: RGBColorSpace = .sRGB,
              red: Double,
              green: Double,
              blue: Double,
              opacity: Double = 1) {
    self.init { _ in
      _RGBA(red: red,
            green: green,
            blue: blue,
            opacity: opacity,
            space: colorSpace)
    }
  }

  public init(_ colorSpace: RGBColorSpace = .sRGB,
              white: Double,
              opacity: Double = 1) {
    self.init(colorSpace,
              red: white,
              green: white,
              blue: white,
              opacity: opacity)
  }

  // Source for the formula:
  // https://en.wikipedia.org/wiki/HSL_and_HSV#HSL_to_RGB_alternative
  public init(hue: Double,
              saturation: Double,
              brightness: Double,
              opacity: Double = 1) {
    let a = saturation * min(brightness / 2, 1 - (brightness / 2))
    let f = { (n: Int) -> Double in
      let k = Double((n + Int(hue * 12)) % 12)
      return brightness - (a * max(-1, min(k - 3, 9 - k, 1)))
    }
    self.init(.sRGB,
              red: f(0),
              green: f(8),
              blue: f(4),
              opacity: opacity)
  }

  /// Create a `Color` dependent on the current `ColorScheme`.
  public static func _withScheme(_ evaluator: @escaping (ColorScheme) -> Self) -> Self {
    .init {
      evaluator($0.colorScheme)._evaluate($0)
    }
  }

  public func _evaluate(_ environment: EnvironmentValues) -> _RGBA {
    evaluator(environment)
  }
}

extension Color {
  public static let clear: Self = .init(red: 0, green: 0, blue: 0, opacity: 0)
  public static let black: Self = .init(white: 0)
  public static let white: Self = .init(white: 1)
  public static let gray: Self = .init(white: 0.6)
  public static let red: Self = .init(red: 1.00, green: 0.27, blue: 0.23)
  public static let green: Self = .init(red: 0.20, green: 0.84, blue: 0.29)
  public static let blue: Self = .init(red: 0.04, green: 0.52, blue: 1.00)
  public static let orange: Self = .init(red: 1.00, green: 0.62, blue: 0.04)
  public static let yellow: Self = .init(red: 1.00, green: 0.84, blue: 0.04)
  public static let pink: Self = .init(red: 1.00, green: 0.22, blue: 0.37)
  public static let purple: Self = .init(red: 0.75, green: 0.36, blue: 0.95)
  public static let primary: Self = .init {
    switch $0.colorScheme {
    case .light:
      return .init(red: 0,
                   green: 0,
                   blue: 0,
                   opacity: 1,
                   space: .sRGB)
    case .dark:
      return .init(red: 1,
                   green: 1,
                   blue: 1,
                   opacity: 1,
                   space: .sRGB)
    }
  }

  public static let secondary: Self = .gray
  public static let accentColor: Self = .init {
    ($0.accentColor ?? Self.blue)._evaluate($0)
  }

  public init(_ color: UIColor) {
    self = color.color
  }
}

extension Color: ExpressibleByIntegerLiteral {
  /// Allows initializing value of `Color` type from hex values
  public init(integerLiteral bitMask: UInt32) {
    self.init(.sRGB,
              red: Double((bitMask & 0xFF0000) >> 16) / 255,
              green: Double((bitMask & 0x00FF00) >> 8) / 255,
              blue: Double(bitMask & 0x0000FF) / 255,
              opacity: 1)
  }
}

extension Color {
  public init?(hex: String) {
    let cArray = Array(hex.count > 6 ? String(hex.dropFirst()) : hex)

    guard cArray.count == 6 else { return nil }

    guard
      let red = Int(String(cArray[0...1]), radix: 16),
      let green = Int(String(cArray[2...3]), radix: 16),
      let blue = Int(String(cArray[4...5]), radix: 16)
    else {
      return nil
    }
    self.init(.sRGB,
              red: Double(red) / 255,
              green: Double(green) / 255,
              blue: Double(blue) / 255,
              opacity: 1)
  }
}

extension Color: ShapeStyle {}
extension Color: View {
  public var body: some View {
    _ShapeView(shape: Rectangle(), style: self)
  }
}

struct AccentColorKey: EnvironmentKey {
  static let defaultValue: Color? = nil
}

public extension EnvironmentValues {
  var accentColor: Color? {
    get {
      self[AccentColorKey.self]
    }
    set {
      self[AccentColorKey.self] = newValue
    }
  }
}

extension View {
  public func accentColor(_ accentColor: Color?) -> some View {
    environment(\.accentColor, accentColor)
  }
}

struct ForegroundColorKey: EnvironmentKey {
  static let defaultValue: Color? = nil
}

public extension EnvironmentValues {
  var foregroundColor: Color? {
    get {
      self[ForegroundColorKey.self]
    }
    set {
      self[ForegroundColorKey.self] = newValue
    }
  }
}

extension View {
  public func foregroundColor(_ color: Color?) -> some View {
    environment(\.foregroundColor, color)
  }
}
