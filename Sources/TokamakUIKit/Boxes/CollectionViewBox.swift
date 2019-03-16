//
//  CollectionViewBox.swift
//  TokamakUIKit
//
//  Created by Matvii Hodovaniuk on 3/7/19.
//

import Tokamak
import UIKit

final class TokamakCollectionCell: UICollectionViewCell {
  // FIXME: `component` has a strong reference to `box` through its own
  // property `target`, should that be `weak` to break a potential reference
  // cycle?
  fileprivate var component: UIKitRenderer.Mounted?
}

private final class DataSource<T: CellProvider>: NSObject,
  UICollectionViewDataSource {
  weak var viewController: UIViewController?
  weak var renderer: UIKitRenderer?
  var props: CollectionView<T>.Props

  init(
    _ props: CollectionView<T>.Props,
    _ viewController: UIViewController,
    _ renderer: UIKitRenderer?
  ) {
    self.props = props
    self.viewController = viewController
    self.renderer = renderer
  }

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return props.sections.count
  }

  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    return props.sections[section].count
  }

  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    let item = props.sections[indexPath.section][indexPath.row]

    let (id, node) = T.cell(
      props: props.cellProps,
      item: item,
      path: CellPath(indexPath)
    )

    if let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: id.rawValue, for: indexPath
    ) as? TokamakCollectionCell, let component = cell.component {
      renderer?.update(component: component, with: node)
      return cell
    } else {
      if let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: id.rawValue, for: indexPath
      ) as? TokamakCollectionCell {
        if let component = cell.component {
          renderer?.update(component: component, with: node)
        } else if let viewController = viewController {
          cell.component = renderer?.mount(
            with: node,
            to: ViewBox(cell, viewController, node)
          )
        }
        return cell
      } else {
        fatalError("unknown cell type returned from dequeueReusableCell")
      }
    }
  }
}

private final class Delegate<T: CellProvider>:
  NSObject,
  UICollectionViewDelegate {
  var onSelect: ((CellPath) -> ())?

  func collectionView(
    _ collectionView: UICollectionView,
    didSelectItemAt indexPath: IndexPath
  ) {
    onSelect?(CellPath(indexPath))
  }

  init(_ props: CollectionView<T>.Props) {
    onSelect = props.onSelect?.value
  }
}

final class TokamakCollectionView: UICollectionView, Default {
  static var defaultValue: TokamakCollectionView {
    let layout = UICollectionViewFlowLayout()
    layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    return TokamakCollectionView(frame: .zero, collectionViewLayout: layout)
  }
}

final class CollectionViewBox<T: CellProvider>: ViewBox<TokamakCollectionView> {
  private let dataSource: DataSource<T>

  // this delegate stays as a constant and doesn't create a reference cycle
  // swiftlint:disable:next weak_delegate
  private let delegate: Delegate<T>

  var props: CollectionView<T>.Props {
    get {
      return dataSource.props
    }
    set {
      let oldSections = dataSource.props.sections
      dataSource.props = newValue
      delegate.onSelect = newValue.onSelect?.value
      if oldSections != newValue.sections {
        view.reloadData()
      }
    }
  }

  init(
    _ view: TokamakCollectionView,
    _ viewController: UIViewController,
    _ component: UIKitRenderer.MountedHost,
    _ props: CollectionView<T>.Props,
    _ renderer: UIKitRenderer
  ) {
    dataSource = DataSource(props, viewController, renderer)
    delegate = Delegate(props)
    view.dataSource = dataSource
    view.delegate = delegate

    for id in T.Identifier.allCases {
      view.register(
        TokamakCollectionCell.self,
        forCellWithReuseIdentifier: id.rawValue
      )
    }
    super.init(view, viewController, component.node)
  }
}
