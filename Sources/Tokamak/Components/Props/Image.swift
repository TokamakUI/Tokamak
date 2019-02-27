//
//  Image.swift
//  Tokamak
//
//  Created by Max Desiatov on 26/02/2019.
//

import Foundation

public struct Image: Equatable {
  public enum RenderingMode {
    case automatic
    case alwaysOriginal
    case alwaysTemplate
  }

  public enum Source: Equatable {
    case name(String)
    case data(Data)
  }

  /// when changed initializes new image with given data or name
  public let source: Source

  /// when changed creates new image with `withRenderingMode`
  public let renderingMode: RenderingMode

  /// equivalent to  `flipsForRightToLeftLayoutDirection` in UIKit
  public let flipsForRTL: Bool

  // when changed initializes new image with given scale
  public let scale: Double

  public init(
    flipsForRTL: Bool = false,
    name: String,
    renderingMode: RenderingMode = .automatic,
    scale: Double = 1.0
  ) {
    source = .name(name)
    self.renderingMode = renderingMode
    self.scale = scale
    self.flipsForRTL = flipsForRTL
  }

  public init(
    data: Data,
    flipsForRTL: Bool = false,
    renderingMode: RenderingMode = .automatic,
    scale: Double = 1.0
  ) {
    source = .data(data)
    self.renderingMode = renderingMode
    self.scale = scale
    self.flipsForRTL = flipsForRTL
  }
}
