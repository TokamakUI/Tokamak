//
//  Image.swift
//  Gluon
//
//  Created by Matvii Hodovaniuk on 2/17/19.
//

public struct Image: HostComponent {
  public typealias Children = [AnyNode]

  public struct Props: Equatable, StyleProps, Default {
    public static var defaultValue: Props {
      return Props()
    }

    public enum RenderingMode {
      case automatic
      case alwaysOriginal
      case alwaysTemplate
    }

    public enum Source: Equatable {
      case name(String)
      case data(Data)
    }

    // when changed initializes new image with `UIImage(named:)` or `UIImage(data:)`
    public let source: Source

    // when changed creates new image with `withRenderingMode`
    public let renderingMode: RenderingMode

    // when changed initializes new image with given scale
    public let scale: Double

    // mirrors `flipsForRightToLeftLayoutDirection`
    public let flipsForRTL: Bool

    public let style: Style?

    public init(
      source: Source = .name(""),
      renderingMode: RenderingMode = RenderingMode.automatic,
      scale: Double = 1.0,
      flipsForRTL: Bool = false,
      _ style: Style? = nil
    ) {
      self.source = source
      self.renderingMode = renderingMode
      self.scale = scale
      self.flipsForRTL = flipsForRTL
      self.style = style
    }
  }
}
