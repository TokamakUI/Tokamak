public struct _ShadowLayout: ViewModifier, EnvironmentReader {
  public var color: Color
  public var radius: CGFloat
  public var x: CGFloat
  public var y: CGFloat
  public var environment: EnvironmentValues!

  public func body(content: Content) -> some View {
    content
  }

  // mutating func setContent(from values: EnvironmentValues) {
  //   environment = values
  // }
}

public extension View {
  func shadow(
    color: Color = Color(.sRGBLinear, white: 0, opacity: 0.33),
    radius: CGFloat,
    x: CGFloat = 0,
    y: CGFloat = 0
  ) -> some View {
    modifier(_ShadowLayout(color: color, radius: radius, x: x, y: y))
  }
}
