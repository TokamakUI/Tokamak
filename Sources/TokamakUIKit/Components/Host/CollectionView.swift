//
//  CollectionView.swift
//  TokamakUIKit
//
//  Created by Matvii Hodovaniuk on 3/6/19.
//

import Tokamak
import UIKit

extension CollectionView: UIViewComponent {
  public typealias RefTarget = UICollectionView

  static func box(
    for view: TokamakCollectionView,
    _ viewController: UIViewController,
    _ component: UIKitRenderer.MountedHost,
    _ renderer: UIKitRenderer
  ) -> ViewBox<TokamakCollectionView> {
    guard let props = component.node.props.value as? Props else {
      fatalError("incorrect props type stored in CollectionView node")
    }

    return CollectionViewBox<T>(
      view,
      viewController,
      component,
      props,
      renderer
    )
  }

  static func update(view box: ViewBox<TokamakCollectionView>,
                     _ props: CollectionView<T>.Props,
                     _ children: Null) {
    guard let box = box as? CollectionViewBox<T> else {
      boxAssertionFailure("box")
      return
    }

    box.props = props
  }
}
