//
//  ViewController.swift
//  Gluon
//
//  Created by Max Desiatov on 09/15/2018.
//  Copyright (c) 2018 Max Desiatov. All rights reserved.
//

import Gluon
import GluonUIKit
import UIKit

final class GluonViewController: UIViewController {
  private var renderer: UIKitRenderer?

  override func viewDidLoad() {
    super.viewDidLoad()

    renderer = UIKitRenderer(node: App.node(Rectangle(view.frame)),
                             rootViewController: self)
  }

  @IBAction func onTap(_: Any) {
//    let counters = (0..<1_000_000).map { _ in
//        Counter(props: NoProps(), children: [])
//    }
    print(#file)
  }
}

final class ClassicViewController: UIViewController {
  private let button = UIButton()
  private let label = UILabel()

  private var counter = 0

  @objc func onPress() {
    counter += 1
    label.text = "\(counter)"
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    label.text = "\(counter)"

    button.addTarget(self, action: #selector(onPress), for: .touchUpInside)

    view.addSubview(button)
    view.addSubview(label)
  }
}
