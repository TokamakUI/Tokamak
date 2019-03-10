//
//  ContentMode.swift
//  Pods-TokamakDemo
//
//  Created by Matvii Hodovaniuk on 2/19/19.
//

import Tokamak
import UIKit

extension UIView.ContentMode {
  public init(_ contentMode: Image.ContentMode) {
    switch contentMode {
    case .scaleToFill:
      self = .scaleToFill
    case .scaleAspectFit:
      self = .scaleAspectFit
    case .scaleAspectFill:
      self = .scaleAspectFill
    case .center:
      self = .center
    case .top:
      self = .top
    case .bottom:
      self = .bottom
    case .left:
      self = .left
    case .right:
      self = .right
    case .topLeft:
      self = .topLeft
    case .topRight:
      self = .topRight
    case .bottomLeft:
      self = .bottomLeft
    case .bottomRight:
      self = .bottomRight
    }
  }
}
