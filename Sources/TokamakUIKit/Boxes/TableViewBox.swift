//
//  TableViewBox.swift
//  TokamakUIKit
//
//  Created by Max Desiatov on 26/01/2019.
//

import Tokamak
import UIKit

final class TokamakTableCell: UITableViewCell {
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
    ) as? TokamakTableCell, let component = cell.component {
      renderer?.update(component: component, with: node)
      return cell
    } else {
      let result = TokamakTableCell(
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

private final class Delegate<T: CellProvider>: NSObject, UITableViewDelegate {
  var onSelect: ((CellPath) -> ())?

  func tableView(
    _ tableView: UITableView,
    didSelectRowAt indexPath: IndexPath
  ) {
    onSelect?(CellPath(indexPath))
  }

  init(_ props: ListView<T>.Props) {
    onSelect = props.onSelect?.value
  }
}

final class TokamakTableView: UITableView, Default {
  static var defaultValue: TokamakTableView {
    return TokamakTableView()
  }
}

final class TableViewBox<T: CellProvider>: ViewBox<TokamakTableView> {
  private let dataSource: DataSource<T>

  // this delegate stays as a constant and doesn't create a reference cycle
  // swiftlint:disable:next weak_delegate
  private let delegate: Delegate<T>

  var props: ListView<T>.Props {
    get {
      return dataSource.props
    }
    set {
      let oldModel = dataSource.props.model
      dataSource.props = newValue
      delegate.onSelect = newValue.onSelect?.value
      if oldModel != newValue.model {
        view.reloadData()
      }
    }
  }

  init(
    _ view: TokamakTableView,
    _ viewController: UIViewController,
    _ component: UIKitRenderer.MountedHost,
    _ props: ListView<T>.Props,
    _ renderer: UIKitRenderer
  ) {
    dataSource = DataSource(props, viewController, renderer)
    delegate = Delegate(props)
    view.dataSource = dataSource
    view.delegate = delegate
    super.init(view, viewController, component.node)
  }
}
