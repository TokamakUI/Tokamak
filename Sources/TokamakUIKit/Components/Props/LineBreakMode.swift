//
//  LineBreakMode.swift
//  TokamakUIKit
//
//  Created by Max Desiatov on 14/02/2019.
//

import Tokamak
import UIKit

extension NSLineBreakMode {
  public init(_ mode: LineBreakMode) {
    switch mode {
    case .wordWrap:
      self = .byWordWrapping
    case .charWrap:
      self = .byCharWrapping
    case .clip:
      self = .byClipping
    case .truncateHead:
      self = .byTruncatingHead
    case .truncateTail:
      self = .byTruncatingTail
    case .truncateMiddle:
      self = .byTruncatingMiddle
    }
  }
}
