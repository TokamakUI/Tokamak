//
//  TableViewController.swift
//  Gluon_Example
//
//  Created by Max Desiatov on 26/01/2019.
//  Copyright © 2019 Gluon. All rights reserved.
//

import UIKit

struct Weak<T: AnyObject>: Hashable {
  static func ==(lhs: Weak<T>, rhs: Weak<T>) -> Bool {
    return lhs.value === rhs.value
  }

  public func hash(into hasher: inout Hasher) {
    guard let value = value else { return }
    hasher.combine(ObjectIdentifier(value))
  }

  weak var value: T?
}

var cells = [Weak<Cell>]()

final class Cell: UITableViewCell {
  deinit {
    print("cell deinit")
  }
}

final class VC: UITableViewController {
  override func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    switch indexPath.row {
    case let row where (row / 10) % 2 == 0:
      if let result = tableView.dequeueReusableCell(withIdentifier: "even") {
        return result
      } else {
        let result = Cell(style: .default, reuseIdentifier: "even")
        result.textLabel?.text = "even"
        cells.append(Weak(value: result))
        return result
      }
    case let row where (row / 10) % 2 == 1:
      if let result = tableView.dequeueReusableCell(withIdentifier: "odd") {
        return result
      } else {
        let result = Cell(style: .default, reuseIdentifier: "odd")
        result.textLabel?.text = "odd"
        cells.append(Weak(value: result))
        return result
      }
    default:
      fatalError("blah")
    }
  }

  override func tableView(
    _ tableView: UITableView,
    numberOfRowsInSection section: Int
  ) -> Int {
    return 1000
  }

  deinit {
    print(cells.count)
    DispatchQueue.main.async {
      print(cells)
    }
  }
}
