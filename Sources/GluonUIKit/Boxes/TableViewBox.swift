//
//  TableViewBox.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 26/01/2019.
//

import Gluon
import UIKit

final class DataSource<T: CellProvider>: NSObject,
  UITableViewDataSource {
  var model: T.Model

  init(_ model: T.Model) {
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

final class TableViewBox<T: CellProvider>: ViewBox<GluonTableView> {
  weak var component: UIKitRenderer.Component?
  var dataSource: DataSource<T>

  init(
    _ view: GluonTableView,
    _ viewController: UIViewController,
    _ component: UIKitRenderer.Component,
    _ model: T.Model
  ) {
    dataSource = DataSource(model)
    self.component = component
    super.init(view, viewController, component.node)
  }
}
