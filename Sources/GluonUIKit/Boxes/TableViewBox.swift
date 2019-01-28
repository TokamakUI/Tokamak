//
//  TableViewBox.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 26/01/2019.
//

import Gluon
import UIKit

final class TableCellBox: ViewBox<UITableViewCell> {}

extension CellPath {
  init(_ path: IndexPath) {
    self.init(section: path.section, item: path.item)
  }
}

final class DataSource<T: CellProvider>: NSObject,
  UITableViewDataSource {
  weak var viewController: UIViewController?
  weak var component: UIKitRenderer.Component?
  var props: ListView<T>.Props

  init(_ props: ListView<T>.Props, _ component: UIKitRenderer.Component) {
    self.props = props
    self.component = component
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    return props.model.count
  }

  func tableView(
    _ tableView: UITableView,
    numberOfRowsInSection section: Int
  ) -> Int {
    return props.model[section].count
  }

  func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    let item = props.model[indexPath.section][indexPath.row]

    let (id, node) = T.cell(
      props: props.cellProps,
      item: item,
      path: CellPath(indexPath)
    )

    if let cell = tableView.dequeueReusableCell(withIdentifier: id.rawValue) {
//      component?.reconcile(managed: , with: node)
      return cell
    } else {
      let result = UITableViewCell(
        style: .default,
        reuseIdentifier: id.rawValue
      )
//      component?.manage(child: , with: node)
      return result
    }
  }
}

final class GluonTableView: UITableView, Default {
  static var defaultValue: GluonTableView {
    return GluonTableView()
  }
}

final class TableViewBox<T: CellProvider>: ViewBox<GluonTableView> {
  var dataSource: DataSource<T>

  init(
    _ view: GluonTableView,
    _ viewController: UIViewController,
    _ component: UIKitRenderer.Component,
    _ props: ListView<T>.Props
  ) {
    dataSource = DataSource(props, component)
    super.init(view, viewController, component.node)
  }
}
