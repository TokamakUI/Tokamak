//
//  TableViewBox.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 26/01/2019.
//

import Gluon
import UIKit

final class GluonTableCell: UITableViewCell {
  // FIXME: `component` has a strong reference to `box` through its own
  // property `target`, should that be `weak` to break a potential reference
  // cycle?
  fileprivate var component: UIKitRenderer.Mounted?
}

extension CellPath {
  init(_ path: IndexPath) {
    self.init(section: path.section, item: path.item)
  }
}

private final class DataSource<T: CellProvider>: NSObject,
  UITableViewDataSource {
  weak var viewController: UIViewController?
  weak var renderer: UIKitRenderer?
  var props: ListView<T>.Props

  init(
    _ props: ListView<T>.Props,
    _ viewController: UIViewController,
    _ renderer: UIKitRenderer?
  ) {
    self.props = props
    self.viewController = viewController
    self.renderer = renderer
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

    if let cell = tableView.dequeueReusableCell(
      withIdentifier: id.rawValue
    ) as? GluonTableCell, let component = cell.component {
      renderer?.update(component: component, with: node)
      return cell
    } else {
      let result = GluonTableCell(
        style: .default,
        reuseIdentifier: id.rawValue
      )
      if let viewController = viewController {
        result.component = renderer?.mount(
          with: node,
          to: ViewBox(result, viewController, node)
        )
      }
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
  private var dataSource: DataSource<T>

  var props: ListView<T>.Props {
    get {
      return dataSource.props
    }
    set {
      let oldModel = dataSource.props.model
      dataSource.props = newValue
      if oldModel != newValue.model {
        view.reloadData()
      }
    }
  }

  init(
    _ view: GluonTableView,
    _ viewController: UIViewController,
    _ component: UIKitRenderer.MountedHost,
    _ props: ListView<T>.Props,
    _ renderer: UIKitRenderer
  ) {
    dataSource = DataSource(props, viewController, renderer)
    view.dataSource = dataSource
    super.init(view, viewController, component.node)
  }
}
