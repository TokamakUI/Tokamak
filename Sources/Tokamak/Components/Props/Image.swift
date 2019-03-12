//
//  Image.swift
//  Tokamak
//
//  Created by Max Desiatov on 26/02/2019.
//

import Foundation

public struct Image: Equatable {
  public enum ContentMode {
    case scaleToFill
    case scaleAspectFit
    case scaleAspectFill
    case center
    case top
    case bottom
    case left
    case right
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
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

  public let contentMode: ContentMode

  /// when changed initializes new image with given data or name
  public let source: Source

  /// when changed creates new image with `withRenderingMode`
  public let renderingMode: RenderingMode

  /// equivalent to  `flipsForRightToLeftLayoutDirection` in UIKit
  public let flipsForRTL: Bool

  /// when changed initializes new image with given scale
  public let scale: Double

  public init(
    contentMode: ContentMode = .scaleToFill,
    flipsForRTL: Bool = false,
    name: String,
    renderingMode: RenderingMode = .automatic,
    scale: Double = 1.0
  ) {
    source = .name(name)
    self.contentMode = contentMode
    self.renderingMode = renderingMode
    self.scale = scale
    self.flipsForRTL = flipsForRTL
  }

  public init(
    contentMode: ContentMode = .scaleToFill,
    data: Data,
    flipsForRTL: Bool = false,
    renderingMode: RenderingMode = .automatic,
    scale: Double = 1.0
  ) {
    source = .data(data)
    self.contentMode = contentMode
    self.renderingMode = renderingMode
    self.scale = scale
    self.flipsForRTL = flipsForRTL
  }
}
