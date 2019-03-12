//
//  ContainerViewController.swift
//  TokamakUIKit
//
//  Created by Max Desiatov on 01/01/2019.
//

import AppKit
import Tokamak

final class ContainerViewController: NSViewController {
  private let contained: NSView

  init(contained: NSView) {
    self.contained = contained

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    view.addSubview(contained)
  }
}
