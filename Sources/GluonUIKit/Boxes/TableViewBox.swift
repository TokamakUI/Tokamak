//
//  TableViewBox.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 26/01/2019.
//

import Gluon
import UIKit

private final class DataSource<T: CellProvider>: NSObject,
  UITableViewDataSource {
  private let model: [[T]]

  init(model: [[T]]) {
    self.model = model
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    return model.count
  }

  func tableView(
    _ tableView: UITableView,
    numberOfRowsInSection section: Int
  ) -> Int {
    return model[section].count
  }

  func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    return UITableViewCell(style: .default, reuseIdentifier: "blah")
  }
}

final class GluonTableView: UITableView, Default {
  static var defaultValue: GluonTableView {
    return GluonTableView()
  }
}

final class TableViewBox: ViewBox<GluonTableView> {}
