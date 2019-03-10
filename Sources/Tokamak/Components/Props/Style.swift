//
//  Style.swift
//  Tokamak
//
//  Created by Max Desiatov on 31/12/2018.
//

public protocol StyleProps {
  var style: Style? { get }
}

public enum Layout: Equatable {
  case frame(Rectangle)
  case constraints([Constraint])
}

public struct Style: Equatable {
  public let accessibility: Accessibility?
  public let allowsEdgeAntialiasing: Bool?
  public let allowsGroupOpacity: Bool?
  public let backgroundColor: Color?
  public let borderColor: Color?
  public let borderWidth: Float?
  public let cornerRadius: Float?
  public let isDoubleSided: Bool?
  public let isHidden: Bool?
  public let masksToBounds: Bool?
  public let opacity: Float?
  public let shadowColor: Color?
  public let shadowOpacity: Float?
  public let shadowRadius: Float?
  public let layout: Layout?

  public init(
    accessibility: Accessibility? = nil,
    allowsEdgeAntialiasing: Bool? = false,
    allowsGroupOpacity: Bool? = true,
    backgroundColor: Color? = nil,
    borderColor: Color? = nil,
    borderWidth: Float? = 0.0,
    cornerRadius: Float? = 0.0,
    isDoubleSided: Bool? = true,
    isHidden: Bool? = nil,
    masksToBounds: Bool? = false,
    opacity: Float? = 1.0,
    shadowColor: Color? = nil,
    shadowOpacity: Float? = 0.0,
    shadowRadius: Float? = 3.0
  ) {
    self.accessibility = accessibility
    self.allowsEdgeAntialiasing = allowsEdgeAntialiasing
    self.allowsGroupOpacity = allowsGroupOpacity
    self.backgroundColor = backgroundColor
    self.borderColor = borderColor
    self.borderWidth = borderWidth
    self.cornerRadius = cornerRadius
    self.isDoubleSided = isDoubleSided
    self.isHidden = isHidden
    self.masksToBounds = masksToBounds
    self.opacity = opacity
    self.shadowColor = shadowColor
    self.shadowOpacity = shadowOpacity
    self.shadowRadius = shadowRadius

    layout = nil
  }

  public init(
    _ frame: Rectangle,
    accessibility: Accessibility? = nil,
    allowsEdgeAntialiasing: Bool? = false,
    allowsGroupOpacity: Bool? = true,
    backgroundColor: Color? = nil,
    borderColor: Color? = nil,
    borderWidth: Float? = 0.0,
    cornerRadius: Float? = 0.0,
    isDoubleSided: Bool? = true,
    isHidden: Bool? = nil,
    masksToBounds: Bool? = false,
    opacity: Float? = 1.0,
    shadowColor: Color? = nil,
    shadowOpacity: Float? = 0.0,
    shadowRadius: Float? = 3.0
  ) {
    self.accessibility = accessibility
    self.allowsEdgeAntialiasing = allowsEdgeAntialiasing
    self.allowsGroupOpacity = allowsGroupOpacity
    self.backgroundColor = backgroundColor
    self.borderColor = borderColor
    self.borderWidth = borderWidth
    self.cornerRadius = cornerRadius
    self.isDoubleSided = isDoubleSided
    self.isHidden = isHidden
    self.masksToBounds = masksToBounds
    self.opacity = opacity
    self.shadowColor = shadowColor
    self.shadowOpacity = shadowOpacity
    self.shadowRadius = shadowRadius

    layout = .frame(frame)
  }

  public init(
    _ constraint: Constraint,
    accessibility: Accessibility? = nil,
    allowsEdgeAntialiasing: Bool? = false,
    allowsGroupOpacity: Bool? = true,
    backgroundColor: Color? = nil,
    borderColor: Color? = nil,
    borderWidth: Float? = 0.0,
    cornerRadius: Float? = 0.0,
    isDoubleSided: Bool? = true,
    isHidden: Bool? = nil,
    masksToBounds: Bool? = false,
    opacity: Float? = 1.0,
    shadowColor: Color? = nil,
    shadowOpacity: Float? = 0.0,
    shadowRadius: Float? = 3.0
  ) {
    self.accessibility = accessibility
    self.allowsEdgeAntialiasing = allowsEdgeAntialiasing
    self.allowsGroupOpacity = allowsGroupOpacity
    self.backgroundColor = backgroundColor
    self.borderColor = borderColor
    self.borderWidth = borderWidth
    self.cornerRadius = cornerRadius
    self.isDoubleSided = isDoubleSided
    self.isHidden = isHidden
    self.masksToBounds = masksToBounds
    self.opacity = opacity
    self.shadowColor = shadowColor
    self.shadowOpacity = shadowOpacity
    self.shadowRadius = shadowRadius

    layout = .constraints([constraint])
  }

  public init(
    _ constraints: [Constraint],
    accessibility: Accessibility? = nil,
    allowsEdgeAntialiasing: Bool? = false,
    allowsGroupOpacity: Bool? = true,
    backgroundColor: Color? = nil,
    borderColor: Color? = nil,
    borderWidth: Float? = 0.0,
    cornerRadius: Float? = 0.0,
    isDoubleSided: Bool? = true,
    isHidden: Bool? = nil,
    masksToBounds: Bool? = false,
    opacity: Float? = 1.0,
    shadowColor: Color? = nil,
    shadowOpacity: Float? = 0.0,
    shadowRadius: Float? = 3.0
  ) {
    self.accessibility = accessibility
    self.allowsEdgeAntialiasing = allowsEdgeAntialiasing
    self.allowsGroupOpacity = allowsGroupOpacity
    self.backgroundColor = backgroundColor
    self.borderColor = borderColor
    self.borderWidth = borderWidth
    self.cornerRadius = cornerRadius
    self.isDoubleSided = isDoubleSided
    self.isHidden = isHidden
    self.masksToBounds = masksToBounds
    self.opacity = opacity
    self.shadowColor = shadowColor
    self.shadowOpacity = shadowOpacity
    self.shadowRadius = shadowRadius

    layout = .constraints(constraints)
  }
}
