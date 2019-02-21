//
//  Image.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 2/17/19.
//

import Foundation

public struct Image: HostComponent {
  public typealias Children = [AnyNode]

  public struct Props: Equatable, ViewProps {
    public enum RenderingMode {
      case automatic
      case alwaysOriginal
      case alwaysTemplate
    }

    public enum Source: Equatable {
      case name(String)
      case data(Data)
    }

    // when changed initializes new image with `UIImage(named:)`
    // or `UIImage(data:)`
    public let source: Source

    // when changed creates new image with `withRenderingMode`
    public let renderingMode: RenderingMode

    // when changed initializes new image with given scale
    public let scale: Double

    // mirrors `flipsForRightToLeftLayoutDirection`
    public let flipsForRTL: Bool

    public let style: Style?

    public init(
      flipsForRTL: Bool = false,
      name: String,
      renderingMode: RenderingMode = .automatic,
      scale: Double = 1.0,
      _ style: Style? = nil
    ) {
      source = .name(name)
      self.renderingMode = renderingMode
      self.scale = scale
      self.flipsForRTL = flipsForRTL
      self.style = style
    }

    public init(
      data: Data,
      flipsForRTL: Bool = false,
      renderingMode: RenderingMode = .automatic,
      scale: Double = 1.0,
      _ style: Style? = nil
    ) {
      source = .data(data)
      self.renderingMode = renderingMode
      self.scale = scale
      self.flipsForRTL = flipsForRTL
      self.style = style
    }
  }
}
